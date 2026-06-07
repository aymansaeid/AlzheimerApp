import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.patientId,
    required super.isPatientSafe,
    required super.todayMedications,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final dynamic isOutside = json['isCurrentlyOutside'] ?? json['is_currently_outside'];
    final bool isSafe = isOutside is bool ? !isOutside : (json['isPatientSafe'] ?? json['is_patient_safe'] ?? true);

    return DashboardSummaryModel(
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      isPatientSafe: isSafe,
      todayMedications: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'patientId': patientId, 'isPatientSafe': isPatientSafe};
  }
}
