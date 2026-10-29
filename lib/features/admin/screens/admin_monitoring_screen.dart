import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/admin_provider.dart';
import '../../../models/permohonan_model.dart';
import '../../../core/utils/api_exception.dart';

class AdminMonitoringScreen extends StatefulWidget {
  const AdminMonitoringScreen({super.key});

  @override
  State<AdminMonitoringScreen> createState() => _AdminMonitoringScreenState();
}

class _AdminMonitoringScreenState extends State<AdminMonitoringScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _selectedStatus = '';
  String _selectedJenis = '';
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': '', 'label': 'Semua Status', 'icon': Icons.menu_rounded},
    {'value': 'draft', 'label': 'Draft', 'icon': Icons.edit_note_rounded},
    {'value': 'diajukan', 'label': 'Diajukan', 'icon': Icons.send_rounded},
    {'value': 'dalam_validasi_kelengkapan', 'label': 'Validasi', 'icon': Icons.rule_rounded},
    {'value': 'perlu_kunjungan_lapangan', 'label': 'Survey', 'icon': Icons.location_on_rounded},
    {'value': 'dalam_analisis', 'label': 'Analisis', 'icon': Icons.analytics_rounded},
    {'value': 'siap_terbit', 'label': 'Siap Terbit', 'icon': Icons.task_alt_rounded},
    {'value': 'perlu_revisi', 'label': 'Perlu Revisi', 'icon': Icons.assignment_return_rounded},
    {'value': 'terbit', 'label': 'Surat Terbit', 'icon': Icons.verified_rounded},
    {'value': 'ditolak_permanen', 'label': 'Ditolak', 'icon': Icons.cancel_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchMasterJenisPerizinan();
      _applyFilter(page: 1);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyFilter({int page = 1}) async {
    final provider = context.read<AdminProvider>();
    
    // Pastikan master jenis perizinan sudah dimuat untuk mapping _selectedJenis ke ID
    if (provider.jenisList.isEmpty && !provider.isJenisLoading) {
      await provider.fetchMasterJenisPerizinan();
    }

    int? jenisPerizinanId;
    if (_selectedJenis.isNotEmpty) {
      try {
        final jenis = provider.jenisList.firstWhere(
          (j) => j.kode.toUpperCase() == _selectedJenis.toUpperCase(),
        );
        jenisPerizinanId = jenis.id;
      } catch (_) {
        // Jika tidak ditemukan, filter tidak akan berlaku
      }
    }

    await provider.fetchMonitoring(
      status: _selectedStatus.isEmpty ? null : _selectedStatus,
      jenisPerizinanId: jenisPerizinanId,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      page: page,
    );
    
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: () => _applyFilter(page: page),
      );
    }
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
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Monitoring Seluruh Permohonan'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ─────────────────────────────────────────────────────────────────
          // HEADER: Search, Filter Status & Jenis
          // ─────────────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar (rounded border + primary color)
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
                              _applyFilter(page: 1);
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
                      _applyFilter(page: 1);
                    });
                  },
                  onSubmitted: (_) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _applyFilter(page: 1);
                  },
                ),
                const SizedBox(height: 16),

                // Status Icon Filter Row
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: [
                    ...(_isExpanded 
                        ? _statusOptions 
                        : _statusOptions.where((item) => _statusOptions.indexOf(item) < 3 || item['value'] == _selectedStatus)).map((item) {
                      final isSelected = _selectedStatus == item['value'];
                      final color = isSelected ? AppTheme.primaryColor : const Color(0xFF64748B);

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedStatus = item['value'] as String);
                          _applyFilter(page: 1);
                        },
                        child: SizedBox(
                          width: 60, // Fixed width to ensure consistent alignment in Wrap
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryColor.withValues(alpha: 0.12)
                                          : Colors.grey.withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData,
                                      color: color,
                                      size: 20,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['label'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    // Tombol Lainnya / Tutup
                    GestureDetector(
                      onTap: () {
                        setState(() => _isExpanded = !_isExpanded);
                      },
                      child: SizedBox(
                        width: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isExpanded ? 'Tutup' : 'Lainnya',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Segmented Control — Semua Layanan / dinamis
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
                          selectedValue: _selectedJenis,
                          isFirst: true,
                          isLast: provider.jenisList.isEmpty,
                          onTap: () {
                            setState(() => _selectedJenis = '');
                            _applyFilter(page: 1);
                          },
                        ),
                        if (provider.jenisList.isNotEmpty) Container(width: 1, color: Colors.grey.shade300),
                        ...provider.jenisList.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final jenis = entry.value;
                          final isLast = idx == provider.jenisList.length - 1;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSegmentItem(
                                label: jenis.kode,
                                value: jenis.kode,
                                selectedValue: _selectedJenis,
                                isFirst: false,
                                isLast: isLast,
                                onTap: () {
                                  setState(() => _selectedJenis = jenis.kode);
                                  _applyFilter(page: 1);
                                },
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

          // ─────────────────────────────────────────────────────────────────
          // DAFTAR MONITORING
          // ─────────────────────────────────────────────────────────────────
          Expanded(
            child: provider.isMonitoringLoading && provider.monitoringList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.monitoringList.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => _applyFilter(page: 1),
                        child: const GlobalEmptyState(
                          title: 'Belum Ada Data',
                          subtitle: 'Tidak ada data monitoring permohonan yang ditemukan.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _applyFilter(page: provider.monCurrentPage),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: provider.monitoringList.length + (provider.monLastPage > 1 ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.monitoringList.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: provider.monCurrentPage > 1
                                          ? () => _applyFilter(page: provider.monCurrentPage - 1)
                                          : null,
                                    ),
                                    Text(
                                      'Halaman ${provider.monCurrentPage} dari ${provider.monLastPage}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed: provider.monCurrentPage < provider.monLastPage
                                          ? () => _applyFilter(page: provider.monCurrentPage + 1)
                                          : null,
                                    ),
                                  ],
                                ),
                              );
                            }
                            final p = provider.monitoringList[index];
                            return _MonitoringCard(
                              permohonan: p,
                              onDelete: () => _confirmDelete(context, p.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengajuan'),
        content: const Text('Apakah Anda yakin ingin menghapus pengajuan ini secara permanen? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<AdminProvider>();
              final success = await provider.deleteMonitoring(id);
              if (!context.mounted) return;
              if (success) {
                context.showSuccessMessage('Pengajuan berhasil dihapus');
              } else if (provider.error != null) {
                showGlobalErrorBottomSheet(
                  context,
                  errorMessage: provider.error!,
                  onRetry: () {}, // Kosongkan karena bukan fungsi filter
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Widget — Mirip RecentPermohonanCard + detail monitoring
// ─────────────────────────────────────────────────────────────────────────────
class _MonitoringCard extends StatelessWidget {
  final PermohonanModel permohonan;
  final VoidCallback onDelete;

  const _MonitoringCard({required this.permohonan, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isKRK = permohonan.jenisPerizinan?.kode == 'KRK';
    final accentColor = isKRK ? Colors.blueAccent : Colors.orangeAccent;
    final statusColor = permohonan.statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/admin/monitoring/${permohonan.id}');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Left Accent Bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(color: accentColor),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Nomor + Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              permohonan.nomorPermohonan,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (permohonan.jenisPerizinan != null)
                              Row(
                                children: [
                                  Icon(Icons.description_outlined, size: 14, color: accentColor),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${permohonan.jenisPerizinan!.kode} — ${permohonan.jenisPerizinan!.nama}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          permohonan.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Row 2: Pemohon & Lokasi
                  if (permohonan.pemohon != null)
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      text: permohonan.pemohon!.name,
                      isBold: true,
                    ),
                  if (permohonan.pemohon?.alamat != null &&
                      permohonan.pemohon!.alamat!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: permohonan.pemohon!.alamat!,
                    ),

                  const SizedBox(height: 6),

                  // Row 3: Tanggal & Detail & Hapus
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Dibuat: ${permohonan.createdAt.split('T').first}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),
                      const Spacer(),
                      
                      // Tombol Hapus (Kecil)
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            'Hapus',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Detail >',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isBold;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
