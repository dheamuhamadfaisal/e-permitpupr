import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/custom_curved_navigation_bar.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_sidebar.dart';

import '../dashboard/screens/petugas_dashboard_screen.dart';
import '../petugas/screens/petugas_permohonan_screen.dart';
import '../petugas/screens/petugas_arsip_screen.dart';
import '../profile/screens/profile_screen.dart';

class PetugasNavigation extends StatefulWidget {
  const PetugasNavigation({super.key});

  @override
  State<PetugasNavigation> createState() => PetugasNavigationState();
}

class PetugasNavigationState extends State<PetugasNavigation> {
  int _selectedIndex = 0;

  void switchTab(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  final List<Widget> _screens = const [
    PetugasDashboardScreen(),
    PetugasPermohonanScreen(),
    PetugasArsipScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = [
      CustomNavBarItem(icon: Icons.home_rounded, label: 'Beranda'),
      CustomNavBarItem(icon: Icons.assignment_rounded, label: 'Tugas'),
      CustomNavBarItem(icon: Icons.archive_rounded, label: 'Arsip'),
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
