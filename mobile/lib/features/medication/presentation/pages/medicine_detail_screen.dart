import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_state.dart';
import 'package:mobile/features/medication/domain/entities/medicine.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import '../../domain/entities/medicine_log.dart';
import '../bloc/medicine_bloc.dart';
import '../widgets/medicine_info_chip.dart';
import '../widgets/medicine_status_info_card.dart';
import '../widgets/medicine_detail_action_buttons.dart';

class MedicineDetailScreen extends StatefulWidget {
  final String medicationId;
  final MedicineLog? initialMedicationLog;

  const MedicineDetailScreen({
    super.key,
    required this.medicationId,
    this.initialMedicationLog,
  });

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  Medicine? _medicine;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
      builder: (context, authState) {
        bool isPatient = false;
        bool isCaregiver = false;
        if (authState is AuthAuthenticated) {
          isPatient = authState.user.role == 'patient';
          isCaregiver = authState.user.role == 'caregiver';
        }

        bool isPrimaryAdmin = false;
        if (isCaregiver) {
          try {
            final dashboardState = context.watch<DashboardBloc>().state;
            isPrimaryAdmin =
                dashboardState is DashboardLoaded &&
                dashboardState.isCurrentPatientAdmin;
          } catch (_) {}
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
                          medicineId: medication.medicineId,
                        ),
                      );
                    }
                  }
                }
              }
            },
            builder: (context, state) {
              MedicineLog? medication;
              if (state is MedicineLoaded) {
                try {
                  medication = state.medicines.firstWhere(
                    (m) => m.id == widget.medicationId,
                  );
                } catch (_) {}
              }
              medication ??= widget.initialMedicationLog;

              if (medication == null) {
                if (state is MedicineLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MedicineLoaded || state is MedicineDetailsLoaded) {
                  return const Center(child: Text('İlaç kaydı bulunamadı.'));
                }
                return const Center(child: Text('Veri bulunamadı.'));
              }

              Medicine? matchedMedicine = _medicine;
              if (matchedMedicine == null && state is MedicineLoaded) {
                matchedMedicine = state.allMedicines
                    .cast<Medicine?>()
                    .firstWhere(
                      (m) => m?.id == medication!.medicineId,
                      orElse: () => null,
                    );
              }

              final scheduledLocal = medication.scheduledAt.toLocal();
              final timeStr = DateFormat('HH:mm').format(scheduledLocal);
              final isFuture = scheduledLocal.isAfter(DateTime.now());

              final selectedDate = state is MedicineLoaded
                  ? state.selectedDate
                  : DateTime.now();

              final instructions =
                  (medication.instructions?.trim().isNotEmpty == true)
                  ? medication.instructions!.trim()
                  : (matchedMedicine?.instructions?.trim().isNotEmpty == true
                        ? matchedMedicine!.instructions!.trim()
                        : null);

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
                              matchedMedicine?.name ?? medication.medicineName,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MedicineInfoChip(
                                  icon: Icons.science,
                                  label: 'Dozaj',
                                  value:
                                      matchedMedicine?.dosage ??
                                      medication.dosage,
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
                            if (instructions != null &&
                                instructions.isNotEmpty) ...[
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Theme.of(context).primaryColor,
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
                                      instructions,
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
                    if (isPatient || isPrimaryAdmin)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: MedicineDetailActionButtons(
                          medication: medication,
                          isPatient: isPatient,
                          isPrimaryAdmin: isPrimaryAdmin,
                          isFuture: isFuture,
                          selectedDate: selectedDate,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
