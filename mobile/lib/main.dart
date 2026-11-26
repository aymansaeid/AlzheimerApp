import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/location_tracking/data/services/location_bg_service.dart';
import 'features/notifications/data/datasources/notification_local_data_source.dart';
import 'features/notifications/service/notification_service.dart';
import 'features/notifications/presentation/widgets/notification_permission_guard.dart';
import 'firebase_options.dart';

// Arka planda bildirimleri yakalayan fonksiyon
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Arka plandayken gelen safezone alert'leri sistem tarafından otomatik push banner olarak gösterilir
  debugPrint('Arka plan bildirimi: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  configureDependencies();

  await getIt<NotificationLocalDataSource>().init();
  await LocationBgService.initializeService();
  await getIt<NotificationService>().initialize();

  getIt<AuthBloc>().add(AuthCheckRequested());

  runApp(const AlzheimerApp());
}

class AlzheimerApp extends StatelessWidget {
  const AlzheimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'AlzCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        builder: (context, child) {
          return NotificationPermissionGuard(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
