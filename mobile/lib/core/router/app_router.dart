import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/features/auth/presentation/pages/register_screen.dart';
import 'package:mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:mobile/features/caregiver/presentation/pages/caregiver_dashboard_screen.dart';
import 'package:mobile/features/patient/presentation/pages/patient_home_screen.dart';

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
    GoRoute(
      path: '/patient-dashboard',
      name: 'patient_dashboard',
      builder: (context, state) => PatientHomeScreen(
        onTabTapped: (_) {},
        onSosPressed: () {},
        onMedicationTaken: (_) {},
        onMemoryPersonTapped: (_) {},
      ),
    ),
    GoRoute(
      path: '/caregiver-dashboard',
      name: 'caregiver_dashboard',
      builder: (context, state) => CaregiverDashboardScreen(
        onTabTapped: (_) {},
        onRefresh: () {},
        onOpenMap: () {},
      ),
    ),
  ],
);
