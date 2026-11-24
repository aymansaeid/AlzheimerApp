import 'package:equatable/equatable.dart';

class LovedOne extends Equatable {
  final String followerId;
  final String fullName;
  final String phone;
  final String relationshipType;
  final bool isPrimary;
  final String joinedAt;
  final String? profilePhotoUrl;

  const LovedOne({
    required this.followerId,
    required this.fullName,
    required this.phone,
    required this.relationshipType,
    required this.isPrimary,
    required this.joinedAt,
    this.profilePhotoUrl,
  });

  @override
  List<Object?> get props => [
        followerId,
        fullName,
        phone,
        relationshipType,
        isPrimary,
        joinedAt,
        profilePhotoUrl,
      ];
}
