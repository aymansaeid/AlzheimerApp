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

  @override
  List<Object?> get props => [
        patientId,
        fullName,
        isPrimaryAdmin,
        joinedAt,
        profilePhotoUrl,
      ];
}
