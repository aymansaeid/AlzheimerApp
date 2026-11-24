import 'package:equatable/equatable.dart';

/// User entity for profile editing (excludes role information).
class ProfileUser extends Equatable {
  final String fullName;
  final String email;
  final String? phone;
  final String? password;
  final String? avatarUrl;

  const ProfileUser({
    required this.fullName,
    required this.email,
    this.phone,
    this.password,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        password,
        avatarUrl,
      ];
}
