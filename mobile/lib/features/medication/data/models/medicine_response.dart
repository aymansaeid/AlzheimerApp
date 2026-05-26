import 'medication_model.dart';

class MedicineResponse {
  final String id;
  final String patientId;
  final String createdBy;
  final String name;
  final String dosage;
  final String instructions;
  final String scheduleTime; // "HH:MM:SS" or "HH:MM"
  final String daysOfWeek; // "1,2,3,4,5"
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  MedicineResponse({
    required this.id,
    required this.patientId,
    required this.createdBy,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.scheduleTime,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory MedicineResponse.fromJson(Map<String, dynamic> json) {
    DateTime parsedStart = DateTime.now();
    if (json['startDate'] ?? json['start_date'] != null) {
      try {
        parsedStart = DateTime.parse(
          (json['startDate'] ?? json['start_date']).toString(),
        );
      } catch (_) {}
    }

    DateTime? parsedEnd;
    if (json['endDate'] ?? json['end_date'] != null) {
      try {
        parsedEnd = DateTime.parse(
          (json['endDate'] ?? json['end_date']).toString(),
        );
      } catch (_) {}
    }

    return MedicineResponse(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      createdBy: (json['createdBy'] ?? json['created_by'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      instructions: (json['instructions'] ?? '').toString(),
      scheduleTime: (json['scheduleTime'] ?? json['schedule_time'] ?? '')
          .toString(),
      daysOfWeek: (json['daysOfWeek'] ?? json['days_of_week'] ?? '').toString(),
      startDate: parsedStart,
      endDate: parsedEnd,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  // Convert to domain model (MedicationModel)
  MedicationModel toDomainModel({bool isTaken = false}) {
    List<int> parsedDays = [];
    if (daysOfWeek.isNotEmpty) {
      parsedDays = daysOfWeek
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
    }

    String cleanTime = scheduleTime;
    if (scheduleTime.length >= 5) {
      cleanTime = scheduleTime.substring(0, 5); // Take "HH:MM"
    }

    return MedicationModel(
      id: id,
      patientId: patientId,
      createdBy: createdBy,
      name: name,
      dosage: dosage,
      instructions: instructions,
      scheduleTime: cleanTime,
      daysOfWeek: parsedDays,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      isTaken: isTaken,
    );
  }
}
