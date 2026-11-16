import 'dart:io';

import 'package:flutter/material.dart';

class PostImagePickerSection extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final bool isPickingImage;

  const PostImagePickerSection({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
    this.isPickingImage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedImage != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              radius: 16,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: onRemoveImage,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: isPickingImage ? null : onPickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Text(
              'Fotoğraf Ekle (Opsiyonel)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
