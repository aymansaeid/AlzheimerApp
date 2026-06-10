import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/medication/presentation/bloc/medicine_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medicine_log.dart';
import '../bloc/medicine_bloc.dart';
import '../widgets/medicine_info_chip.dart';
import '../widgets/medicine_status_info_card.dart';
import '../widgets/medicine_detail_action_buttons.dart';

class MedicineDetailScreen extends StatelessWidget {
  final String medicationId;

  const MedicineDetailScreen({super.key, required this.medicationId});

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
          body: BlocBuilder<MedicineBloc, MedicineState>(
            builder: (context, state) {
              if (state is MedicineLoaded) {
                // Find medication log by ID
                final MedicineLog medication;
                try {
                  medication = state.medicines.firstWhere(
                    (m) => m.id == medicationId,
                  );
                } catch (_) {
                  return const Center(child: Text('İlaç kaydı bulunamadı.'));
                }

                final timeStr = DateFormat('HH:mm').format(medication.scheduledAt);

                // Calculate isFuture exactly once
                final scheduledLocal = medication.scheduledAt.toLocal();
                final isFuture = scheduledLocal.isAfter(DateTime.now());

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
                                      color: Colors.black.withValues(alpha: 0.05),
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
                                medication.medicineName,
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
                                    value: medication.dosage,
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
                          selectedDate: state.selectedDate,
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
