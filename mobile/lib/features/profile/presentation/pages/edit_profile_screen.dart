import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/core/widgets/profile_picture_widget.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/profile_update_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_avatar_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _onSave(BuildContext context, User user) {
    if (!_formKey.currentState!.validate()) return;

    final newFullName = _fullNameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newPassword = _newPasswordController.text;
    final currentPassword = _currentPasswordController.text;

    final fullNameChanged = newFullName != user.fullName;
    final emailChanged = newEmail != user.email;
    final phoneChanged = newPhone != (user.phone ?? '');
    final passwordChanged = newPassword.isNotEmpty;

    if (!fullNameChanged &&
        !emailChanged &&
        !phoneChanged &&
        !passwordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Herhangi bir değişiklik yapılmadı.')),
      );
      return;
    }

    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            user: ProfileUpdateEntity(
              fullName: fullNameChanged ? newFullName : null,
              email: emailChanged ? newEmail : null,
              phone: phoneChanged ? newPhone : null,
              currentPassword:
                  (emailChanged || passwordChanged) ? currentPassword : null,
              newPassword: passwordChanged ? newPassword : null,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<ProfileBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profili Düzenle'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return const Center(
                child: Text('Kullanıcı bilgisi bulunamadı.'),
              );
            }

            final user = authState.user;

            return BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, profileState) {
                if (profileState.updatedAvatarUrl != null) {
                  context.read<AuthBloc>().add(
                        AuthUserAvatarUpdated(profileState.updatedAvatarUrl),
                      );
                } else if (profileState.avatarRemoved) {
                  context.read<AuthBloc>().add(
                        const AuthUserAvatarUpdated(null),
                      );
                }

                if (profileState.updatedProfile != null) {
                  final updated = profileState.updatedProfile!;
                  context.read<AuthBloc>().add(
                        AuthUserProfileUpdated(
                          fullName: updated.fullName,
                          email: updated.email,
                          phone: updated.phone,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil bilgileri güncellendi.'),
                    ),
                  );
                  Navigator.of(context).pop(true);
                }

                if (profileState.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        profileState.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.onError),
                      ),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }

                if (profileState.permissionDeniedType != null) {
                  showProfilePermissionDialog(
                    context,
                    profileState.permissionDeniedType!,
                  );
                  context.read<ProfileBloc>().add(
                        const ProfilePermissionWarningCleared(),
                      );
                }
              },
              builder: (context, profileState) {
                final hasPhoto =
                    user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: ProfilePictureWidget(
                            imageUrl: user.avatarUrl,
                            initials: _getInitials(user.fullName),
                            size: 110,
                            showAddBadge: !hasPhoto,
                            isLoading: profileState.isAvatarLoading,
                            onTap: () => handleProfileAvatarTap(
                              context,
                              userId: user.id,
                              currentAvatarUrl: user.avatarUrl,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'Ad Soyad',
                          icon: Icons.person_outline,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ad soyad boş bırakılamaz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'E-posta',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-posta alanı boş bırakılamaz';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value.trim())) {
                              return 'Geçerli bir e-posta adresi giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Telefon (Temizlemek için boş bırakın)',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Güvenlik (E-posta veya şifre değişikliği için)',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Mevcut Şifre',
                          icon: Icons.lock_outline,
                          controller: _currentPasswordController,
                          obscureText: true,
                          validator: (value) {
                            final emailChanged =
                                _emailController.text.trim() != user.email;
                            final passwordChanged =
                                _newPasswordController.text.isNotEmpty;
                            if ((emailChanged || passwordChanged) &&
                                (value == null || value.isEmpty)) {
                              return 'E-posta veya şifre değiştirmek için mevcut şifrenizi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Yeni Şifre (Opsiyonel)',
                          icon: Icons.lock_reset_outlined,
                          controller: _newPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 6) {
                              return 'Yeni şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: profileState.isUpdatingProfile
                              ? null
                              : () => _onSave(context, user),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: profileState.isUpdatingProfile
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Değişiklikleri Kaydet'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
