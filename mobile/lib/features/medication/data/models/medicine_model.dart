import '../../domain/entities/medicine.dart';

class MedicineModel extends Medicine {
  const MedicineModel({
    required super.id,
    required super.patientId,
    required super.creatorId,
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

  factory MedicineModel.fromEntity(Medicine entity) {
    return MedicineModel(
      id: entity.id,
      patientId: entity.patientId,
      creatorId: entity.creatorId,
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

  factory MedicineModel.fromJson(
    Map<String, dynamic> json, {
    bool isTaken = false,
  }) {
    DateTime parsedStart = DateTime.now();
    final startVal = json['startDate'] ?? json['start_date'];
    if (startVal != null) {
      try {
        parsedStart = DateTime.parse(startVal.toString());
      } catch (_) {}
    }

    DateTime? parsedEnd;
    final endVal = json['endDate'] ?? json['end_date'];
    if (endVal != null) {
      try {
        parsedEnd = DateTime.parse(endVal.toString());
      } catch (_) {}
    }

    final daysOfWeekStr = (json['daysOfWeek'] ?? json['days_of_week'] ?? '')
        .toString();
    final List<int> parsedDays = daysOfWeekStr.isNotEmpty
        ? daysOfWeekStr
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .map((day) => day == 0 ? 7 : day)
              .toList()
        : [];

    String cleanTime = (json['scheduleTime'] ?? json['schedule_time'] ?? '')
        .toString();
    if (cleanTime.length >= 5) {
      cleanTime = cleanTime.substring(0, 5); // Take "HH:MM"
    }

    return MedicineModel(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      creatorId: (json['creatorId'] ?? json['creator_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      instructions: (json['instructions'] ?? '').toString(),
      scheduleTime: cleanTime,
      daysOfWeek: parsedDays,
      startDate: parsedStart,
      endDate: parsedEnd,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isTaken: json['isTaken'] ?? isTaken,
    );
  }

  Map<String, dynamic> toJson() {
    // Ensure scheduleTime format is HH:MM:SS
    String cleanTime = scheduleTime;
    if (cleanTime.split(':').length == 2) {
      cleanTime = '$cleanTime:00'; // Append seconds
    }

    // Sunday (7) mapped to C# Sunday (0), and comma joined
    final daysStr = daysOfWeek.map((day) => day == 7 ? 0 : day).join(',');

    // Represent startDate strictly at midnight UTC
    final startUtcIso = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    ).toIso8601String();
    final endUtcIso = endDate != null
        ? DateTime.utc(
            endDate!.year,
            endDate!.month,
            endDate!.day,
          ).toIso8601String()
        : null;

    return {
      if (id.isNotEmpty && !id.startsWith('temp_') && id.length >= 5) 'id': id,
      'patientId': patientId,
      'creatorId': creatorId,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'scheduleTime': cleanTime,
      'daysOfWeek': daysStr,
      'startDate': startUtcIso,
      'endDate': ?endUtcIso,
      'isActive': isActive,
    };
  }

  @override
  MedicineModel copyWith({
    String? id,
    String? patientId,
    String? creatorId,
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
    return MedicineModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      creatorId: creatorId ?? this.creatorId,
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
