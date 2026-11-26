import '../../domain/entities/medicine_log.dart';

class MedicineLogModel extends MedicineLog {
  const MedicineLogModel({
    required super.id,
    required super.medicineId,
    required super.medicineName,
    required super.dosage,
    super.instructions,
    required super.status,
    required super.scheduledAt,
    super.takenAt,
    super.note,
  });

  factory MedicineLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedScheduled = DateTime.now();
    final scheduledVal = json['scheduledAt'] ?? json['scheduled_at'];
    if (scheduledVal != null) {
      try {
        parsedScheduled = DateTime.parse(scheduledVal.toString());
      } catch (_) {}
    }

    DateTime? parsedTaken;
    final takenVal = json['takenAt'] ?? json['taken_at'];
    if (takenVal != null) {
      try {
        parsedTaken = DateTime.parse(takenVal.toString());
      } catch (_) {}
    }

    final rawInstructions = json['instructions']?.toString().trim();
    final String? parsedInstructions =
        (rawInstructions == null || rawInstructions.isEmpty)
        ? null
        : rawInstructions;

    return MedicineLogModel(
      id: (json['id'] ?? '').toString(),
      medicineId: (json['medicineId'] ?? json['medicine_id'] ?? json['medicineScheduleId'] ?? '').toString(),
      medicineName: (json['medicineName'] ?? json['medicine_name'] ?? json['name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      instructions: parsedInstructions,
      status: json['status'] ?? 0,
      scheduledAt: parsedScheduled,
      takenAt: parsedTaken,
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
      'instructions': instructions,
      'status': status,
      'scheduledAt': scheduledAt.toIso8601String(),
      'takenAt': takenAt?.toIso8601String(),
      'note': note,
    };
  }
}
