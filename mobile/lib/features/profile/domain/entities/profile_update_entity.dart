import 'package:equatable/equatable.dart';

/// Entity for partial profile updates via `PUT /api/Users/me`.
///
/// Only non-null fields are sent to the backend.
class ProfileUpdateEntity extends Equatable {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? currentPassword;
  final String? newPassword;
  final String? profilePhotoUrl;

  const ProfileUpdateEntity({
    this.fullName,
    this.email,
    this.phone,
    this.currentPassword,
    this.newPassword,
    this.profilePhotoUrl,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        currentPassword,
        newPassword,
        profilePhotoUrl,
      ];
}
