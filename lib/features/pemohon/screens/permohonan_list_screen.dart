import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/permohonan_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/dashboard_model.dart';
import '../../../routes/app_router.dart';
import '../widgets/permohonan_card.dart';

class PermohonanListScreen extends StatefulWidget {
  const PermohonanListScreen({super.key});

  @override
  State<PermohonanListScreen> createState() => _PermohonanListScreenState();
}

class _PermohonanListScreenState extends State<PermohonanListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': '', 'label': 'Semua Status', 'icon': Icons.menu},
    {'value': 'draft', 'label': 'Draft', 'icon': Icons.assignment_outlined},
    {'value': 'diajukan', 'label': 'Diajukan', 'icon': Icons.send_outlined},
    {'value': 'ditolak_permanen', 'label': 'Ditolak', 'icon': Icons.cancel_outlined},
    {'value': 'perlu_revisi', 'label': 'Perlu Revisi', 'icon': Icons.autorenew},
    {'value': 'terbit', 'label': 'Surat Terbit', 'icon': Icons.check_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({int page = 1}) async {
    final provider = context.read<PermohonanProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    
    await Future.wait([
      provider.fetchPermohonan(page: page),
      dashboardProvider.fetchDashboardForRole('pemohon'),
    ]);
    
    if (!mounted) return;

    if (provider.error != null) {
      final errorMsg = provider.error!;
      showGlobalErrorBottomSheet(
        context,
        errorMessage: errorMsg,
        onRetry: () => _fetchData(page: context.read<PermohonanProvider>().currentPage),
      );
    }
  }

  int _getCountForStatus(DashboardPemohonModel? dashboard, String statusValue) {
    if (dashboard == null) return 0;
    switch (statusValue) {
      case '': return dashboard.totalPermohonan;
      case 'draft': return dashboard.draft;
      case 'diajukan': return dashboard.sedangDiproses;
      case 'ditolak_permanen': return dashboard.ditolak;
      case 'perlu_revisi': return dashboard.perluRevisi;
      case 'terbit': return dashboard.disetujui;
      default: return 0;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermohonanProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboard = dashboardProvider.pemohonDashboard;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Permohonan Saya'),
        automaticallyImplyLeading: false,
      ),

      body: Column(
        children: [
          // Filter & Search Section
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nomor permohonan / jenis ....',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setFilter(search: '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  onChanged: (val) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      provider.setFilter(search: val.trim());
                    });
                  },
                  onSubmitted: (val) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    provider.setFilter(search: val.trim());
                  },
                ),
                const SizedBox(height: 16),

                // Status Chips Filter (Row of Column Icons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _statusOptions.map((item) {
                    final isSelected = provider.selectedStatus == item['value'];
                    final color = isSelected ? AppTheme.primaryColor : const Color(0xFF64748B);
                    final count = _getCountForStatus(dashboard, item['value'] as String);
                    
                    return GestureDetector(
                      onTap: () {
                        provider.setFilter(status: item['value']);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Badge(
                            label: Text(count > 99 ? '99+' : count.toString()),
                            backgroundColor: AppTheme.primaryColor,
                            textColor: Colors.white,
                            isLabelVisible: count > 0,
                            child: Icon(
                              item['icon'] as IconData,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content List
          Expanded(
            child: provider.isLoading && provider.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.items.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => _fetchData(page: 1),
                        child: const GlobalEmptyState(
                          title: 'Belum ada aktivitas',
                          subtitle: 'Saat ini anda belum membuat permohonan.\nYuk mulai ajukan permohonan pertama anda!',
                          imagePath: 'assets/images/belum ada permohonan.png',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _fetchData(page: 1),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding bottom secukupnya untuk navbar
                          itemCount: provider.items.length + (provider.lastPage > 1 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.items.length) {
                              // Pagination diletakkan di akhir list agar ikut ke-scroll
                              return Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: provider.currentPage > 1
                                          ? () => _fetchData(page: provider.currentPage - 1)
                                          : null,
                                    ),
                                    Text(
                                      'Halaman ${provider.currentPage} dari ${provider.lastPage}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed: provider.currentPage < provider.lastPage
                                          ? () => _fetchData(page: provider.currentPage + 1)
                                          : null,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final item = provider.items[index];
                            return PermohonanCard(
                              permohonan: item,
                              onTap: () => context.push('/permohonan/${item.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
