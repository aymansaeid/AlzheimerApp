import 'package:equatable/equatable.dart';

class MedicineLog extends Equatable {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final int status; // 0=Pending, 1=Taken, 2=Missed
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final String? note;

  const MedicineLog({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.status,
    required this.scheduledAt,
    this.takenAt,
    this.note,
  });

  MedicineLog copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? dosage,
    int? status,
    DateTime? scheduledAt,
    DateTime? takenAt,
    String? note,
  }) {
    return MedicineLog(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      takenAt: takenAt ?? this.takenAt,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        medicineId,
        medicineName,
        dosage,
        status,
        scheduledAt,
        takenAt,
        note,
      ];
}
