import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/injection.dart';
import '../cubit/create_post_cubit.dart';
import '../cubit/create_post_state.dart';
import '../widgets/permission_denied_dialog.dart';
import '../widgets/post_image_picker_section.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreatePostCubit>(),
      child: const _CreatePostView(),
    );
  }
}

class _CreatePostView extends StatefulWidget {
  const _CreatePostView();

  @override
  State<_CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<_CreatePostView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listenWhen: (prev, current) =>
          prev.status != current.status ||
          prev.permissionDenied != current.permissionDenied,
      listener: (context, state) {
        // İzin reddedildiyse dialog aç
        if (state.permissionDenied) {
          showDialog(
            context: context,
            builder: (_) => PermissionDeniedDialog(
              onOpenSettings: () =>
                  context.read<CreatePostCubit>().openAppSettings(),
            ),
          );
        }

        // Başarılı gönderim
        if (state.status == CreatePostStatus.success) {
          _titleController.clear();
          _contentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gönderi başarıyla paylaşıldı!')),
          );
          context.pop(true); // Feed ekranına geri dön
        }

        // Hata durumu
        if (state.status == CreatePostStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Bir hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == CreatePostStatus.submitting;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Yeni Gönderi'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isSubmitting
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: state.isValid
                            ? () => context.read<CreatePostCubit>().submitPost()
                            : null,
                        child: Text(
                          'Paylaş',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: state.isValid
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  enabled: !isSubmitting,
                  onChanged: (val) =>
                      context.read<CreatePostCubit>().onTitleChanged(val),
                  decoration: const InputDecoration(
                    hintText: 'Başlık (Opsiyonel)',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                TextField(
                  controller: _contentController,
                  enabled: !isSubmitting,
                  maxLines: null,
                  minLines: 4,
                  onChanged: (val) =>
                      context.read<CreatePostCubit>().onContentChanged(val),
                  decoration: const InputDecoration(
                    hintText: 'Neler düşünüyorsun?',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                PostImagePickerSection(
                  selectedImage: state.selectedImage,
                  onPickImage: () =>
                      context.read<CreatePostCubit>().pickImage(),
                  onRemoveImage: () =>
                      context.read<CreatePostCubit>().removeImage(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
