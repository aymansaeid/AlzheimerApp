import 'package:equatable/equatable.dart';

class NetworkUser extends Equatable {
  final String id;
  final String fullName;
  final String role; // 'patient' or 'caregiver'
  final String avatarUrl; 
  final bool isMe;

  const NetworkUser({
    required this.id,
    required this.fullName,
    required this.role,
    required this.avatarUrl,
    this.isMe = false,
  });

  @override
  List<Object?> get props => [id, fullName, role, avatarUrl, isMe];
}
