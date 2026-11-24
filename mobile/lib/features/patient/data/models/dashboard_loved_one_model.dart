import '../../domain/entities/loved_one.dart';

class DashboardLovedOneModel extends LovedOne {
  const DashboardLovedOneModel({
    required super.followerId,
    required super.fullName,
    required super.phone,
    required super.relationshipType,
    required super.isPrimary,
    required super.joinedAt,
    super.profilePhotoUrl,
  });

  factory DashboardLovedOneModel.fromJson(Map<String, dynamic> json) {
    return DashboardLovedOneModel(
      followerId: (json['followerId'] ?? json['follower_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      relationshipType: (json['relationshipType'] ?? json['relationship_type'] ?? '').toString(),
      isPrimary: json['isPrimary'] == true || json['is_primary'] == true,
      joinedAt: (json['joinedAt'] ?? json['joined_at'] ?? '').toString(),
      profilePhotoUrl: (json['profilePhotoUrl'] ??
              json['profile_photo_url'] ??
              json['avatarUrl'] ??
              json['avatar_url'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followerId': followerId,
      'fullName': fullName,
      'phone': phone,
      'relationshipType': relationshipType,
      'isPrimary': isPrimary,
      'joinedAt': joinedAt,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}
