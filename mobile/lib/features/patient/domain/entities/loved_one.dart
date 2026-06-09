import 'package:equatable/equatable.dart';

class LovedOne extends Equatable {
  final String followerId;
  final String fullName;
  final String phone;
  final String relationshipType;
  final bool isPrimary;
  final String joinedAt;

  const LovedOne({
    required this.followerId,
    required this.fullName,
    required this.phone,
    required this.relationshipType,
    required this.isPrimary,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        followerId,
        fullName,
        phone,
        relationshipType,
        isPrimary,
        joinedAt,
      ];
}
