import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';

import '../widgets/recent_permohonan_card.dart';
import '../../navigation/petugas_navigation.dart';

class PetugasDashboardScreen extends StatefulWidget {
  const PetugasDashboardScreen({super.key});

  @override
  State<PetugasDashboardScreen> createState() => _PetugasDashboardScreenState();
}

class _PetugasDashboardScreenState extends State<PetugasDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider = context.read<DashboardProvider>();
    await provider.fetchDashboardForRole('petugas');
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: _fetchData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<DashboardProvider>();
    final data = provider.petugasDashboard;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: provider.isLoading && provider.petugasDashboard == null
            ? const Center(child: CircularProgressIndicator())
            : provider.petugasDashboard == null
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
                          // Header (gaya Admin)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo ${user?.name ?? 'Petugas Tata Ruang'}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Bagian Tata Ruang — Pemeriksaan Teknis & Survey',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Statistik Tugas Teknis (Banner gaya Admin)
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
                                    'Statistik Tugas Teknis',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildBannerStat(icon: Icons.menu, count: data?.totalPermohonan ?? 0, label: 'Semua Layanan', iconColor: Colors.white70),
                                    _buildBannerStat(icon: Icons.send_outlined, count: data?.diajukan ?? 0, label: 'Diajukan', iconColor: Colors.white70),
                                    _buildBannerStat(icon: Icons.location_on_outlined, count: data?.perluKunjunganLapangan ?? 0, label: 'Survey', iconColor: const Color(0xFF38BDF8)),
                                    _buildBannerStat(icon: Icons.analytics_outlined, count: data?.dalamAnalisis ?? 0, label: 'Analisis', iconColor: const Color(0xFFFBBF24)),
                                    _buildBannerStat(icon: Icons.assignment_turned_in_outlined, count: data?.siapTerbit ?? 0, label: 'Siap Terbit', iconColor: const Color(0xFF94A3B8)),
                                    _buildBannerStat(icon: Icons.check_circle_outline, count: data?.terbit ?? 0, label: 'Terbit', iconColor: const Color(0xFF4ADE80)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Tugas Masuk Terbaru
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tugas Masuk Terbaru',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if ((data?.permohonanTerbaru.length ?? 0) > 3)
                                  GestureDetector(
                                    onTap: () {
                                      context.findAncestorStateOfType<PetugasNavigationState>()?.switchTab(1);
                                    },
                                    child: Text(
                                      'Lihat Tab Tugas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: data?.permohonanTerbaru.isEmpty ?? true
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Tidak Ada Tugas Teknis Aktif',
                                        style: TextStyle(color: Color(0xFF94A3B8)),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: data!.permohonanTerbaru.take(3).map(
                                      (p) => RecentPermohonanCard(
                                        permohonan: p,
                                        onTap: () => context.push('/petugas/permohonan/${p.id}'),
                                      ),
                                    ).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildBannerStat({required IconData icon, required int count, required String label, required Color iconColor}) {
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
}
