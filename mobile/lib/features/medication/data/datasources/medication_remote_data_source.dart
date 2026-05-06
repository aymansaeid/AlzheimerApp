import 'package:injectable/injectable.dart';

import '../../domain/entities/medication.dart';

abstract class MedicationRemoteDataSource {
  Future<List<Medication>> getMedicationsByDate(
    String patientId,
    DateTime date,
  );
  Future<Medication> addMedication(Medication medication);
  Future<Medication> updateMedication(Medication medication);
  Future<void> deleteMedication(String id);
  Future<void> markAsTaken(String id, DateTime date);
}

@LazySingleton(as: MedicationRemoteDataSource)
class MockMedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final List<Medication> _mockMedications = [
    Medication(
      id: '1',
      patientId: 'patient_1',
      createdBy: 'caregiver_1',
      name: 'Donepezil',
      dosage: '10 mg',
      instructions: 'Take after dinner',
      scheduleTime: '20:00',
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      isActive: true,
      isTaken: false,
    ),
    Medication(
      id: '2',
      patientId: 'patient_1',
      createdBy: 'caregiver_1',
      name: 'Memantine',
      dosage: '5 mg',
      instructions: 'Take with breakfast',
      scheduleTime: '08:00',
      daysOfWeek: [1, 2, 5, 6, 7],
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      isActive: true,
      isTaken: false, // Default false, mock state holds actual state
    ),
  ];

  // Map of medicationId to a set of date strings ('YYYY-MM-DD')
  final Map<String, Set<String>> _takenDates = {
    '2': {
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
    },
  };

  @override
  Future<List<Medication>> getMedicationsByDate(
    String patientId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    // Normalize date to ignore time for comparison
    final queryDate = DateTime(date.year, date.month, date.day);

    return _mockMedications
        .where((m) {
          if (!m.isActive) return false;
          if (!m.daysOfWeek.contains(date.weekday)) return false;

          final start = DateTime(
            m.startDate.year,
            m.startDate.month,
            m.startDate.day,
          );
          if (queryDate.isBefore(start)) return false;

          if (m.endDate != null) {
            final end = DateTime(
              m.endDate!.year,
              m.endDate!.month,
              m.endDate!.day,
            );
            if (queryDate.isAfter(end)) return false;
          }

          return true;
        })
        .map((m) {
          final dateStr =
              '${queryDate.year}-${queryDate.month}-${queryDate.day}';
          final isTaken = _takenDates[m.id]?.contains(dateStr) ?? false;
          return m.copyWith(isTaken: isTaken);
        })
        .toList();
  }

  @override
  Future<Medication> addMedication(Medication medication) async {
    await Future.delayed(const Duration(seconds: 1));
    final newMedication = medication.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _mockMedications.add(newMedication);
    return newMedication;
  }

  @override
  Future<Medication> updateMedication(Medication medication) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockMedications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _mockMedications[index] = medication;
      return medication;
    }
    throw Exception('Medication not found');
  }

  @override
  Future<void> deleteMedication(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockMedications.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> markAsTaken(String id, DateTime date) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockMedications.indexWhere((m) => m.id == id);
    if (index != -1) {
      final dateStr = '${date.year}-${date.month}-${date.day}';
      _takenDates.putIfAbsent(id, () => {}).add(dateStr);
    } else {
      throw Exception('Medication not found');
    }
  }
}
