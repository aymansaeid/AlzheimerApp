import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/memory_content/features/create_audio_post/presentation/pages/record_audio_screen.dart';
import '../../features/memory_content/features/create_text_post/presentation/pages/create_post_screen.dart';
import '../../features/memory_content/features/feed/presentation/pages/feed_screen.dart';
import 'go_router_refresh_stream.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/caregiver/presentation/pages/caregiver_dashboard_screen.dart';
import '../../features/caregiver/presentation/widgets/caregiver_layout.dart';
import '../../features/patient/presentation/pages/patient_dashboard_screen.dart';
import '../../features/patient/presentation/widgets/patient_layout.dart';
import '../../features/care_network/presentation/pages/care_network_screen.dart';
import '../../features/care_network/presentation/pages/user_detail_screen.dart';
import '../../features/medication/presentation/pages/medicine_list_screen.dart';
import '../../features/medication/presentation/pages/medicine_detail_screen.dart';
import '../../features/medication/presentation/pages/medicine_form_screen.dart';
import '../../features/medication/presentation/bloc/medicine_bloc.dart';
import '../../features/memory_content/features/feed/presentation/bloc/memory_bloc.dart';
import '../../features/caregiver/presentation/bloc/dashboard_bloc.dart';
import '../../features/onboarding/presentation/pages/patient_setup_screen.dart';
import '../../features/onboarding/presentation/pages/caregiver_setup_screen.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/care_network/presentation/bloc/care_network_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(getIt<AuthBloc>().stream),
  redirect: (context, state) {
    final authState = getIt<AuthBloc>().state;
    final currentLocation = state.matchedLocation;
    final isAtAuthPage =
        currentLocation == '/login' || currentLocation == '/register';

    // 1. While controling (AuthInitial, AuthLoading)
    // Token is being checked or state of token is getting from backend
    // User must be in the /splash screen
    if (authState is AuthInitial || authState is AuthLoading) {
      return currentLocation == '/splash' ? null : '/splash';
    }

    // 2. The login failed or getted an error
    // (AuthError or AuthUnauthenticated)
    if (authState is AuthUnauthenticated || authState is AuthError) {
      // is it already at the login page? If yes, do not redirect
      // if not redirect to the login page
      return isAtAuthPage ? null : '/login';
    }

    // 3. The token is valid and user is authenticated
    if (authState is AuthAuthenticated) {
      // if the user is in the login or register page, or splash page,
      // redirect to the appropriate dashboard based on the user's role
      final shouldRedirectToHome =
          isAtAuthPage ||
          currentLocation == '/splash' ||
          currentLocation == '/';

      if (shouldRedirectToHome) {
        if (authState.user.role == 'patient') {
          return authState.isSetupComplete ? '/patient/home' : '/patient_setup';
        } else {
          return authState.isSetupComplete
              ? '/caregiver/dashboard'
              : '/caregiver_setup';
        }
      }
    }

    // 4. If none of the above conditions are met, do not redirect
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
        providers: [
          BlocProvider(create: (_) => getIt<MedicineBloc>()),
          BlocProvider(create: (_) => getIt<MemoryBloc>()),
        ],
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
              builder: (context, state) => FeedScreen(),
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
              key: ValueKey('memoryBloc'),
              create: (_) => getIt<MemoryBloc>(),
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
              path: '/caregiver/memory',
              name: 'caregiver_memory',
              builder: (context, state) => FeedScreen(),
              routes: [
                // Feed üzerinde açılan Metin/Görsel paylaşım ekranı
                GoRoute(
                  path: 'create-post',
                  name: 'create-post',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const CreatePostScreen(),
                ),
                // Feed üzerinde açılan ses kayıt ekranı
                GoRoute(
                  path: 'record-audio',
                  name: 'record-audio',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const RecordAudioScreen(),
                ),
              ],
            ),
          ],
        ),

        // MAP SCREEN
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: '/caregiver/alerts',
        //       name: 'caregiver_alerts',
        //       builder: (context, state) => GeofenceAlertScreen(
        //         patientName: 'Ahmet Bey',
        //         locationAddress: 'Kadıköy',
        //         distanceMeters: 50,
        //         timeOutside: '5 dk',
        //         onDismissAlert: () {},
        //         onCallPatient: () {},
        //         onOpenLiveMap: () {},
        //       ),
        //     ),
        //   ],
        // ),
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
