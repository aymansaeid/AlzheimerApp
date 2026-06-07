import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/followed_patient.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/patient_selector.dart';
import '../widgets/safety_status_card.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() =>
      _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  String? _selectedPatientId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardLoaded) {
              setState(() {
                _selectedPatientId = state.summary.patientId;
              });
            } else if (state is DashboardEmptyPatients) {
              context.go('/caregiver_setup');
            }
          },
          builder: (context, state) {
            // Extract patients and select active patient ID dynamically
            List<FollowedPatient>? patients;
            String? activePatientId = _selectedPatientId;

            if (state is DashboardLoaded) {
              patients = state.patients;
              activePatientId = _selectedPatientId ?? state.summary.patientId;
            } else if (state is DashboardLoading) {
              patients = state.patients;
              if (state.loadingPatientId != null) {
                activePatientId = state.loadingPatientId;
              }
            } else if (state is DashboardError) {
              patients = state.patients;
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(
                  LoadDashboard(_selectedPatientId),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Header greetings
                    _buildHeader(context, theme, state),
                    const SizedBox(height: 20),

                    // Render dynamic Horizontal Patient Selector if list is available
                    if (patients != null && patients.isNotEmpty) ...[
                      PatientSelector(
                        patients: patients,
                        selectedPatientId:
                            activePatientId ?? patients.first.patientId,
                        onPatientSelected: (patientId) {
                          // Tap-guard: Ignore selection click if already active or currently loading this patient ID
                          final String currentActive =
                              activePatientId ?? patients!.first.patientId;
                          if (currentActive == patientId) return;

                          setState(() {
                            _selectedPatientId = patientId;
                          });
                          context.read<DashboardBloc>().add(
                            SelectPatient(patientId),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Render conditional dashboard details below patient selector
                    if (state is DashboardLoading) ...[
                      if (patients == null)
                        // Show central spinner only on very first load
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 120.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        // Show a smaller loading indicator under selector when switching patients
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ] else if (state is DashboardNoPatients ||
                        state is DashboardEmptyPatients)
                      _buildNoPatientsFallback(theme)
                    else if (state is DashboardLoaded) ...[
                      // Safety Status Widget
                      SafetyStatusCard(
                        patientName: () {
                          final targetId = activePatientId ?? state.summary.patientId;
                          for (final p in state.patients) {
                            if (p.patientId == targetId) return p.fullName;
                          }
                          return state.patients.isNotEmpty ? state.patients.first.fullName : '';
                        }(),
                      ),
                      const SizedBox(height: 24),
                      // Bugünkü İlaçlar başlığı
                      const SectionTitle(text: 'Günlük İlaç Uyumu'),
                      const SizedBox(height: 12),
                      // Günlük İlaçlar Özeti (Medication Compliance Card)
                      _buildMedicationComplianceCard(context, theme, state.summary),
                    ] else if (state is DashboardError)
                      _buildErrorView(theme, state.message),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DashboardState state) {
    // Dynamically show notification badge if patient has unread alerts
    final bool hasAlerts =
        state is DashboardLoaded && state.summary.unreadAlertCount > 0;
    final int alertCount =
        state is DashboardLoaded ? state.summary.unreadAlertCount : 0;

    return Row(
      children: [
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String caregiverName = 'Bakıcı';
              if (authState is AuthAuthenticated) {
                caregiverName = authState.user.fullName;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Merhaba,', style: theme.textTheme.bodyMedium),
                  Text('$caregiverName 👋', style: theme.textTheme.headlineLarge),
                ],
              );
            },
          ),
        ),
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasAlerts)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$alertCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationComplianceCard(
    BuildContext context,
    ThemeData theme,
    DashboardSummary summary,
  ) {
    final int taken = summary.medsTakenToday;
    final int total = summary.totalMedsToday;
    final double progress = total > 0 ? taken / total : 0.0;

    if (total == 0) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bugün için planlanmış ilaç yok',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İlaç Takip Durumu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bugün alınması gereken tüm ilaçlar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$taken / $total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bugünkü İlaç Uyumu',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '%${(progress * 100).toInt()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.primaryContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (progress == 1.0)
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Harika! Bugünkü tüm ilaçlar alındı.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPatientsFallback(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.supervised_user_circle_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Takip Edilen Hasta Bulunmuyor',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Hastanızın güvenlik durumunu ve bugünkü ilaç uyumunu takip edebilmek için lütfen önce takip ettiğiniz hastalar arasına ekleme yapın.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/caregiver_setup');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Hasta İlişkisi Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(
                  LoadDashboard(_selectedPatientId),
                );
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
