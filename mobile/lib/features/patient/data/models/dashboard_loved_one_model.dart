class DashboardLovedOneModel {
  final String followerId;
  final String fullName;
  final String phone;
  final String relationshipType;
  final bool isPrimary;
  final String joinedAt;

  const DashboardLovedOneModel({
    required this.followerId,
    required this.fullName,
    required this.phone,
    required this.relationshipType,
    required this.isPrimary,
    required this.joinedAt,
  });

  factory DashboardLovedOneModel.fromJson(Map<String, dynamic> json) {
    return DashboardLovedOneModel(
      followerId: (json['followerId'] ?? json['follower_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      relationshipType: (json['relationshipType'] ?? json['relationship_type'] ?? '').toString(),
      isPrimary: json['isPrimary'] == true || json['is_primary'] == true,
      joinedAt: (json['joinedAt'] ?? json['joined_at'] ?? '').toString(),
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
    };
  }
}
