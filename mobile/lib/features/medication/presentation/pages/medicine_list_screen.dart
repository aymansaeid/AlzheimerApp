import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/medication/domain/entities/medicine.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_state.dart';
import 'package:mobile/features/medication/data/models/medicine_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../widgets/medication_card.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/medicine_empty_state.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    //   final authState = context.read<AuthBloc>().state;
    //   if (authState is AuthAuthenticated) {
    //     if (authState.user.role == 'patient') {
    //       // Patient — always have their own ID, load immediately
    //       context.read<MedicineBloc>().add(
    //         LoadDailyMedicinesEvent(
    //           authState.user.id,
    //           _selectedDate,
    //           loadMedicinesList: true,
    //         ),
    //       );
    //     } else if (authState.user.role == 'caregiver') {
    //       // Caregiver — only load if dashboard is already ready,
    //       // otherwise BlocListener in build() will handle it
    //       try {
    //         final dashboardState = context.read<DashboardBloc>().state;
    //         if (dashboardState is DashboardLoaded) {
    //           context.read<MedicineBloc>().add(
    //             LoadDailyMedicinesEvent(
    //               dashboardState.summary.patientId,
    //               _selectedDate,
    //               loadMedicinesList: true,
    //             ),
    //           );
    //         }
    //       } catch (_) {}
    //     }
    //   }

    // Jump to center roughly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(15 * 60.0); // Rough center of 30 days
      }
    });
  }

  /// Resolves the patientId from available state and dispatches LoadDailyMedications.
  void _loadMedicationsForDate(DateTime date) {
    String? patientId;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.role == 'patient') {
        patientId = authState.user.id;
      } else if (authState.user.role == 'caregiver') {
        try {
          final dashboardState = context.read<DashboardBloc>().state;
          if (dashboardState is DashboardLoaded) {
            patientId = dashboardState.summary.patientId;
          }
        } catch (_) {}
      }
    }
    context.read<MedicineBloc>().add(
      LoadDailyMedicinesEvent(patientId ?? '', date),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadMedicationsForDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
      builder: (context, authState) {
        bool isCaregiver = false;
        if (authState is AuthAuthenticated) {
          isCaregiver = authState.user.role == 'caregiver';
        }

        Widget scaffold = Scaffold(
          appBar: AppBar(
            title: Text(isCaregiver ? 'İlaçlar' : 'İlaçlarım'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          body: Column(
            children: [
              DateSelectorBar(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                scrollController: _scrollController,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<MedicineBloc, MedicineState>(
                  listener: (context, state) {
                    if (state is MedicineLoaded) {
                      // Sync local date state if it was updated from outside (e.g. Nav bar tap)
                      if (_selectedDate.year != state.selectedDate.year ||
                          _selectedDate.month != state.selectedDate.month ||
                          _selectedDate.day != state.selectedDate.day) {
                        setState(() {
                          _selectedDate = state.selectedDate;
                        });

                        // Attempt to scroll back to center (today) if needed
                        final today = DateTime.now();
                        if (state.selectedDate.year == today.year &&
                            state.selectedDate.month == today.month &&
                            state.selectedDate.day == today.day) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              15 * 60.0, // center index (15) * item width (60)
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      }
                    } else if (state is MedicineError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is MedicineOperationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is MedicineLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MedicineLoaded) {
                      if (state.medicines.isEmpty) {
                        return const MedicineEmptyState();
                      }
                      return _buildListBuilder(state, isCaregiver);
                    } else if (state is MedicineError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const Center(child: Text('Bir hata oluştu.'));
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: !isCaregiver
              ? null
              : Builder(
                  builder: (context) {
                    final state = context.watch<DashboardBloc>().state;

                    final isAdmin =
                        state is DashboardLoaded && state.isCurrentPatientAdmin;

                    if (!isAdmin) return const SizedBox.shrink();

                    return FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        final currentPatientId = state.summary.patientId;
                        final result = await context.pushNamed<bool>(
                          'caregiver_medication_form',
                          queryParameters: {
                            'patientId': currentPatientId,
                            'date': _selectedDate.toIso8601String(),
                          },
                        );
                        if (result == true && context.mounted) {
                          _loadMedicationsForDate(_selectedDate);
                        }
                      },
                    );
                  },
                ),
        );

        // For caregivers, wrap with BlocListener to auto-load medications
        // once the DashboardBloc finishes loading the selected patient
        if (isCaregiver) {
          return BlocListener<DashboardBloc, DashboardState>(
            listenWhen: (previous, current) {
              if (previous is DashboardLoaded && current is DashboardLoaded) {
                return previous.summary.patientId != current.summary.patientId;
              }
              // Only trigger if previous was not loaded AND we don't have medicines loaded/loading already
              return current is DashboardLoaded &&
                  (context.read<MedicineBloc>().state is! MedicineLoaded) &&
                  (context.read<MedicineBloc>().state is! MedicineLoading);
            },
            listener: (context, state) {
              if (state is DashboardLoaded) {
                context.read<MedicineBloc>().add(
                  LoadDailyMedicinesEvent(
                    state.summary.patientId,
                    _selectedDate,
                    loadMedicinesList: true,
                  ),
                );
              }
            },
            child: scaffold,
          );
        }

        return scaffold;
      },
    );
  }

  Widget _buildListBuilder(MedicineLoaded state, bool isCaregiver) {
    final sortedMedicines = List.from(state.medicines)
      ..sort((a, b) {
        if (a.status == 1 && b.status != 1) return 1;
        if (a.status != 1 && b.status == 1) return -1;
        return a.scheduledAt.compareTo(b.scheduledAt);
      });

    return ListView.builder(
      itemCount: sortedMedicines.length,
      itemBuilder: (context, index) {
        final medicationLog = sortedMedicines[index];

        // Find matching medicine configuration to get updated name and dosage
        Medicine? match;
        try {
          match = state.allMedicines.firstWhere(
            (m) => m.id == medicationLog.medicineId,
          );
        } catch (_) {}

        DateTime updatedScheduledAt = medicationLog.scheduledAt;
        if (match != null) {
          try {
            final timeParts = match.scheduleTime.split(':');
            if (timeParts.isNotEmpty) {
              final hour = int.parse(timeParts[0]);
              final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
              updatedScheduledAt = DateTime(
                medicationLog.scheduledAt.year,
                medicationLog.scheduledAt.month,
                medicationLog.scheduledAt.day,
                hour,
                minute,
              );
            }
          } catch (_) {}
        }

        final medication = match != null
            ? medicationLog.copyWith(
                medicineName: match.name,
                dosage: match.dosage,
                scheduledAt: updatedScheduledAt,
              )
            : medicationLog;

        return MedicationCard(
          medication: medication,
          isPatient: !isCaregiver,
          onTap: () async {
            // Push to detail screen
            final routeName = isCaregiver
                ? 'caregiver_medication_detail'
                : 'patient_medication_detail';
            final patientId = state.patientId ?? '';

            Map<String, dynamic>? medicineJson;
            if (match != null) {
              medicineJson = MedicineModel.fromEntity(match).toJson();
            }

            final result = await context.pushNamed<bool>(
              routeName,
              pathParameters: {'id': medication.id},
              queryParameters: {
                if (isCaregiver) 'patientId': patientId,
                'date': _selectedDate.toIso8601String(),
              },
              extra: medicineJson,
            );
            if (result == true && context.mounted) {
              _loadMedicationsForDate(_selectedDate);
            }
          },
          onMarkAsTaken: () {
            context.read<MedicineBloc>().add(
              MarkAsTakenEvent(id: medication.id, date: _selectedDate),
            );
          },
        );
      },
    );
  }
}
