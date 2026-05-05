import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC eklendiğinde kullanılacak
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class PatientLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // IndexedStack otomatik olarak sağlanır
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        items: const [
          AppNavItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
          AppNavItem(icon: Icons.photo_album_rounded, label: 'Anılarım'),
        ],
        onTap: (index) {
          // İlgili sekmeye (branch) geçiş yap
          // initialLocation: true ise aynı sekmeye tekrar tıklandığında o sekmenin ana rotasına döner
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
          
          /* BLoC Veri Tazeleme Örneği:
          if (index == 1) {
             // Anılar sekmesine geçildiğinde veriyi sessizce tazele
             // context.read<MemoryBloc>().add(RefreshMemoriesEvent());
          }
          */
        },
      ),
    );
  }
}
