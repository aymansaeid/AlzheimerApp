import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_picture_options_sheet.dart';
import '../../../../core/widgets/profile_picture_widget.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../cubit/register_cubit.dart';
import '../cubit/register_state.dart';
import '../widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('login');
    }
  }

  Future<void> _onAvatarTap(
    BuildContext context,
    RegisterCubit cubit,
    bool hasPhoto,
  ) async {
    final action = await showProfilePictureOptionsSheet(
      context,
      hasPhoto: hasPhoto,
    );
    if (action == null) return;

    switch (action) {
      case ProfilePictureAction.camera:
        await cubit.pickAvatar(ImageSource.camera);
        break;
      case ProfilePictureAction.gallery:
        await cubit.pickAvatar(ImageSource.gallery);
        break;
      case ProfilePictureAction.remove:
        cubit.removeAvatar();
        break;
    }
  }

  Future<void> _onSubmit(
    BuildContext context,
    RegisterCubit registerCubit,
    RegisterState registerState,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    String? avatarUrl;
    if (registerState.selectedAvatarFile != null) {
      avatarUrl = await registerCubit.uploadAvatarIfSelected();
      if (avatarUrl == null) {
        return;
      }
    }

    if (!context.mounted) return;
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
            role: registerState.selectedRole == 'patient' ? 0 : 1,
            avatarUrl: avatarUrl,
          ),
        );
  }

  void _showPermissionDialog(BuildContext context, String type) {
    final label = type == 'camera' ? 'kamera' : 'galeri';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İzin Gerekli'),
        content: Text(
          'Profil fotoğrafı seçmek için $label izni vermeniz gerekiyor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              getIt<PermissionService>().openSettings();
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<RegisterCubit>()),
      ],
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.user.role == 'patient') {
              if (state.isSetupComplete) {
                context.goNamed('patient_home');
              } else {
                context.goNamed('patient_setup');
              }
            } else {
              if (state.isSetupComplete) {
                context.goNamed('caregiver_dashboard');
              } else {
                context.goNamed('caregiver_setup');
              }
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(color: theme.colorScheme.onError),
                ),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, authState) {
          return BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, registerState) {
              if (registerState.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      registerState.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.onError),
                    ),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
              if (registerState.permissionDeniedType != null) {
                _showPermissionDialog(
                  context,
                  registerState.permissionDeniedType!,
                );
                context.read<RegisterCubit>().clearPermissionWarning();
              }
            },
            builder: (context, registerState) {
              final registerCubit = context.read<RegisterCubit>();
              final isBusy =
                  authState is AuthLoading || registerState.isLoading;

              return PopScope(
                canPop: !isBusy,
                child: AuthLayout(
                  title: 'Hesap Oluştur',
                  subtitle: 'Sisteme katılmak için bilgilerinizi girin',
                  showLogo: false,
                  titleInAppBar: true,
                  onBack: () => _goToLogin(context),
                  isBackEnabled: !isBusy,
                  child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Column(
                          children: [
                            ProfilePictureWidget(
                              imageFile: registerState.selectedAvatarFile,
                              size: 100,
                              showAddBadge:
                                  registerState.selectedAvatarFile == null,
                              isLoading: registerState.isLoading,
                              onTap: () => _onAvatarTap(
                                context,
                                registerCubit,
                                registerState.selectedAvatarFile != null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              registerState.selectedAvatarFile == null
                                  ? 'Profil Fotoğrafı Ekle (İsteğe Bağlı)'
                                  : 'Fotoğrafı Değiştir',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Ad Soyad',
                        icon: Icons.person_outline,
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                        label: 'Şifre',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Şifre alanı boş bırakılamaz';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalıdır';
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
                          if (!RegExp(r'^(?:\+90|0)?\d{10}$').hasMatch(value)) {
                            return 'Geçerli bir Türkiye telefon numarası giriniz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildRoleSelector(
                        theme,
                        registerState.selectedRole,
                        registerCubit,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: isBusy
                            ? null
                            : () => _onSubmit(
                                  context,
                                  registerCubit,
                                  registerState,
                                ),
                        child: isBusy
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Kayıt Ol'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Zaten hesabınız var mı?',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: isBusy ? null : () => _goToLogin(context),
                            child: Text(
                              'Giriş Yap',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoleSelector(
    ThemeData theme,
    String selectedRole,
    RegisterCubit registerCubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rolünüz',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                title: 'Hasta',
                icon: '👴',
                isSelected: selectedRole == 'patient',
                onTap: () => registerCubit.selectRole('patient'),
                theme: theme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleCard(
                title: 'Takipçi',
                icon: '👩‍⚕️',
                isSelected: selectedRole == 'caregiver',
                onTap: () => registerCubit.selectRole('caregiver'),
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
