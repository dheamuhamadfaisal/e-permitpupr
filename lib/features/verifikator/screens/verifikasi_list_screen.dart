import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/verifikator_provider.dart';
import '../../dashboard/widgets/recent_permohonan_card.dart';

class VerifikasiListScreen extends StatefulWidget {
  const VerifikasiListScreen({super.key});

  @override
  State<VerifikasiListScreen> createState() => _VerifikasiListScreenState();
}

class _VerifikasiListScreenState extends State<VerifikasiListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, String>> _statusOptions = [
    {'value': '', 'label': 'Semua Status'},
    {'value': 'menunggu_verifikasi', 'label': 'Menunggu Verifikasi'},
    {'value': 'disetujui', 'label': 'Disetujui'},
    {'value': 'ditolak', 'label': 'Ditolak'},
    {'value': 'revisi', 'label': 'Revisi'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({int page = 1}) async {
    final provider = context.read<VerifikatorProvider>();
    await provider.fetchPermohonan(page: page);
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: () => _fetchData(page: provider.currentPage),
      );
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
    final provider = context.watch<VerifikatorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Permohonan (Kabid/Kadis)'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter & Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Nomor Permohonan / Pemohon / Jenis...',
                    prefixIcon: const Icon(Icons.search, size: 20),
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
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                const SizedBox(height: 12),

                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusOptions.length,
                    itemBuilder: (context, index) {
                      final item = _statusOptions[index];
                      final isSelected = provider.selectedStatus == item['value'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(item['label']!),
                          selected: isSelected,
                          onSelected: (_) => provider.setFilter(status: item['value']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: provider.isLoading && provider.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.items.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => _fetchData(page: 1),
                        child: const GlobalEmptyState(
                          title: 'Belum Ada Verifikasi',
                          subtitle: 'Saat Ini Belum Ada Permohonan Yang Perlu Diverifikasi.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _fetchData(page: 1),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: provider.items.length + (provider.lastPage > 1 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.items.length) {
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
                            return RecentPermohonanCard(
                              permohonan: item,
                              onTap: () => context.push('/verifikator/permohonan/${item.id}'),
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
