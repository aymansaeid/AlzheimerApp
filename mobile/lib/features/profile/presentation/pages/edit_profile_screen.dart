import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/widgets/app_text_field.dart';
import 'package:mobile/core/widgets/profile_picture_widget.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/profile_user.dart';
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
  final _passwordController = TextEditingController();

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
    _passwordController.dispose();
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

                if (profileState.profileUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil bilgileri güncellendi.'),
                    ),
                  );
                  Navigator.of(context).pop();
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
                              return 'Lütfen ad ve soyadınızı giriniz';
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
                            if (value == null || value.isEmpty) {
                              return 'Bu alan boş bırakılamaz';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Geçerli bir e-posta adresi giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Telefon',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Telefon alanı boş bırakılamaz';
                            }
                            if (!RegExp(r'^(?:\+90|0)?\d{10}$')
                                .hasMatch(value)) {
                              return 'Geçerli bir Türkiye telefon numarası giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Yeni Şifre (Opsiyonel)',
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: profileState.isUpdatingProfile
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final passwordText =
                                        _passwordController.text.trim();
                                    context.read<ProfileBloc>().add(
                                          ProfileUpdateRequested(
                                            user: ProfileUser(
                                              fullName:
                                                  _fullNameController.text
                                                      .trim(),
                                              email:
                                                  _emailController.text.trim(),
                                              phone:
                                                  _phoneController.text.trim(),
                                              password: passwordText.isEmpty
                                                  ? null
                                                  : passwordText,
                                              avatarUrl: user.avatarUrl,
                                            ),
                                          ),
                                        );
                                  }
                                },
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
