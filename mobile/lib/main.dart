import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/caregiver/caregiver_dashboard_screen.dart';
import 'package:mobile/features/caregiver/geofence_alert_screen.dart';
import 'package:mobile/features/patient/memory_module_screen.dart';
import 'package:mobile/features/patient/patient_home_screen.dart';
import 'core/app_theme.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AlzheimerApp());
}

class AlzheimerApp extends StatelessWidget {
  const AlzheimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alzheimer Takip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DevPreviewScreen(), // Replace with real auth flow
      routes: {
        '/patient/home': (_) => const PatientHomeScreen(),
        '/patient/memory': (_) => const MemoryModuleScreen(),
        '/caregiver/dashboard': (_) => const CaregiverDashboardScreen(),
        '/caregiver/geofence-alert': (_) => const GeofenceAlertScreen(),
      },
    );
  }
}

// ─── Dev Preview — remove in production ──────────────────────────────────────
class DevPreviewScreen extends StatelessWidget {
  const DevPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal400,
                      borderRadius: AppRadius.md,
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AlzheimerTakip',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Geliştirici Önizlemesi',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _SectionHeader(title: 'Hasta Ekranları'),
              const SizedBox(height: 12),
              _PreviewButton(
                label: 'Hasta Ana Ekranı',
                subtitle: 'İlaçlar, SOS, Sevdikler',
                emoji: '🏠',
                color: AppColors.teal50,
                onTap: () => Navigator.pushNamed(context, '/patient/home'),
              ),
              const SizedBox(height: 8),
              _PreviewButton(
                label: 'Bellek Modülü',
                subtitle: 'Fotoğraf, sesli mesaj, kişisel kart',
                emoji: '💝',
                color: AppColors.teal50,
                onTap: () => Navigator.pushNamed(context, '/patient/memory'),
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: 'Takipçi Ekranları'),
              const SizedBox(height: 12),
              _PreviewButton(
                label: 'Takipçi Paneli',
                subtitle: 'Konum, ilaç uyumu, aktiviteler',
                emoji: '📊',
                color: AppColors.blue50,
                onTap: () =>
                    Navigator.pushNamed(context, '/caregiver/dashboard'),
              ),
              const SizedBox(height: 8),
              _PreviewButton(
                label: 'Geofence Uyarısı',
                subtitle: 'Alan dışı alarm ekranı',
                emoji: '🚨',
                color: AppColors.coral50,
                onTap: () =>
                    Navigator.pushNamed(context, '/caregiver/geofence-alert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _PreviewButton({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
