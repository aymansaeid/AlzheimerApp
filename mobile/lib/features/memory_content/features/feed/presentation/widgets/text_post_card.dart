import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';
import 'post_header_widget.dart';

class TextPostCard extends StatelessWidget {
  final Post post;

  const TextPostCard({super.key, required this.post});

  bool _isLocalFile(String path) =>
      !path.startsWith('http://') && !path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final hasTitle = post.title != null && post.title!.trim().isNotEmpty;
    final hasContent = post.content != null && post.content!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeaderWidget(
            userName: post.userName,
            userAvatarUrl: post.userProfileImageUrl,
            createdAt: post.createdAt,
          ),
          if (hasImage) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: SizedBox(
                width: double.infinity,
                child: _isLocalFile(post.imageUrl!)
                    ? Image.file(File(post.imageUrl!), fit: BoxFit.cover)
                    : Image.network(post.imageUrl!, fit: BoxFit.cover),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle) ...[
                  Text(
                    post.title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: hasImage ? 15 : 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (hasContent)
                  Text(
                    post.content!,
                    style: const TextStyle(fontSize: 14, height: 1.3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
