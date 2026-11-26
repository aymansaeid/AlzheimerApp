import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile/features/care_network/presentation/bloc/care_network_bloc.dart';
import 'package:mobile/features/care_network/presentation/bloc/care_network_event.dart';
import 'package:mobile/features/caregiver/domain/entities/followed_patient.dart';
import 'package:mobile/features/caregiver/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile/features/map_viewer/presentation/bloc/tracker_map_bloc.dart';
import 'package:mobile/features/map_viewer/presentation/bloc/tracker_map_event.dart';
import 'package:mobile/features/map_viewer/presentation/bloc/tracker_map_state.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_bloc.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_event.dart';
import 'package:mobile/features/memory_content/features/feed/presentation/bloc/memory_bloc.dart';
import 'package:mobile/features/memory_content/features/feed/presentation/bloc/memory_event.dart';
import 'package:mobile/features/memory_content/features/feed/presentation/bloc/memory_state.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

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
          AppNavItem(icon: Icons.map_rounded, label: 'Konum'),
          AppNavItem(icon: Icons.photo_album_rounded, label: 'Anılar'),
          AppNavItem(icon: Icons.people_rounded, label: 'Ağım'),
          AppNavItem(icon: Icons.person, label: 'Profil'),
        ],
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );

          if (index == 1) {
            String? patientId;
            final dashboardState = context.read<DashboardBloc>().state;
            if (dashboardState is DashboardLoaded) {
              patientId = dashboardState.summary.patientId;
            }
            context.read<MedicineBloc>().add(
              LoadDailyMedicinesEvent(patientId ?? '', DateTime.now()),
            );
          } else if (index == 2) {
            final mapBloc = context.read<TrackerMapBloc>();
            if (mapBloc.state.status == TrackerMapStatus.initial) {
              mapBloc.add(const TrackerMapStarted());
            } else {
              mapBloc.add(const TrackerMapRefreshRequested());
            }
          } else if (index == 3) {
            final dashboardState = context.read<DashboardBloc>().state;
            if (dashboardState is DashboardLoaded) {
              final patientId = dashboardState.summary.patientId;
              final memoryState = context.read<MemoryBloc>().state;
              final needsLoad = memoryState is! MemoryLoading &&
                  (memoryState is! MemoryLoaded ||
                      memoryState.patientId != patientId);
              if (needsLoad && patientId.isNotEmpty) {
                final authState = context.read<AuthBloc>().state;
                final currentUserId =
                    authState is AuthAuthenticated ? authState.user.id : '';
                context.read<MemoryBloc>().add(
                  LoadMemories(
                    patientId: patientId,
                    currentUserId: currentUserId,
                    isPrimaryAdmin: dashboardState.isCurrentPatientAdmin,
                  ),
                );
              }
            }
          } else if (index == 4) {
            final authState = context.read<AuthBloc>().state;
            final currentUserId =
                authState is AuthAuthenticated ? authState.user.id : '';
            final dashboardState = context.read<DashboardBloc>().state;
            List<FollowedPatient> patients = [];
            if (dashboardState is DashboardLoaded) {
              patients = dashboardState.patients;
            } else if (dashboardState is DashboardLoading) {
              patients = dashboardState.patients ?? [];
            } else if (dashboardState is DashboardError) {
              patients = dashboardState.patients ?? [];
            }
            context.read<CareNetworkBloc>().add(
              FetchCareNetwork(currentUserId, patients: patients),
            );
          }
        },
      ),
    );
  }
}
