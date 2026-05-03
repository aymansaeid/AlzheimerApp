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
