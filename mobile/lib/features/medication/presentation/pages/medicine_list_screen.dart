import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_state.dart';
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

    final authState = getIt<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.role == 'patient') {
        // Patient — always have their own ID, load immediately
        context.read<MedicineBloc>().add(
          LoadDailyMedicinesEvent(authState.user.id, _selectedDate),
        );
      } else if (authState.user.role == 'caregiver') {
        // Caregiver — only load if dashboard is already ready,
        // otherwise BlocListener in build() will handle it
        try {
          final dashboardState = context.read<DashboardBloc>().state;
          if (dashboardState is DashboardLoaded) {
            context.read<MedicineBloc>().add(
              LoadDailyMedicinesEvent(
                dashboardState.summary.patientId,
                _selectedDate,
              ),
            );
          }
        } catch (_) {}
      }
    }

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
    final authState = getIt<AuthBloc>().state;
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
    // Determine user role
    final authState = getIt<AuthBloc>().state;
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
                  final sortedMedicines = List.from(state.medicines)
                    ..sort((a, b) {
                      if (a.status == 1 && b.status != 1) return 1;
                      if (a.status != 1 && b.status == 1) return -1;
                      return a.scheduledAt.compareTo(b.scheduledAt);
                    });
                  return ListView.builder(
                    itemCount: sortedMedicines.length,
                    itemBuilder: (context, index) {
                      final medication = sortedMedicines[index];
                      return MedicationCard(
                        medication: medication,
                        onTap: () {
                          // Push to detail screen, passing the bloc as extra
                          context.push(
                            '/medication/detail/${medication.id}',
                            extra: context.read<MedicineBloc>(),
                          );
                        },
                        onMarkAsTaken: () {
                          context.read<MedicineBloc>().add(
                            MarkAsTakenEvent(
                              id: medication.id,
                              date: _selectedDate,
                            ),
                          );
                        },
                      );
                    },
                  );
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
      floatingActionButton: isCaregiver
          ? BlocBuilder<MedicineBloc, MedicineState>(
              builder: (context, medicationState) {
                return FloatingActionButton(
                  onPressed: () {
                    String? currentPatientId;

                    if (medicationState is MedicineLoaded) {
                      currentPatientId = medicationState.patientId;
                    }

                    context.push(
                      '/medication/form?patientId=$currentPatientId',
                      extra: context
                          .read<MedicineBloc>(), // Temiz ve tek bir nesne!
                    );
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                );
              },
            )
          : null,
    );

    // For caregivers, wrap with BlocListener to auto-load medications
    // once the DashboardBloc finishes loading the selected patient
    if (isCaregiver) {
      return BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            context.read<MedicineBloc>().add(
              LoadDailyMedicinesEvent(state.summary.patientId, _selectedDate),
            );
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}
