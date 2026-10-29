import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/dashboard_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider = context.read<DashboardProvider>();
    await provider.fetchDashboardForRole('admin');
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: _fetchData,
      );
    }
  }

  int _getCount(DashboardAdminModel? data, String status) {
    if (data == null) return 0;
    int total = 0;
    data.statistikStatus.forEach((key, value) {
      if (key.toLowerCase().contains(status.toLowerCase())) {
        total += value;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<DashboardProvider>();
    final data = provider.adminDashboard;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: provider.isLoading && provider.adminDashboard == null
            ? const Center(child: CircularProgressIndicator())
            : provider.adminDashboard == null
                ? RefreshIndicator(
                    onRefresh: _fetchData,
                    child: const GlobalEmptyState(
                      title: 'Gagal Memuat',
                      subtitle: 'Tidak Ada Data Dashboard Yang Bisa Ditampilkan.',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo Admin Sistem',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Monitoring Sistem, User Management & Master Data',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          // Statistik Pengguna (Blue Card)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8, bottom: 20),
                                  child: Text(
                                    'Daftar Pengguna',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStatIcon(icon: Icons.group_outlined, count: data?.totalUser ?? 0, label: 'Total User', iconColor: Colors.white70),
                                    _buildStatIcon(icon: Icons.person_outline, count: data?.totalPemohon ?? 0, label: 'Pemohon', iconColor: const Color(0xFF67E8F9)),
                                    _buildStatIcon(icon: Icons.manage_accounts_outlined, count: data?.totalOperator ?? 0, label: 'Operator', iconColor: const Color(0xFFFB923C)),
                                    _buildStatIcon(icon: Icons.engineering_outlined, count: data?.totalPetugas ?? 0, label: 'Petugas', iconColor: const Color(0xFFAB8FEB)),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Daftar Pengajuan
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daftar Pengajuan',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildPengajuanCard(context, 'Semua', data?.totalPermohonan ?? 0, Icons.list_alt_rounded, const Color(0xFF3B4B72)),
                                    _buildPengajuanCard(context, 'Diajukan', _getCount(data, 'diajukan') + _getCount(data, 'draft'), Icons.assignment_outlined, const Color(0xFF0284C7)),
                                    _buildPengajuanCard(context, 'Ditolak', _getCount(data, 'ditolak'), Icons.cancel_outlined, const Color(0xFFDC2626)),
                                    _buildPengajuanCard(context, 'Revisi', _getCount(data, 'revisi'), Icons.edit_document, const Color(0xFFD97706)),
                                    _buildPengajuanCard(context, 'Surat Terbit', _getCount(data, 'terbit') + _getCount(data, 'selesai'), Icons.check_circle_outline, const Color(0xFF16A34A)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Daftar per Jenis Perizinan
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daftar per Jenis Perizinan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (data?.statistikJenis.isEmpty ?? true)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text('Belum Ada Data', style: TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                else
                                  ...data!.statistikJenis.map((j) => _buildJenisCard(j)).toList(),
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

  Widget _buildStatIcon({required IconData icon, required int count, required String label, required Color iconColor}) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: iconColor, size: 28),
              if (count > 0)
                Positioned(
                  top: -6,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B4B72),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPengajuanCard(BuildContext context, String label, int count, IconData icon, Color iconColor) {
    final width = (MediaQuery.of(context).size.width - 40 - 32) / 3;
    return Container(
      width: width,
      height: width * 1.35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3B4B72),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJenisCard(Map<String, dynamic> j) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: j['logo_url'] != null ? Colors.transparent : const Color(0xFF6B82A8),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: j['logo_url'] != null && j['logo_url'].toString().isNotEmpty
                ? Image.network(
                    j['logo_url'],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF6B82A8),
                      child: Center(
                        child: Text(
                          j['kode']?.toString() ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      j['kode']?.toString() ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              j['nama']?.toString() ?? '',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
          Text(
            '${j['permohonan_count'] ?? 0} Berkas',
            style: const TextStyle(color: Color(0xFF3B4B72), fontWeight: FontWeight.bold, fontSize: 13),
          )
        ],
      ),
    );
  }
}

