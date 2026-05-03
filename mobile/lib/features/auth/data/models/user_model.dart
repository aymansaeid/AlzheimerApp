import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    @JsonKey(name: 'full_name') required super.fullName,
    super.phone,
    @JsonKey(name: 'avatar_url') super.avatarUrl,
    @JsonKey(name: 'fcm_token') super.fcmToken,
    @JsonKey(name: 'is_active', defaultValue: true) required super.isActive,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
