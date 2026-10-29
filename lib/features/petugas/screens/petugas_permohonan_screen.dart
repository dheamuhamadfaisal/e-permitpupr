import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/petugas_provider.dart';
import '../../../providers/jenis_perizinan_provider.dart';
import '../../dashboard/widgets/recent_permohonan_card.dart';

/// Halaman Dashboard Utama Petugas Bidang Tata Ruang (Validator Single Actor)
/// Fitur Utama:
/// 1. Kartu Statistik Aktif: Menampilkan jumlah tugas & dapat diklik untuk memfilter daftar permohonan.
/// 2. Tab Bar Pemisah Layanan: Memisahkan tampilan pengajuan KRK dan Siteplan agar rapi & tidak membingungkan.
/// 3. Tugas Teknis: Diklik untuk membuka detail permohonan & pengunduhan berkas pemohon.
class PetugasPermohonanScreen extends StatefulWidget {
  const PetugasPermohonanScreen({super.key});

  @override
  State<PetugasPermohonanScreen> createState() => _PetugasPermohonanScreenState();
}

class _PetugasPermohonanScreenState extends State<PetugasPermohonanScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': '', 'label': 'Semua Status', 'icon': Icons.menu, 'key': 'total'},
    {'value': 'diajukan', 'label': 'Diajukan', 'icon': Icons.send_outlined, 'key': 'diajukan'},
    {'value': 'perlu_kunjungan_lapangan', 'label': 'Survey', 'icon': Icons.location_on_outlined, 'key': 'survey'},
    {'value': 'dalam_analisis', 'label': 'Analisis', 'icon': Icons.analytics_outlined, 'key': 'analisis'},
    {'value': 'siap_terbit', 'label': 'Siap Terbit', 'icon': Icons.assignment_turned_in_outlined, 'key': 'siap_terbit'},
    {'value': 'terbit', 'label': 'Terbit', 'icon': Icons.check_circle_outline, 'key': 'terbit'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({int page = 1}) async {
    final dashboardProvider = context.read<DashboardProvider>();
    final petugasProvider = context.read<PetugasProvider>();
    final jenisProvider = context.read<JenisPerizinanProvider>();
    
    await jenisProvider.fetchJenisPerizinan();
    await dashboardProvider.fetchDashboardForRole('petugas');
    await petugasProvider.fetchPermohonan(page: page);
    if (!mounted) return;

    if (petugasProvider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: petugasProvider.error!,
        onRetry: () => _fetchData(page: petugasProvider.currentPage),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSegmentItem({
    required String label,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
    required bool isFirst,
    required bool isLast,
  }) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(20) : Radius.zero,
            right: isLast ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petugasProvider = context.watch<PetugasProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final stats = dashboardProvider.petugasDashboard;

    final jenisProvider = context.watch<JenisPerizinanProvider>();
    final selectedJenis = petugasProvider.selectedJenis;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tugas Bidang Tata Ruang'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // -------------------------------------------------------------
          // 1. SEARCH, FILTER STATUS & TIPE LAYANAN
          // -------------------------------------------------------------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nomor permohonan / jenis ....',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              petugasProvider.setFilter(search: '');
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
                      petugasProvider.setFilter(search: val.trim());
                    });
                  },
                  onSubmitted: (val) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    petugasProvider.setFilter(search: val.trim());
                  },
                ),
                const SizedBox(height: 16),

                // Status Chips Filter (Row of Column Icons with Badges)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B4B72),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B4B72).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _statusOptions.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isSelected = petugasProvider.selectedStatus == item['value'];
                      
                      Color iconColor = Colors.white70;
                      if (item['key'] == 'survey') iconColor = const Color(0xFF38BDF8);
                      else if (item['key'] == 'analisis') iconColor = const Color(0xFFFBBF24);
                      else if (item['key'] == 'siap_terbit') iconColor = const Color(0xFF94A3B8);
                      else if (item['key'] == 'terbit') iconColor = const Color(0xFF4ADE80);
                      
                      if (isSelected) iconColor = Colors.white;

                      int badgeCount = 0;
                      if (item['key'] == 'total') badgeCount = stats?.totalPermohonan ?? 0;
                      else if (item['key'] == 'diajukan') badgeCount = stats?.diajukan ?? 0;
                      else if (item['key'] == 'survey') badgeCount = stats?.perluKunjunganLapangan ?? 0;
                      else if (item['key'] == 'analisis') badgeCount = stats?.dalamAnalisis ?? 0;
                      else if (item['key'] == 'siap_terbit') badgeCount = stats?.siapTerbit ?? 0;
                      else if (item['key'] == 'terbit') badgeCount = stats?.terbit ?? 0;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            petugasProvider.setFilter(status: item['value']);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    color: iconColor,
                                    size: 26,
                                  ),
                                  if (badgeCount > 0)
                                    Positioned(
                                      right: -10,
                                      top: -6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          widthFactor: 1,
                                          heightFactor: 1,
                                          child: Text(
                                            badgeCount.toString(),
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : const Color(0xFF3B4B72),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Sub-filter Segmented Control (Pill shape)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentItem(
                          label: 'Semua Layanan',
                          value: '',
                          selectedValue: selectedJenis,
                          isFirst: true,
                          isLast: jenisProvider.items.isEmpty,
                          onTap: () => petugasProvider.setFilter(jenis: ''),
                        ),
                        if (jenisProvider.items.isNotEmpty) Container(width: 1, color: Colors.grey.shade300),
                        ...jenisProvider.items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final jenis = entry.value;
                          final isLast = idx == jenisProvider.items.length - 1;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSegmentItem(
                                label: jenis.kode,
                                value: jenis.kode,
                                selectedValue: selectedJenis,
                                isFirst: false,
                                isLast: isLast,
                                onTap: () => petugasProvider.setFilter(jenis: jenis.kode),
                              ),
                              if (!isLast) Container(width: 1, color: Colors.grey.shade300),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // -------------------------------------------------------------
          // 4. DAFTAR TUGAS TEKNIS (DIKLIK UNTUK MEMBUKA DETAIL & DOWNLOAD DOKUMEN)
          // -------------------------------------------------------------
          Expanded(
            child: petugasProvider.isLoading && petugasProvider.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : petugasProvider.items.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () => _fetchData(page: 1),
                            child: const GlobalEmptyState(
                              title: 'Tidak Ada Tugas',
                              subtitle: 'Tidak Ada Tugas Teknis Ditemukan Untuk Filter Ini.',
                              imagePath: 'assets/images/error_pekerja.png',
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _fetchData(page: 1),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: petugasProvider.items.length + (petugasProvider.lastPage > 1 ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == petugasProvider.items.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: petugasProvider.currentPage > 1
                                              ? () => _fetchData(page: petugasProvider.currentPage - 1)
                                              : null,
                                        ),
                                        Text(
                                          'Halaman ${petugasProvider.currentPage} dari ${petugasProvider.lastPage}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: petugasProvider.currentPage < petugasProvider.lastPage
                                              ? () => _fetchData(page: petugasProvider.currentPage + 1)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final item = petugasProvider.items[index];
                                return RecentPermohonanCard(
                                  permohonan: item,
                                  onTap: () => context.push('/petugas/permohonan/${item.id}'),
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
