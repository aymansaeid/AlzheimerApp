import 'package:equatable/equatable.dart';

class CareTeamMember extends Equatable {
  final String id;
  final String fullName;
  final String role; // 'Admin', 'Viewer', 'Patient'
  final DateTime joinedAt;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? relationshipType;

  const CareTeamMember({
    required this.id,
    required this.fullName,
    required this.role,
    required this.joinedAt,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.relationshipType,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        role,
        joinedAt,
        email,
        phoneNumber,
        avatarUrl,
        relationshipType,
      ];
}
