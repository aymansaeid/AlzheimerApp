import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/memory_content.dart';
import '../../domain/entities/post.dart';
import 'post_header_widget.dart';

class TextPostCard extends StatelessWidget {
  final MemoryContent memory;
  final bool canDelete;
  final VoidCallback? onDelete;

  const TextPostCard({
    super.key,
    required this.memory,
    this.canDelete = false,
    this.onDelete,
  });

  factory TextPostCard.fromPost({
    Key? key,
    required Post post,
    bool canDelete = false,
    VoidCallback? onDelete,
  }) {
    return TextPostCard(
      key: key,
      memory: MemoryContent(
        id: post.id,
        patientId: '',
        fileUrl: post.imageUrl ?? '',
        title: post.title,
        description: post.content,
        relationship: post.userName,
        contentType: MemoryContentType.photo,
        isActive: true,
        createdAt: post.createdAt.toIso8601String(),
        uploaderId: post.userId,
      ),
      canDelete: canDelete,
      onDelete: onDelete,
    );
  }

  bool _isLocalFile(String path) =>
      !path.startsWith('http://') && !path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final hasImage = memory.fileUrl.isNotEmpty &&
        (memory.contentType == MemoryContentType.photo ||
            memory.contentType == MemoryContentType.identityCard);
    final hasTitle = memory.title != null && memory.title!.trim().isNotEmpty;
    final hasContent =
        memory.description != null && memory.description!.trim().isNotEmpty;
    final createdAt =
        DateTime.tryParse(memory.createdAt) ?? DateTime.now();
    final displayName = memory.relationship.isNotEmpty
        ? memory.relationship
        : 'Yakını';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeaderWidget(
            userName: displayName,
            createdAt: createdAt,
            canDelete: canDelete,
            onDelete: onDelete,
          ),
          if (hasImage) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: SizedBox(
                width: double.infinity,
                child: _isLocalFile(memory.fileUrl)
                    ? Image.file(File(memory.fileUrl), fit: BoxFit.cover)
                    : Image.network(
                        memory.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
          ],
          if (hasTitle || hasContent)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasTitle) ...[
                    Text(
                      memory.title!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: hasImage ? 15 : 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (hasContent)
                    Text(
                      memory.description!,
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
