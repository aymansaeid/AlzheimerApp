import 'package:equatable/equatable.dart';

enum PostType { audio, text }

class Post extends Equatable {
  final String id;
  final PostType type;
  final DateTime createdAt;
  final String? title;
  final String? content;
  final String? audioUrl;
  final String? imageUrl;
  final Duration? audioDuration;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;

  const Post({
    required this.id,
    required this.type,
    required this.createdAt,
    this.title,
    this.content,
    this.audioUrl,
    this.imageUrl,
    this.audioDuration,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    createdAt,
    title,
    content,
    audioUrl,
    imageUrl,
    audioDuration,
    userId,
    userName,
    userProfileImageUrl,
  ];
}
