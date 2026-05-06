import '../../domain/entities/network_user.dart';

class NetworkUserModel extends NetworkUser {
  const NetworkUserModel({
    required super.id,
    required super.fullName,
    required super.role,
    required super.avatarUrl,
    super.isMe,
    required super.email,
    required super.phoneNumber,
  });

  factory NetworkUserModel.fromJson(Map<String, dynamic> json) {
    return NetworkUserModel(
      id: json['id'],
      fullName: json['fullName'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
      isMe: json['isMe'] ?? false,
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'role': role,
      'avatarUrl': avatarUrl,
      'isMe': isMe,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
