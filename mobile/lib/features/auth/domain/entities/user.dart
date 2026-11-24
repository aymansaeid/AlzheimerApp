import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String role; // 'patient', 'caregiver', 'admin'
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? fcmToken;
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.fcmToken,
    required this.isActive,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? role,
    String? fullName,
    String? phone,
    bool clearPhone = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? fcmToken,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: clearPhone ? null : (phone ?? this.phone),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    fullName,
    phone,
    avatarUrl,
    fcmToken,
    isActive,
    createdAt,
  ];
}
