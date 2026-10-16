import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
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
  String _selectedRole = 'patient';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: getIt<AuthBloc>(),
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
        builder: (context, state) {
          return AuthLayout(
            title: 'Hesap Oluştur',
            subtitle: 'Sisteme katılmak için bilgilerinizi girin',
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    theme: theme,
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
                  _buildTextField(
                    theme: theme,
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
                  _buildTextField(
                    theme: theme,
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
                  // phone section
                  _buildTextField(
                    theme: theme,
                    label: 'Telefon',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      // we need turkish teleohone number validation
                      if (value == null || value.isEmpty) {
                        return 'Telefon alanı boş bırakılamaz';
                      }
                      // it should start with +90 or 0 and then 10 digits
                      if (!RegExp(r'^(?:\+90|0)?\d{10}$').hasMatch(value)) {
                        return 'Geçerli bir Türkiye telefon numarası giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildRoleSelector(theme),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                AuthRegisterRequested(
                                  fullName: _fullNameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  phone: _phoneController.text,
                                  role: _selectedRole == 'patient' ? 0 : 1,
                                ),
                              );
                            }
                          },
                    child: state is AuthLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                        onPressed: () => context.goNamed('login'),
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
          );
        },
      ),
    );
  }

  Widget _buildRoleSelector(ThemeData theme) {
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
                isSelected: _selectedRole == 'patient',
                onTap: () => setState(() => _selectedRole = 'patient'),
                theme: theme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleCard(
                title: 'Takipçi',
                icon: '👩‍⚕️',
                isSelected: _selectedRole == 'caregiver',
                onTap: () => setState(() => _selectedRole = 'caregiver'),
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 28),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
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
