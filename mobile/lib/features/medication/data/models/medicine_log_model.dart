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
