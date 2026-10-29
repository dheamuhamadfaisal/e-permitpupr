import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/custom_curved_navigation_bar.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_sidebar.dart';

import '../dashboard/screens/verifikator_dashboard_screen.dart';
import '../verifikator/screens/verifikasi_list_screen.dart';
import '../profile/screens/profile_screen.dart';

class VerifikatorNavigation extends StatefulWidget {
  const VerifikatorNavigation({super.key});

  @override
  State<VerifikatorNavigation> createState() => _VerifikatorNavigationState();
}

class _VerifikatorNavigationState extends State<VerifikatorNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    VerifikatorDashboardScreen(),
    VerifikasiListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = [
      CustomNavBarItem(icon: Icons.home_rounded, label: 'Beranda'),
      CustomNavBarItem(icon: Icons.gavel_rounded, label: 'Verifikasi'),
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
