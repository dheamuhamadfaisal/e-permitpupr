import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';

import 'package:go_router/go_router.dart';

import '../widgets/recent_permohonan_card.dart';
import '../widgets/stat_card.dart';

class VerifikatorDashboardScreen extends StatefulWidget {
  const VerifikatorDashboardScreen({super.key});

  @override
  State<VerifikatorDashboardScreen> createState() => _VerifikatorDashboardScreenState();
}

class _VerifikatorDashboardScreenState extends State<VerifikatorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider = context.read<DashboardProvider>();
    await provider.fetchDashboardForRole('verifikator');
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
    final data = provider.verifikatorDashboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Verifikator (Kabid/Kadis)'),
        automaticallyImplyLeading: false,
        actions: [
        ],
      ),
      body: provider.isLoading && provider.verifikatorDashboard == null
          ? const Center(child: CircularProgressIndicator())
          : provider.verifikatorDashboard == null
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
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${user?.name ?? 'Verifikator'} ⚖️',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Kabid & Kadis Dinas PUPR — Persetujuan / Penolakan Final',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Statistik Verifikasi Final',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stats Grid (4 Items)
                        GridView.count(
                          crossAxisCount: ResponsiveLayout.isDesktop(context) ? 4 : (ResponsiveLayout.isTablet(context) ? 3 : 2),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          children: [
                            StatCard(
                              title: 'Menunggu Verifikasi',
                              count: data?.menungguVerifikasi ?? 0,
                              icon: Icons.hourglass_top_outlined,
                              color: const Color(0xFF0284C7),
                            ),
                            StatCard(
                              title: 'Disetujui',
                              count: data?.disetujui ?? 0,
                              icon: Icons.check_circle_outline,
                              color: const Color(0xFF16A34A),
                            ),
                            StatCard(
                              title: 'Ditolak',
                              count: data?.ditolak ?? 0,
                              icon: Icons.cancel_outlined,
                              color: const Color(0xFFDC2626),
                            ),
                            StatCard(
                              title: 'Perlu Revisi',
                              count: data?.perluRevisi ?? 0,
                              icon: Icons.edit_note,
                              color: const Color(0xFFEA580C),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                        const Text(
                          'Siap Verifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (data?.permohonanTerbaru.isEmpty ?? true)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak Ada Permohonan Menunggu Verifikasi',
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          )
                        else
                          ...data!.permohonanTerbaru.map(
                            (p) => RecentPermohonanCard(
                              permohonan: p,
                              onTap: () => context.push('/verifikator/permohonan/${p.id}'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
