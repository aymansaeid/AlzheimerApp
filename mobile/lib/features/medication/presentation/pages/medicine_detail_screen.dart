import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_state.dart';
import 'package:mobile/features/medication/data/models/medicine_model.dart';
import 'package:mobile/features/medication/domain/entities/medicine.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medicine_log.dart';
import '../bloc/medicine_bloc.dart';
import '../widgets/medicine_info_chip.dart';
import '../widgets/medicine_status_info_card.dart';
import '../widgets/medicine_detail_action_buttons.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String medicationId;
  final Map<String, dynamic>? initialMedicineJson;

  const MedicineDetailScreen({
    super.key,
    required this.medicationId,
    this.initialMedicineJson,
  });

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  Medicine? _medicine;

  @override
  void initState() {
    super.initState();
    if (widget.initialMedicineJson != null) {
      try {
        _medicine = MedicineModel.fromJson(widget.initialMedicineJson!);
      } catch (e) {
        debugPrint('Error parsing initial medicine json: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
      builder: (context, authState) {
        bool isPatient = false;
        if (authState is AuthAuthenticated) {
          isPatient = authState.user.role == 'patient';
        }

        return Scaffold(
          backgroundColor: Colors.grey[50], // Soft background
          appBar: AppBar(
            title: const Text('İlaç Detayı'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: BlocConsumer<MedicineBloc, MedicineState>(
            listener: (context, state) {
              if (ModalRoute.of(context)?.isCurrent == false) {
                return;
              }
              if (state is MedicineDetailsLoaded) {
                setState(() {
                  _medicine = state.medicine;
                });
              } else if (state is MedicineLoaded) {
                try {
                  final log = state.medicines.firstWhere(
                    (m) => m.id == widget.medicationId,
                  );
                  final match = state.allMedicines.firstWhere(
                    (m) => m.id == log.medicineId,
                  );
                  setState(() {
                    _medicine = match;
                  });
                } catch (_) {
                  if (state.selectedMedicineDetails != null) {
                    setState(() {
                      _medicine = state.selectedMedicineDetails;
                    });
                  } else if (_medicine == null) {
                    final medication = state.medicines
                        .cast<MedicineLog?>()
                        .firstWhere(
                          (m) => m?.id == widget.medicationId,
                          orElse: () => null,
                        );
                    if (medication != null &&
                        medication.medicineId.isNotEmpty) {
                      context.read<MedicineBloc>().add(
                        LoadMedicineDetailsEvent(
                          patientId: state.patientId ?? '',
                          medicineId: medication.medicineId,
                        ),
                      );
                    }
                  }
                }
              }
            },
            builder: (context, state) {
              if (state is MedicineLoaded || state is MedicineDetailsLoaded) {
                // Find medication log by ID
                final List<MedicineLog> medicinesList = state is MedicineLoaded
                    ? state.medicines
                    : [];
                MedicineLog? medication;
                try {
                  medication = medicinesList.firstWhere(
                    (m) => m.id == widget.medicationId,
                  );
                } catch (_) {
                  // Fallback if detail state doesn't have lists yet
                }

                if (medication == null && _medicine != null) {
                  // Reconstruct simple log helper from medicine details if needed
                  final timeParts = _medicine!.scheduleTime.split(':');
                  final hour = timeParts.isNotEmpty
                      ? (int.tryParse(timeParts[0]) ?? 8)
                      : 8;
                  final minute = timeParts.length > 1
                      ? (int.tryParse(timeParts[1]) ?? 0)
                      : 0;
                  medication = MedicineLog(
                    id: _medicine!.id,
                    medicineId: _medicine!.id,
                    medicineName: _medicine!.name,
                    dosage: _medicine!.dosage,
                    status: _medicine!.isTaken ? 1 : 0,
                    scheduledAt: DateTime.now().copyWith(
                      hour: hour,
                      minute: minute,
                    ),
                  );
                }

                if (medication != null && _medicine != null) {
                  try {
                    final timeParts = _medicine!.scheduleTime.split(':');
                    if (timeParts.isNotEmpty) {
                      final hour = int.parse(timeParts[0]);
                      final minute = timeParts.length > 1
                          ? int.parse(timeParts[1])
                          : 0;
                      medication = medication.copyWith(
                        scheduledAt: DateTime(
                          medication.scheduledAt.year,
                          medication.scheduledAt.month,
                          medication.scheduledAt.day,
                          hour,
                          minute,
                        ),
                      );
                    }
                  } catch (_) {}
                }

                if (medication == null) {
                  return const Center(child: Text('İlaç kaydı bulunamadı.'));
                }

                final timeStr = DateFormat(
                  'HH:mm',
                ).format(medication.scheduledAt);

                // Calculate isFuture exactly once
                final scheduledLocal = medication.scheduledAt.toLocal();
                final isFuture = scheduledLocal.isAfter(DateTime.now());

                final selectedDate = state is MedicineLoaded
                    ? state.selectedDate
                    : DateTime.now();

                return SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Large Pill Icon
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.medication,
                                  size: 64,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Name
                              Text(
                                _medicine?.name ?? medication.medicineName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Info Chips
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MedicineInfoChip(
                                    icon: Icons.science,
                                    label: 'Dozaj',
                                    value:
                                        _medicine?.dosage ?? medication.dosage,
                                  ),
                                  MedicineInfoChip(
                                    icon: Icons.access_time,
                                    label: 'Saat',
                                    value: timeStr,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Status Info Card
                              MedicineStatusInfoCard(
                                medication: medication,
                                isFuture: isFuture,
                                isPatient: isPatient,
                              ),

                              // Instructions Card
                              if (_medicine != null &&
                                  _medicine!.instructions.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Kullanım Talimatı',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _medicine!.instructions,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Bottom Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: MedicineDetailActionButtons(
                          medication: medication,
                          isPatient: isPatient,
                          isFuture: isFuture,
                          selectedDate: selectedDate,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is MedicineLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('Veri bulunamadı.'));
            },
          ),
        );
      },
    );
  }
}
