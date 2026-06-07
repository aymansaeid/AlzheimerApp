import '../../domain/entities/medicine_log.dart';

class MedicineLogModel extends MedicineLog {
  const MedicineLogModel({
    required super.id,
    required super.medicineId,
    required super.medicineName,
    required super.dosage,
    required super.status,
    required super.scheduledAt,
    super.takenAt,
  });

  factory MedicineLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedScheduled = DateTime.now();
    if (json['scheduledAt'] ?? json['scheduled_at'] != null) {
      try {
        parsedScheduled = DateTime.parse(
          (json['scheduledAt'] ?? json['scheduled_at']).toString(),
        );
      } catch (_) {}
    }

    DateTime? parsedTaken;
    if (json['takenAt'] ?? json['taken_at'] != null) {
      try {
        parsedTaken = DateTime.parse(
          (json['takenAt'] ?? json['taken_at']).toString(),
        );
      } catch (_) {}
    }

    return MedicineLogModel(
      id: (json['id'] ?? '').toString(),
      medicineId: (json['medicineId'] ?? json['medicine_id'] ?? json['medicineScheduleId'] ?? '').toString(),
      medicineName: (json['medicineName'] ?? json['medicine_name'] ?? json['name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      status: json['status'] ?? 0,
      scheduledAt: parsedScheduled,
      takenAt: parsedTaken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
      'status': status,
      'scheduledAt': scheduledAt.toIso8601String(),
      'takenAt': takenAt?.toIso8601String(),
    };
  }
}
