import 'package:equatable/equatable.dart';
import '../../../medication/domain/entities/medication.dart';

class DashboardSummary extends Equatable {
  final String patientId;
  final bool isPatientSafe;
  final List<Medication> todayMedications;

  const DashboardSummary({
    required this.patientId,
    required this.isPatientSafe,
    required this.todayMedications,
  });

  @override
  List<Object?> get props => [patientId, isPatientSafe, todayMedications];
}
