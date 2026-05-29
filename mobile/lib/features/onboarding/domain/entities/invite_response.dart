import 'package:equatable/equatable.dart';

class InviteResponse extends Equatable {
  final String inviteCode;
  final String deepLinkUrl;
  final DateTime expiresAt;

  const InviteResponse({
    required this.inviteCode,
    required this.deepLinkUrl,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [inviteCode, deepLinkUrl, expiresAt];
}
