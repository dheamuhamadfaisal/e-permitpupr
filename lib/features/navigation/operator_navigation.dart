import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/custom_curved_navigation_bar.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/custom_sidebar.dart';

import '../dashboard/screens/operator_dashboard_screen.dart';
import '../operator/screens/kelola_informasi_layanan_screen.dart';
import '../operator/screens/upload_berita_screen.dart';
import '../operator/screens/edit_profil_dinas_screen.dart';
import '../profile/screens/profile_screen.dart';

class OperatorNavigation extends StatefulWidget {
  const OperatorNavigation({super.key});

  @override
  State<OperatorNavigation> createState() => _OperatorNavigationState();
}

class _OperatorNavigationState extends State<OperatorNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      OperatorDashboardScreen(
        onNavigateToBerita: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      const KelolaInformasiLayananScreen(),
      const UploadBeritaScreen(),
      const EditProfilDinasScreen(),
      const ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      CustomNavBarItem(icon: Icons.home_rounded, label: 'Beranda'),
      CustomNavBarItem(icon: Icons.info_outline_rounded, label: 'Informasi'),
      CustomNavBarItem(icon: Icons.newspaper_rounded, label: 'Berita'),
      CustomNavBarItem(icon: Icons.business_rounded, label: 'Dinas'),
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
