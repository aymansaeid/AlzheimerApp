import '../../../medication/data/models/medicine_log_model.dart';
import 'dashboard_loved_one_model.dart';

class PatientDashboardModel {
  final String patientName;
  final List<MedicineLogModel> todayMedicines;
  final List<DashboardLovedOneModel> lovedOnes;

  const PatientDashboardModel({
    required this.patientName,
    required this.todayMedicines,
    required this.lovedOnes,
  });

  factory PatientDashboardModel.fromJson(Map<String, dynamic> json) {
    final todayMedicinesJson = json['todayMedicines'] ?? json['today_medicines'];
    final lovedOnesJson = json['lovedOnes'] ?? json['loved_ones'];

    final medicinesList = todayMedicinesJson is List
        ? todayMedicinesJson
            .map((e) => MedicineLogModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <MedicineLogModel>[];

    final lovedOnesList = lovedOnesJson is List
        ? lovedOnesJson
            .map((e) => DashboardLovedOneModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <DashboardLovedOneModel>[];

    return PatientDashboardModel(
      patientName: (json['patientName'] ?? json['patient_name'] ?? '').toString(),
      todayMedicines: medicinesList,
      lovedOnes: lovedOnesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'todayMedicines': todayMedicines.map((e) => e.toJson()).toList(),
      'lovedOnes': lovedOnes.map((e) => e.toJson()).toList(),
    };
  }
}
