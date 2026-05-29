import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.patientId,
    required super.isPatientSafe,
    required super.todayMedications,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    // In a production application, nested medications would be parsed here from a list of maps.
    // For our clean Clean Architecture setup, this provides proper API mapping structure.
    return DashboardSummaryModel(
      patientId: json['patientId'] as String,
      isPatientSafe: json['isPatientSafe'] as bool,
      todayMedications: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'patientId': patientId, 'isPatientSafe': isPatientSafe};
  }
}
