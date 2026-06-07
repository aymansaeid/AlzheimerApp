import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/medication/presentation/bloc/medication_bloc.dart';
import 'package:mobile/features/medication/presentation/bloc/medication_event.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class PatientLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          navigationShell, // go_router arka planda IndexedStack'i kendi yönetir
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        items: const [
          AppNavItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
          AppNavItem(icon: Icons.medication_rounded, label: 'İlaçlarım'),
          AppNavItem(icon: Icons.photo_album_rounded, label: 'Anılarım'),
          AppNavItem(icon: Icons.person, label: 'Profil'),
        ],
        onTap: (index) {
          // Path'leri bilmemize gerek yok, go_router index'e göre Branch'e (dallanmaya) gider.
          // initialLocation parametresi ile o sekmeye tıklandığında sekmenin ilk haline sıfırlanmasını tetikleriz.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
          if (index == 1) {
            String? patientId;
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              patientId = authState.user.id;
            }
            context.read<MedicationBloc>().add(
              LoadDailyMedications(patientId ?? '', DateTime.now()),
            );
          }
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
