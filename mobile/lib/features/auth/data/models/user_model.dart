import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.fullName,
    super.phone,
    super.avatarUrl,
    super.fcmToken,
    required super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String mappedRole = 'patient';
    final roleRaw = json['role'];
    if (roleRaw == 1) {
      mappedRole = 'caregiver';
    } else if (roleRaw == 2) {
      mappedRole = 'admin';
    } else {
      mappedRole = 'patient';
    }

    DateTime parsedDate = DateTime.now();
    final createdAtRaw = json['createdAt'] ?? json['created_at'];

    if (createdAtRaw != null) {
      try {
        parsedDate = DateTime.parse(createdAtRaw.toString());
      } catch (_) {}
    }

    return UserModel(
      id: (json['id']).toString(),
      email: (json['email']).toString(),
      role: mappedRole,
      fullName: (json['fullName']).toString(),
      phone: json['phone'] ?? json['phoneNumber'] ?? json['phone_number'],
      avatarUrl: json['profilePhotoUrl'] ??
          json['profile_photo_url'] ??
          json['avatarUrl'] ??
          json['avatar_url'],
      fcmToken: json['fcmToken'] ?? json['fcm_token'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role == 'patient' ? 0 : (role == 'caregiver' ? 1 : 2),
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'fcmToken': fcmToken,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
