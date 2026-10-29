import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/custom_curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_sidebar.dart';

import '../dashboard/screens/pemohon_dashboard_screen.dart';
import '../pemohon/screens/permohonan_list_screen.dart';
import '../profile/screens/profile_screen.dart';

class PemohonNavigation extends StatefulWidget {
  const PemohonNavigation({super.key});

  @override
  State<PemohonNavigation> createState() => _PemohonNavigationState();
}

class _PemohonNavigationState extends State<PemohonNavigation> {
  int _selectedIndex = 0;
  bool _hasSeenPengajuan = false;

  final List<Widget> _screens = const [
    PemohonDashboardScreen(),
    PermohonanListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final permohonanList = context.watch<DashboardProvider>().pemohonDashboard?.permohonanTerbaru ?? [];
    final hasUpdates = permohonanList.any((p) => p.status != 'draft') && !_hasSeenPengajuan;

    final navItems = [
      CustomNavBarItem(icon: Icons.home_rounded, label: 'Beranda'),
      CustomNavBarItem(icon: Icons.assignment_rounded, label: 'Pengajuan', showBadge: hasUpdates),
      CustomNavBarItem(icon: Icons.person_rounded, label: 'Profil'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ResponsiveLayout(
        mobile: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomCurvedNavigationBar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                    if (index == 1) {
                      _hasSeenPengajuan = true;
                    }
                  });
                },
                items: navItems,
              ),
            ),
          ],
        ),
        desktop: Row(
          children: [
            CustomSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  if (index == 1) {
                    _hasSeenPengajuan = true;
                  }
                });
              },
              items: navItems,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
