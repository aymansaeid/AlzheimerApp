import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/features/auth/presentation/pages/register_screen.dart';
import 'package:mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/features/caregiver/presentation/pages/caregiver_dashboard_screen.dart';
import 'package:mobile/features/caregiver/presentation/widgets/caregiver_layout.dart';
import 'package:mobile/features/geofence/presentation/pages/geofence_alert_screen.dart';
import 'package:mobile/features/memory/presentation/pages/memory_module_screen.dart';
import 'package:mobile/features/patient/presentation/pages/patient_dashboard_screen.dart';
import 'package:mobile/features/patient/presentation/widgets/patient_layout.dart';
import 'package:mobile/features/care_network/presentation/pages/care_network_screen.dart';
import 'package:mobile/features/care_network/presentation/pages/user_detail_screen.dart';
import 'package:mobile/features/medication/presentation/pages/medicine_list_screen.dart';
import 'package:mobile/features/medication/presentation/pages/medicine_detail_screen.dart';
import 'package:mobile/features/medication/presentation/pages/medicine_form_screen.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_bloc.dart';
import 'package:mobile/features/caregiver/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile/features/onboarding/presentation/pages/patient_setup_screen.dart';
import 'package:mobile/features/onboarding/presentation/pages/caregiver_setup_screen.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/router/go_router_refresh_stream.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';

import '../../features/care_network/presentation/bloc/care_network_bloc.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = getIt<AuthBloc>().state;
    final isGoingToLogin =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (authState is AuthUnauthenticated && !isGoingToLogin) {
      return '/login';
    }

    if (authState is AuthAuthenticated) {
      final isAtAuthPage =
          isGoingToLogin ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/';
      if (isAtAuthPage) {
        if (authState.user.role == 'patient') {
          return authState.isSetupComplete ? '/patient/home' : '/patient_setup';
        } else {
          return authState.isSetupComplete
              ? '/caregiver/dashboard'
              : '/caregiver_setup';
        }
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/patient_setup',
      name: 'patient_setup',
      builder: (context, state) => const PatientSetupScreen(),
    ),
    GoRoute(
      path: '/caregiver_setup',
      name: 'caregiver_setup',
      builder: (context, state) => const CaregiverSetupScreen(),
    ),

    // Patient StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<MedicineBloc>())],
        child: PatientLayout(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patient/home',
              name: 'patient_home',
              builder: (context, state) => const PatientDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patient/medications',
              name: 'patient_medications',
              builder: (context, state) => const MedicineListScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  name: 'patient_medication_detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final initialMedicineJson =
                        state.extra as Map<String, dynamic>?;
                    return MedicineDetailScreen(
                      medicationId: id,
                      initialMedicineJson: initialMedicineJson,
                    );
                  },
                ),
                GoRoute(
                  path: 'form',
                  name: 'patient_medication_form',
                  builder: (context, state) {
                    final id = state.uri.queryParameters['id'];
                    final authState = context.read<AuthBloc>().state;
                    final patientId = authState is AuthAuthenticated
                        ? authState.user.id
                        : '';
                    final initialMedicineJson =
                        state.extra as Map<String, dynamic>?;
                    return MedicineFormScreen(
                      medicationId: id,
                      patientId: patientId,
                      initialMedicineJson: initialMedicineJson,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patient/memory',
              name: 'patient_memory',
              builder: (context, state) =>
                  MemoryModuleScreen(onAddMemory: () {}),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patient_profile',
              name: 'patient_profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Caregiver StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              // key is needed to prevent bloc from being recreated when switching between branches
              key: ValueKey('medicineBloc'),
              create: (_) => getIt<MedicineBloc>(),
            ),
            BlocProvider(
              create: (_) =>
                  getIt<DashboardBloc>()..add(const LoadDashboard(null)),
            ),
            BlocProvider(create: (_) => getIt<CareNetworkBloc>()),
          ],
          child: CaregiverLayout(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/caregiver/dashboard',
              name: 'caregiver_dashboard',
              builder: (context, state) => CaregiverDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/caregiver/medications',
              name: 'caregiver_medications',
              builder: (context, state) => const MedicineListScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  name: 'caregiver_medication_detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final initialMedicineJson =
                        state.extra as Map<String, dynamic>?;
                    return MedicineDetailScreen(
                      medicationId: id,
                      initialMedicineJson: initialMedicineJson,
                    );
                  },
                ),
                GoRoute(
                  path: 'form',
                  name: 'caregiver_medication_form',
                  builder: (context, state) {
                    final id = state.uri.queryParameters['id'];
                    final patientId =
                        state.uri.queryParameters['patientId'] ?? '';
                    final initialMedicineJson =
                        state.extra as Map<String, dynamic>?;
                    return MedicineFormScreen(
                      medicationId: id,
                      patientId: patientId,
                      initialMedicineJson: initialMedicineJson,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/caregiver/alerts',
              name: 'caregiver_alerts',
              builder: (context, state) => GeofenceAlertScreen(
                patientName: 'Ahmet Bey',
                locationAddress: 'Kadıköy',
                distanceMeters: 50,
                timeOutside: '5 dk',
                onDismissAlert: () {},
                onCallPatient: () {},
                onOpenLiveMap: () {},
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/caregiver/network',
              name: 'caregiver_network',
              builder: (context, state) => const CareNetworkScreen(),
              routes: [
                GoRoute(
                  path: 'user/:id',
                  name: 'user_detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final patientId = state.uri.queryParameters['patientId'];
                    return UserDetailScreen(userId: id, patientId: patientId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/caregiver_profile',
              name: 'caregiver_profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
