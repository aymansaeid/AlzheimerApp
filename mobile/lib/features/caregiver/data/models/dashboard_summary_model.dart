import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.patientId,
    super.patientName,
    required super.medsTakenToday,
    required super.totalMedsToday,
    required super.unreadAlertCount,
    super.lastLatitude,
    super.lastLongitude,
    super.isCurrentlyOutside,
    super.batteryLevel,
    super.isCharging,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      patientName: json['patientName'] ?? json['patient_name'],
      medsTakenToday: json['medsTakenToday'] ?? json['meds_taken_today'] ?? 0,
      totalMedsToday: json['totalMedsToday'] ?? json['total_meds_today'] ?? 0,
      unreadAlertCount:
          json['unreadAlertCount'] ?? json['unread_alert_count'] ?? 0,
      lastLatitude: json['lastLatitude'] != null
          ? (json['lastLatitude'] as num).toDouble()
          : null,
      lastLongitude: json['lastLongitude'] != null
          ? (json['lastLongitude'] as num).toDouble()
          : null,
      isCurrentlyOutside:
          json['isCurrentlyOutside'] ?? json['is_currently_outside'],
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      isCharging: json['isCharging'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'medsTakenToday': medsTakenToday,
      'totalMedsToday': totalMedsToday,
      'unreadAlertCount': unreadAlertCount,
      'lastLatitude': lastLatitude,
      'lastLongitude': lastLongitude,
      'isCurrentlyOutside': isCurrentlyOutside,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
    };
  }
}
