import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/medication/data/models/medicine_model.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../../domain/entities/medicine_log.dart';

class MedicineDetailActionButtons extends StatelessWidget {
  final MedicineLog medication;
  final bool isPatient;
  final bool isFuture;
  final DateTime selectedDate;

  const MedicineDetailActionButtons({
    super.key,
    required this.medication,
    required this.isPatient,
    required this.isFuture,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    if (isPatient) {
      return _buildPatientButton(context);
    } else {
      return _buildCaregiverButtons(context);
    }
  }

  Widget _buildPatientButton(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    if (!isToday) {
      return const SizedBox.shrink();
    }

    final isPending = medication.status == 0;
    final isTaken = medication.status == 1;
    final isMissed = medication.status == 2;
    final canTake = isPending && !isFuture;

    String buttonText = 'İlacımı Aldım';
    if (isTaken) {
      buttonText = 'Zaten Alındı';
    } else if (isMissed) {
      buttonText = 'Kaçırıldı';
    } else if (isFuture) {
      buttonText = 'İlaç Saati Gelmedi';
    }

    return SizedBox(
      width: double.infinity,
      height: 64, // Large, accessible button
      child: ElevatedButton(
        onPressed: canTake
            ? () {
                context.read<MedicineBloc>().add(
                  MarkAsTakenEvent(id: medication.id, date: DateTime.now()),
                );
                context.pop();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purpleAccent,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCaregiverButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (medication.medicineId.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                final state = context.read<MedicineBloc>().state;
                final patientId = state is MedicineLoaded
                    ? state.patientId ?? ''
                    : '';

                Map<String, dynamic>? medicineJson;
                if (state is MedicineLoaded) {
                  try {
                    final match = state.allMedicines.firstWhere((m) => m.id == medication.medicineId);
                    medicineJson = MedicineModel.fromEntity(match).toJson();
                  } catch (_) {}
                }

                context.pushNamed(
                  'caregiver_medication_form',
                  queryParameters: {
                    'id': medication.medicineId,
                    'patientId': patientId,
                    'date': selectedDate.toIso8601String(),
                  },
                  extra: medicineJson,
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
              _showDeleteConfirmation(context);
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

  void _showDeleteConfirmation(BuildContext context) {
    final bloc = context.read<MedicineBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('İlacı Sil'),
        content: const Text(
          'Bu ilacı (ve planlamasını) silmek istediğinize emin misiniz?',
        ),
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
              bloc.add(DeleteMedicineEvent(idToDelete));
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
