import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/features/auth/presentation/pages/register_screen.dart';
import 'package:mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:mobile/features/caregiver/presentation/pages/caregiver_dashboard_screen.dart';
import 'package:mobile/features/caregiver/presentation/widgets/caregiver_layout.dart';
import 'package:mobile/features/geofence/presentation/pages/geofence_alert_screen.dart';
import 'package:mobile/features/memory/presentation/pages/memory_module_screen.dart';
import 'package:mobile/features/patient/presentation/pages/patient_home_screen.dart';
import 'package:mobile/features/patient/presentation/widgets/patient_layout.dart';
import 'package:mobile/features/care_network/presentation/pages/care_network_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
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
    // Patient StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => PatientLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patient/home',
              name: 'patient_home',
              builder: (context, state) => PatientHomeScreen(
                onSosPressed: () {},
                onMedicationTaken: (_) {},
                onMemoryPersonTapped: (_) {},
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/patient/memory',
              name: 'patient_memory',
              builder: (context, state) => MemoryModuleScreen(
                onAddMemory: () {},
              ),
            ),
          ],
        ),
      ],
    ),
    // Caregiver StatefulShellRoute
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => CaregiverLayout(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/caregiver/dashboard',
              name: 'caregiver_dashboard',
              builder: (context, state) => CaregiverDashboardScreen(
                onRefresh: () {},
                onOpenMap: () {},
              ),
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
            ),
          ],
        ),
      ],
    ),
  ],
);
