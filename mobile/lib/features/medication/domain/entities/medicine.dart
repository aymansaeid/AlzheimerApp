import 'package:equatable/equatable.dart';

class Medicine extends Equatable {
  final String id;
  final String patientId;
  final String creatorId; // ID of the user who created it
  final String name;
  final String dosage;
  final String instructions;
  final String scheduleTime; // e.g., '08:00', '20:00'
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool
  isTaken; // UI specific: Whether the Medicine was taken for the queried date

  const Medicine({
    required this.id,
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
    required this.isTaken,
  });

  Medicine copyWith({
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
    return Medicine(
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

  @override
  List<Object?> get props => [
    id,
    patientId,
    creatorId,
    name,
    dosage,
    instructions,
    scheduleTime,
    daysOfWeek,
    startDate,
    endDate,
    isActive,
    isTaken,
  ];
}
