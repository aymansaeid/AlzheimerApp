import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../medication/data/models/medicine_log_model.dart';
import '../bloc/patient_dashboard_bloc.dart';
import '../widgets/loved_ones_grid.dart';
import '../widgets/patient_medication_card.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PatientDashboardBloc>()..add(const LoadPatientDashboardEvent()),
      child: const PatientDashboardView(),
    );
  }
}

class PatientDashboardView extends StatelessWidget {
  const PatientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PatientDashboardBloc, PatientDashboardState>(
          builder: (context, state) {
            if (state is PatientDashboardLoading ||
                state is PatientDashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientDashboardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PatientDashboardBloc>().add(
                            const LoadPatientDashboardEvent(),
                          );
                        },
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is PatientDashboardLoaded) {
              final dashboard = state.dashboardData;

              // Sorting today's medicines: un-taken first, taken (status == 1) last. Within both, sort by schedule time.
              final sortedMedicines =
                  List<MedicineLogModel>.from(dashboard.todayMedicines)
                    ..sort((a, b) {
                      if (a.status == 1 && b.status != 1) return 1;
                      if (a.status != 1 && b.status == 1) return -1;
                      return a.scheduledAt.compareTo(b.scheduledAt);
                    });

              final now = DateTime.now();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PatientDashboardBloc>().add(
                    LoadPatientDashboardEvent(),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildHeader(theme, dashboard.patientName),
                          const SizedBox(height: 20),
                          _buildSOSButton(theme),
                          const SizedBox(height: 20),
                          const SectionTitle(text: 'Bugünkü İlaçlar'),
                          if (sortedMedicines.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Center(
                                child: Text(
                                  'Bugün için planlanmış ilaç yok.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...sortedMedicines.map((m) {
                              final scheduledLocal = m.scheduledAt.toLocal();
                              final isFuture = scheduledLocal.isAfter(now);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: PatientMedicationCard(
                                  name: m.medicineName,
                                  time: _formatTime(m.scheduledAt),
                                  isTaken: m.status == 1,
                                  isFuture: isFuture,
                                  onMarkAsTaken: () {
                                    context.read<PatientDashboardBloc>().add(
                                      DashboardMedicineTakenEvent(m.id, 1),
                                    );
                                  },
                                ),
                              );
                            }),
                          const SizedBox(height: 20),
                          const SectionTitle(text: 'Sevdiklerin'),
                          if (dashboard.lovedOnes.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Center(
                                child: Text(
                                  'Henüz eklenmiş bir yakınınız yok.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          else
                            LovedOnesGrid(
                              lovedOnes: dashboard.lovedOnes,
                              constraints: constraints,
                              onMemoryPersonTapped: (_) {},
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String patientName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: theme.textTheme.bodyMedium),
              Text(patientName, style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(_getDateString(), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const AvatarCircle(initials: '👴', size: 56),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın,';
    } else if (hour < 18) {
      return 'Tünaydın,';
    } else {
      return 'İyi akşamlar,';
    }
  }

  String _getDateString() {
    final now = DateTime.now();
    try {
      initializeDateFormatting('tr_TR', null);
      final formatter = DateFormat('EEEE, d MMMM yyyy', 'tr_TR');
      return formatter.format(now);
    } catch (_) {
      final formatter = DateFormat('EEEE, d MMMM yyyy');
      return formatter.format(now);
    }
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildSOSButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 2),
          ),
          child: const Center(
            child: Text(
              '!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        label: const Text('Acil Durum'),
      ),
    );
  }
}
