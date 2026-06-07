import '../../domain/entities/care_team_member.dart';

class CareTeamMemberModel extends CareTeamMember {
  const CareTeamMemberModel({
    required super.id,
    required super.fullName,
    required super.role,
    required super.joinedAt,
    super.email,
    super.phoneNumber,
    super.avatarUrl,
    super.relationshipType,
  });

  factory CareTeamMemberModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['joinedAt'] != null || json['joined_at'] != null) {
      try {
        parsedDate = DateTime.parse((json['joinedAt'] ?? json['joined_at']).toString());
      } catch (_) {}
    }

    final isPrimary = json['isPrimary'] == true || json['is_primary'] == true;
    final roleRaw = json['role']?.toString().toLowerCase();
    final String role = (isPrimary || roleRaw == 'admin' || roleRaw == 'primaryadmin' || roleRaw == 'primary_admin')
        ? 'Admin'
        : 'Viewer';

    return CareTeamMemberModel(
      id: (json['followerId'] ??
              json['id'] ??
              json['patientId'] ??
              json['patient_id'] ??
              json['userId'] ??
              '')
          .toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      role: role,
      joinedAt: parsedDate,
      email: json['email']?.toString(),
      phoneNumber: (json['phone'] ?? json['phoneNumber'] ?? json['phone_number'])?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
      relationshipType: (json['relationshipType'] ?? json['relationship_type'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'relationshipType': relationshipType,
    };
  }
}
