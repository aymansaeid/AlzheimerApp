import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  configureDependencies();
  runApp(const AlzheimerApp());
}

class AlzheimerApp extends StatelessWidget {
  const AlzheimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'AlzCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
