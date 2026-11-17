import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_state.dart' show AuthAuthenticated;
import '../../../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import '../../../feed/domain/entities/memory_content.dart';
import '../../../feed/presentation/bloc/memory_bloc.dart';
import '../../../feed/presentation/bloc/memory_event.dart';
import '../../../feed/presentation/bloc/memory_state.dart';
import '../cubit/create_post_cubit.dart';
import '../cubit/create_post_state.dart';
import '../widgets/permission_denied_dialog.dart';
import '../widgets/post_image_picker_section.dart';

class CreatePostScreen extends StatelessWidget {
  final String? patientId;

  const CreatePostScreen({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    bool hasMemoryBloc = false;
    try {
      context.read<MemoryBloc>();
      hasMemoryBloc = true;
    } catch (_) {}

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CreatePostCubit>()),
        if (!hasMemoryBloc)
          BlocProvider(create: (_) => getIt<MemoryBloc>()),
      ],
      child: _CreatePostView(patientId: patientId),
    );
  }
}

class _CreatePostView extends StatefulWidget {
  final String? patientId;

  const _CreatePostView({this.patientId});

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

  void _submitPost(BuildContext context, CreatePostState postState) {
    if (!postState.isValid) return;

    // 1. Patient ID Çözümleme
    String targetPatientId = widget.patientId ?? '';
    if (targetPatientId.isEmpty) {
      final memoryState = context.read<MemoryBloc>().state;
      if (memoryState is MemoryLoaded && memoryState.patientId.isNotEmpty) {
        targetPatientId = memoryState.patientId;
      }
    }
    if (targetPatientId.isEmpty) {
      try {
        final dashboardState = context.read<DashboardBloc>().state;
        if (dashboardState is DashboardLoaded) {
          targetPatientId = dashboardState.summary.patientId;
        }
      } catch (_) {}
    }
    if (targetPatientId.isEmpty) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        targetPatientId = authState.user.id;
      }
    }

    // 2. Uploader ID ve Yakınlık / İsim Çözümleme
    String uploaderId = '';
    String relationship = 'Yakını';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      uploaderId = authState.user.id;
      if (authState.user.fullName.isNotEmpty) {
        relationship = authState.user.fullName;
      }
    }

    final trimmedTitle = _titleController.text.trim();
    final trimmedContent = _contentController.text.trim();

    // 3. MemoryBloc üzerinden gönderim:
    // Eğer postState.selectedImage null ise Firebase Storage'a yükleme yapılmaz,
    // doğrudan backend'e boş fileUrl ile kayıt gider.
    // Eğer resim varsa yalnızca görsel Firebase Storage'a gider, metinler backend'e gider.
    context.read<MemoryBloc>().add(
      CreateMemory(
        file: postState.selectedImage,
        patientId: targetPatientId,
        contentType: MemoryContentType.photo,
        title: trimmedTitle.isNotEmpty ? trimmedTitle : null,
        description: trimmedContent.isNotEmpty ? trimmedContent : null,
        relationship: relationship,
        uploaderId: uploaderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemoryBloc, MemoryState>(
      listener: (context, memoryState) {
        if (memoryState is MemoryOperationSuccess) {
          _titleController.clear();
          _contentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(memoryState.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // Feed ekranına geri dön
        } else if (memoryState is MemoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(memoryState.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listenWhen: (prev, current) =>
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
        },
        builder: (context, state) {
          final memoryState = context.watch<MemoryBloc>().state;
          final isSubmitting = memoryState is MemoryLoading ||
              (memoryState is MemoryLoaded && memoryState.isActionInProgress);

          final canSubmit = state.isValid && !isSubmitting;

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
                          onPressed: canSubmit
                              ? () => _submitPost(context, state)
                              : null,
                          child: Text(
                            'Paylaş',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: canSubmit
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
                    onPickImage: isSubmitting
                        ? () {}
                        : () => context.read<CreatePostCubit>().pickImage(),
                    onRemoveImage: isSubmitting
                        ? () {}
                        : () => context.read<CreatePostCubit>().removeImage(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
