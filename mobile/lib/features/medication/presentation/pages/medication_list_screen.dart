import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';
import '../widgets/medication_card.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
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
        context.read<MedicationBloc>().add(
          LoadMedications(_selectedDate, patientId: authState.user.id),
        );
      } else if (authState.user.role == 'caregiver') {
        // Caregiver — only load if dashboard is already ready,
        // otherwise BlocListener in build() will handle it
        try {
          final dashboardState = context.read<DashboardBloc>().state;
          if (dashboardState is DashboardLoaded) {
            context.read<MedicationBloc>().add(
              LoadMedications(
                _selectedDate,
                patientId: dashboardState.summary.patientId,
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

  /// Resolves the patientId from available state and dispatches LoadMedications.
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
    context.read<MedicationBloc>().add(
      LoadMedications(date, patientId: patientId),
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
        title: const Text('İlaçlarım'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildDateScroller(),
          const SizedBox(height: 16),
          Expanded(
            child: BlocConsumer<MedicationBloc, MedicationState>(
              listener: (context, state) {
                if (state is MedicationLoaded) {
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
                } else if (state is MedicationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is MedicationOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is MedicationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MedicationLoaded) {
                  if (state.medications.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    itemCount: state.medications.length,
                    itemBuilder: (context, index) {
                      final medication = state.medications[index];
                      return MedicationCard(
                        medication: medication,
                        onTap: () {
                          // Push to detail screen, passing the bloc as extra
                          context.push(
                            '/medication/detail/${medication.id}',
                            extra: context.read<MedicationBloc>(),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('Bir hata oluştu.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isCaregiver
          ? BlocBuilder<MedicationBloc, MedicationState>(
              builder: (context, medicationState) {
                return FloatingActionButton(
                  onPressed: () {
                    String? currentPatientId;

                    if (medicationState is MedicationLoaded) {
                      currentPatientId = medicationState.patientId;
                    }

                    context.push(
                      '/medication/form?patientId=$currentPatientId',
                      extra: context
                          .read<MedicationBloc>(), // Temiz ve tek bir nesne!
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
            context.read<MedicationBloc>().add(
              LoadMedications(
                _selectedDate,
                patientId: state.summary.patientId,
              ),
            );
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildDateScroller() {
    // Generate a list of dates: 15 days before and 15 days after today
    final today = DateTime.now();
    final dates = List.generate(
      31,
      (index) => today.subtract(Duration(days: 15 - index)),
    );

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTurkishDayName(date.weekday),
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Seçili günde alınacak ilaç yok.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getTurkishDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }
}
