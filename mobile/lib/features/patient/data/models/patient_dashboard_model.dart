import '../../../medication/data/models/medicine_log_model.dart';
import '../../domain/entities/patient_dashboard.dart';
import 'dashboard_loved_one_model.dart';

class PatientDashboardModel extends PatientDashboard {
  const PatientDashboardModel({
    required super.patientName,
    super.profilePhotoUrl,
    required super.todayMedicines,
    required super.lovedOnes,
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
      profilePhotoUrl: (json['profilePhotoUrl'] ??
              json['profile_photo_url'] ??
              json['patientProfilePhotoUrl'] ??
              json['avatarUrl'] ??
              json['avatar_url'])
          ?.toString(),
      todayMedicines: medicinesList,
      lovedOnes: lovedOnesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'profilePhotoUrl': profilePhotoUrl,
      'todayMedicines': todayMedicines.map((e) => e.toJson()).toList(),
      'lovedOnes': lovedOnes.map((e) => (e as DashboardLovedOneModel).toJson()).toList(),
    };
  }
}
