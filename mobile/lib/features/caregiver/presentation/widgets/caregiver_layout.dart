import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC eklendiğinde kullanılacak
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class CaregiverLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CaregiverLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // IndexedStack otomatik olarak sağlanır
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        items: const [
          // Panel, Konum, İlaçlar, Anılar, Ağım (Bu yorumu düzelttim: Panel, Uyarılar, Ağım)
          AppNavItem(icon: Icons.dashboard_rounded, label: 'Panel'),
          AppNavItem(icon: Icons.warning_rounded, label: 'Uyarılar'),
          AppNavItem(icon: Icons.people_rounded, label: 'Ağım'),
        ],
        onTap: (index) {
          // İlgili sekmeye (branch) geçiş yap
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );

          /* BLoC Veri Tazeleme Örneği:
          if (index == 0) {
             // Panel sekmesine dönüldüğünde hastanın anlık bilgisini tazele
             // context.read<CaregiverDashboardBloc>().add(RefreshDashboardEvent());
          }
          */
        },
      ),
    );
  }
}
