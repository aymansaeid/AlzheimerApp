import 'package:equatable/equatable.dart';

class Medicine extends Equatable {
  final String id;
  final String patientId;
  final String name;
  final String dosage;
  final String? instructions;
  final List<String> scheduleTimes; // "HH:mm:ss", TR local time
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const Medicine({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dosage,
    this.instructions,
    required this.scheduleTimes,
    required this.daysOfWeek,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  Medicine copyWith({
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
    return Medicine(
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

  @override
  List<Object?> get props => [
    id,
    patientId,
    name,
    dosage,
    instructions,
    scheduleTimes,
    daysOfWeek,
    startDate,
    endDate,
    isActive,
  ];
}
