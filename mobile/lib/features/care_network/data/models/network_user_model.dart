import '../../domain/entities/network_user.dart';

class NetworkUserModel extends NetworkUser {
  const NetworkUserModel({
    required super.id,
    required super.fullName,
    required super.role,
    required super.avatarUrl,
    super.isMe,
  });

  factory NetworkUserModel.fromJson(Map<String, dynamic> json) {
    return NetworkUserModel(
      id: json['id'],
      fullName: json['fullName'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
      isMe: json['isMe'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'role': role,
      'avatarUrl': avatarUrl,
      'isMe': isMe,
    };
  }
}
