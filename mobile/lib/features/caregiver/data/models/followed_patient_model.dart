import '../../domain/entities/followed_patient.dart';

class FollowedPatientModel extends FollowedPatient {
  const FollowedPatientModel({
    required super.patientId,
    required super.fullName,
    required super.isPrimaryAdmin,
    required super.joinedAt,
    super.profilePhotoUrl,
  });

  factory FollowedPatientModel.fromJson(Map<String, dynamic> json) {
    return FollowedPatientModel(
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      isPrimaryAdmin: json['isPrimaryAdmin'] ?? json['is_primary_admin'] ?? false,
      joinedAt: DateTime.parse((json['joinedAt'] ?? json['joined_at']).toString()),
      profilePhotoUrl: (json['profilePhotoUrl'] ??
              json['profile_photo_url'] ??
              json['avatarUrl'] ??
              json['avatar_url'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'fullName': fullName,
      'isPrimaryAdmin': isPrimaryAdmin,
      'joinedAt': joinedAt.toIso8601String(),
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}
