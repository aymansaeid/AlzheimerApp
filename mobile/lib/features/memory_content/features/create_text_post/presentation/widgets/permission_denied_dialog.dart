import 'package:flutter/material.dart';

class PermissionDeniedDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const PermissionDeniedDialog({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Galeri İzni Gerekli'),
      content: const Text(
        'Gönderinize fotoğraf ekleyebilmek için uygulamanın galeriye erişim iznine ihtiyacı var. Ayarlardan izni açabilirsiniz.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onOpenSettings();
          },
          child: const Text('Ayarlara Git'),
        ),
      ],
    );
  }
}
