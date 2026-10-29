import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/custom_curved_navigation_bar.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_sidebar.dart';

import '../dashboard/screens/admin_dashboard_screen.dart';
import '../admin/screens/user_management_screen.dart';
import '../admin/screens/admin_jenis_perizinan_screen.dart';
import '../admin/screens/admin_monitoring_screen.dart';
import '../profile/screens/profile_screen.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    UserManagementScreen(),
    AdminJenisPerizinanScreen(),
    AdminMonitoringScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = [
      CustomNavBarItem(icon: Icons.home_rounded, label: 'Beranda'),
      CustomNavBarItem(icon: Icons.people_rounded, label: 'User'),
      CustomNavBarItem(icon: Icons.business_rounded, label: 'Master'),
      CustomNavBarItem(icon: Icons.analytics_rounded, label: 'Pantau'),
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
