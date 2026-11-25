import '../../domain/entities/medicine.dart';

class MedicineModel extends Medicine {
  const MedicineModel({
    required super.id,
    required super.patientId,
    required super.name,
    required super.dosage,
    super.instructions,
    required super.scheduleTimes,
    required super.daysOfWeek,
    required super.startDate,
    super.endDate,
    required super.isActive,
  });

  factory MedicineModel.fromEntity(Medicine entity) {
    return MedicineModel(
      id: entity.id,
      patientId: entity.patientId,
      name: entity.name,
      dosage: entity.dosage,
      instructions: entity.instructions,
      scheduleTimes: entity.scheduleTimes,
      daysOfWeek: entity.daysOfWeek,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
    );
  }

  static String _normalizeTime(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(':');
    if (parts.length < 2) return '';
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    final second = parts.length >= 3 ? parts[2].padLeft(2, '0') : '00';
    return '$hour:$minute:$second';
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
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

    final rawTimes = json['scheduleTimes'] ?? json['schedule_times'];
    final List<String> parsedTimes = rawTimes is List
        ? rawTimes
              .map((e) => _normalizeTime(e.toString()))
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    final rawInstructions = json['instructions']?.toString().trim();
    final String? parsedInstructions =
        (rawInstructions == null || rawInstructions.isEmpty)
        ? null
        : rawInstructions;

    return MedicineModel(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      instructions: parsedInstructions,
      scheduleTimes: parsedTimes,
      daysOfWeek: parsedDays,
      startDate: parsedStart,
      endDate: parsedEnd,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  List<String> get _normalizedTimes => scheduleTimes
      .map(_normalizeTime)
      .where((e) => e.isNotEmpty)
      .toList();

  String get _apiDaysOfWeek =>
      daysOfWeek.map((day) => day == 7 ? 0 : day).join(',');

  String get _startUtcIso => DateTime.utc(
    startDate.year,
    startDate.month,
    startDate.day,
  ).toIso8601String();

  String? get _endUtcIso => endDate != null
      ? DateTime.utc(
          endDate!.year,
          endDate!.month,
          endDate!.day,
        ).toIso8601String()
      : null;

  String? get _normalizedInstructions {
    final trimmed = instructions?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'patientId': patientId,
      'name': name,
      'dosage': dosage,
      'instructions': _normalizedInstructions,
      'scheduleTimes': _normalizedTimes,
      'daysOfWeek': _apiDaysOfWeek,
      'startDate': _startUtcIso,
      'endDate': _endUtcIso,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'dosage': dosage,
      'instructions': _normalizedInstructions,
      'scheduleTimes': _normalizedTimes,
      'daysOfWeek': _apiDaysOfWeek,
      'startDate': _startUtcIso,
      'endDate': _endUtcIso,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('temp_') && id.length >= 5) 'id': id,
      'patientId': patientId,
      'name': name,
      'dosage': dosage,
      'instructions': _normalizedInstructions,
      'scheduleTimes': _normalizedTimes,
      'daysOfWeek': _apiDaysOfWeek,
      'startDate': _startUtcIso,
      'endDate': _endUtcIso,
      'isActive': isActive,
    };
  }

  @override
  MedicineModel copyWith({
    String? id,
    String? patientId,
    String? name,
    String? dosage,
    String? instructions,
    bool clearInstructions = false,
    List<String>? scheduleTimes,
    List<int>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isActive,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: clearInstructions
          ? null
          : (instructions ?? this.instructions),
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isActive: isActive ?? this.isActive,
    );
  }
}
