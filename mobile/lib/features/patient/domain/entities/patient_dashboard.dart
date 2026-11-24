import 'package:equatable/equatable.dart';
import '../../../medication/data/models/medicine_log_model.dart';
import 'loved_one.dart';

class PatientDashboard extends Equatable {
  final String patientName;
  final String? profilePhotoUrl;
  final List<MedicineLogModel> todayMedicines;
  final List<LovedOne> lovedOnes;

  const PatientDashboard({
    required this.patientName,
    this.profilePhotoUrl,
    required this.todayMedicines,
    required this.lovedOnes,
  });

  @override
  List<Object?> get props => [
        patientName,
        profilePhotoUrl,
        todayMedicines,
        lovedOnes,
      ];
}
