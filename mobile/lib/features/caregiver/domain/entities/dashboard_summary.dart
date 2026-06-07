import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final String patientId;
  final String? patientName;
  final int medsTakenToday;
  final int totalMedsToday;
  final int unreadAlertCount;
  final double? lastLatitude;
  final double? lastLongitude;
  final bool? isCurrentlyOutside;

  const DashboardSummary({
    required this.patientId,
    this.patientName,
    required this.medsTakenToday,
    required this.totalMedsToday,
    required this.unreadAlertCount,
    this.lastLatitude,
    this.lastLongitude,
    this.isCurrentlyOutside,
  });

  bool get isPatientSafe => !(isCurrentlyOutside ?? false);

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        medsTakenToday,
        totalMedsToday,
        unreadAlertCount,
        lastLatitude,
        lastLongitude,
        isCurrentlyOutside,
      ];
}

