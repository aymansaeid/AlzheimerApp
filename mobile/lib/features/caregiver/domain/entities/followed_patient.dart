import 'package:equatable/equatable.dart';

class FollowedPatient extends Equatable {
  final String patientId;
  final String fullName;
  final bool isPrimaryAdmin;
  final DateTime joinedAt;
  final String? profilePhotoUrl;

  const FollowedPatient({
    required this.patientId,
    required this.fullName,
    required this.isPrimaryAdmin,
    required this.joinedAt,
    this.profilePhotoUrl,
  });

  FollowedPatient copyWith({
    String? patientId,
    String? fullName,
    bool? isPrimaryAdmin,
    DateTime? joinedAt,
    String? profilePhotoUrl,
  }) {
    return FollowedPatient(
      patientId: patientId ?? this.patientId,
      fullName: fullName ?? this.fullName,
      isPrimaryAdmin: isPrimaryAdmin ?? this.isPrimaryAdmin,
      joinedAt: joinedAt ?? this.joinedAt,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  @override
  List<Object?> get props => [
        patientId,
        fullName,
        isPrimaryAdmin,
        joinedAt,
        profilePhotoUrl,
      ];
}
