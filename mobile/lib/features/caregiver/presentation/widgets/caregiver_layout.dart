import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class CaregiverLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CaregiverLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        items: const [
          AppNavItem(icon: Icons.dashboard_rounded, label: 'Özet'),
          AppNavItem(icon: Icons.medication_rounded, label: 'İlaçlar'),
          AppNavItem(icon: Icons.warning_rounded, label: 'Uyarılar'),
          AppNavItem(icon: Icons.people_rounded, label: 'Ağım'),
        ],
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
