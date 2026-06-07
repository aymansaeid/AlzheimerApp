import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/medicine_log.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';
import '../bloc/medication_state.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String medicationId;

  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context) {
    // Determine role
    final authState = getIt<AuthBloc>().state;
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
      body: BlocBuilder<MedicationBloc, MedicationState>(
        builder: (context, state) {
          if (state is MedicationLoaded) {
            // Find medication log by ID
            final MedicineLog medication;
            try {
              medication = state.medications.firstWhere(
                (m) => m.id == medicationId,
              );
            } catch (_) {
              return const Center(child: Text('İlaç kaydı bulunamadı.'));
            }

            final timeStr = DateFormat('HH:mm').format(medication.scheduledAt);

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
                              _buildInfoChip(
                                context,
                                Icons.science,
                                'Dozaj',
                                medication.dosage,
                              ),
                              _buildInfoChip(
                                context,
                                Icons.access_time,
                                'Saat',
                                timeStr,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Status Info Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
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
                                      'Durum Bilgisi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  medication.status == 0
                                      ? 'İlaç henüz alınmadı. Alındı olarak işaretlemek için aşağıdaki butonu kullanabilirsiniz.'
                                      : medication.status == 1
                                          ? 'İlaç alındı. Alınma zamanı: ${medication.takenAt != null ? DateFormat('HH:mm').format(medication.takenAt!) : '-'}'
                                          : 'İlaç saati geçirildi (Kaçırıldı).',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: isPatient
                        ? _buildPatientButton(
                            context,
                            medication,
                            state.selectedDate,
                          )
                        : _buildCaregiverButtons(context, medication),
                  ),
                ],
              ),
            );
          } else if (state is MedicationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Veri bulunamadı.'));
        },
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientButton(
    BuildContext context,
    MedicineLog medication,
    DateTime selectedDate,
  ) {
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    if (!isToday) {
      return const SizedBox.shrink();
    }

    final isTaken = medication.status == 1;

    return SizedBox(
      width: double.infinity,
      height: 64, // Large, accessible button
      child: ElevatedButton(
        onPressed: isTaken
            ? null
            : () {
                context.read<MedicationBloc>().add(
                  MarkAsTakenEvent(id: medication.id, date: DateTime.now()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('İlaç alındı olarak işaretlendi!'),
                  ),
                );
                context.pop();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purpleAccent,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        child: Text(
          isTaken ? 'Zaten Alındı' : 'İlacımı Aldım',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCaregiverButtons(BuildContext context, MedicineLog medication) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (medication.medicineId.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/medication/form?id=${medication.medicineId}',
                  extra: context.read<MedicationBloc>(),
                );
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Planlamayı Düzenle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: () {
              _showDeleteConfirmation(context, medication);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Planlamayı Sil',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, MedicineLog medication) {
    final bloc = context.read<MedicationBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('İlacı Sil'),
        content: const Text('Bu ilacı (ve planlamasını) silmek istediğinize emin misiniz?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete schedule by using medicineId
              final idToDelete = medication.medicineId.isNotEmpty
                  ? medication.medicineId
                  : medication.id;
              bloc.add(DeleteMedicationEvent(idToDelete));
              Navigator.pop(dialogContext);
              context.pop(); // Go back to list
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
