import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/section_title.dart';
import '../../../care_network/domain/entities/network_user.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/medication_summary.dart';
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
            }
          },
          builder: (context, state) {
            // Extract patients and select active patient ID dynamically
            List<NetworkUser>? patients;
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
                    _buildHeader(theme, state),
                    const SizedBox(height: 20),

                    // Render dynamic Horizontal Patient Selector if list is available
                    if (patients != null && patients.isNotEmpty) ...[
                      PatientSelector(
                        patients: patients,
                        selectedPatientId: activePatientId ?? patients.first.id,
                        onPatientSelected: (patientId) {
                          // Tap-guard: Ignore selection click if already active or currently loading this patient ID
                          final String currentActive =
                              activePatientId ?? patients!.first.id;
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
                    ] else if (state is DashboardNoPatients)
                      _buildNoPatientsFallback(theme)
                    else if (state is DashboardLoaded) ...[
                      // ADIM 4: Safety Status Widget
                      SafetyStatusCard(
                        isPatientSafe: state.summary.isPatientSafe,
                        patientName: state.patients
                            .firstWhere(
                              (p) =>
                                  p.id ==
                                  (activePatientId ?? state.summary.patientId),
                              orElse: () => state.patients.first,
                            )
                            .fullName,
                      ),
                      const SizedBox(height: 24),
                      // ADIM 4: Bugünkü İlaçlar başlığı
                      const SectionTitle(text: 'Bugünkü İlaçlar'),
                      const SizedBox(height: 12),
                      // ADIM 4: Günlük İlaçlar Özeti (Medication Summary List)
                      MedicationSummary(
                        medications: state.summary.todayMedications,
                      ),
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

  Widget _buildHeader(ThemeData theme, DashboardState state) {
    const String caregiverName = 'Fatma Hanım';

    // Dynamically show notification badge if patient is unsafe
    final bool hasAlerts =
        state is DashboardLoaded && !state.summary.isPatientSafe;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba,', style: theme.textTheme.bodyMedium),
              Text('$caregiverName 👋', style: theme.textTheme.headlineLarge),
            ],
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
                    '1',
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

  Widget _buildNoPatientsFallback(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
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
                  color: theme.colorScheme.primary.withOpacity(0.1),
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
                  // context.pushNamed('add_patient');
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
