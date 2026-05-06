import '../../domain/entities/medication.dart';

class MedicationModel extends Medication {
  const MedicationModel({
    required super.id,
    required super.patientId,
    required super.createdBy,
    required super.name,
    required super.dosage,
    required super.instructions,
    required super.scheduleTime,
    required super.daysOfWeek,
    required super.startDate,
    super.endDate,
    required super.isActive,
    required super.isTaken,
  });

  factory MedicationModel.fromEntity(Medication entity) {
    return MedicationModel(
      id: entity.id,
      patientId: entity.patientId,
      createdBy: entity.createdBy,
      name: entity.name,
      dosage: entity.dosage,
      instructions: entity.instructions,
      scheduleTime: entity.scheduleTime,
      daysOfWeek: entity.daysOfWeek,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      isTaken: entity.isTaken,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      patientId: json['patientId'],
      createdBy: json['createdBy'],
      name: json['name'],
      dosage: json['dosage'],
      instructions: json['instructions'],
      scheduleTime: json['scheduleTime'],
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'],
      isTaken: json['isTaken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'createdBy': createdBy,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'scheduleTime': scheduleTime,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'isTaken': isTaken,
    };
  }

  @override
  MedicationModel copyWith({
    String? id,
    String? patientId,
    String? createdBy,
    String? name,
    String? dosage,
    String? instructions,
    String? scheduleTime,
    List<int>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isTaken,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
