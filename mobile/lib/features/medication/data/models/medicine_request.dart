import 'medication_model.dart';

class MedicineRequest {
  final String? id; // for updates
  final String patientId;
  final String creatorId;
  final String name;
  final String dosage;
  final String instructions;
  final String scheduleTime; // HH:MM:SS
  final String daysOfWeek; // "1,2,3"
  final String startDate; // ISO 8601 UTC
  final String? endDate; // ISO 8601 UTC
  final bool isActive;

  MedicineRequest({
    this.id,
    required this.patientId,
    required this.creatorId,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.scheduleTime,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory MedicineRequest.fromDomain(MedicationModel domain) {
    // Convert List<int> [1,2,3] to "1,2,3"
    final daysStr = domain.daysOfWeek.join(',');

    // Ensure scheduleTime format is HH:MM:SS
    String cleanTime = domain.scheduleTime;
    if (cleanTime.split(':').length == 2) {
      cleanTime = '$cleanTime:00'; // Append seconds
    }

    return MedicineRequest(
      id:
          domain.id.isEmpty ||
              domain.id.startsWith('temp_') ||
              domain.id.length < 5
          ? null
          : domain.id,
      patientId: domain.patientId,
      creatorId: domain.creatorId,
      name: domain.name,
      dosage: domain.dosage,
      instructions: domain.instructions,
      scheduleTime: cleanTime,
      daysOfWeek: daysStr,
      startDate: domain.startDate.toUtc().toIso8601String(),
      endDate: domain.endDate?.toUtc().toIso8601String(),
      isActive: domain.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patientId': patientId,
      'creatorId': creatorId,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'scheduleTime': scheduleTime,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'isActive': isActive,
    };
  }
}
