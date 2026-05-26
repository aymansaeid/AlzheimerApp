import '../../domain/entities/invite_response.dart';

class InviteResponseModel extends InviteResponse {
  const InviteResponseModel({
    required super.inviteCode,
    required super.deepLinkUrl,
    required super.expiresAt,
  });

  factory InviteResponseModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now().add(const Duration(hours: 24));
    if (json['expiresAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['expiresAt'].toString());
      } catch (_) {}
    }
    return InviteResponseModel(
      inviteCode: (json['inviteCode'] ?? json['invite_code'] ?? '').toString(),
      deepLinkUrl: (json['deepLinkUrl'] ?? json['deep_link_url'] ?? '')
          .toString(),
      expiresAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inviteCode': inviteCode,
      'deepLinkUrl': deepLinkUrl,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
