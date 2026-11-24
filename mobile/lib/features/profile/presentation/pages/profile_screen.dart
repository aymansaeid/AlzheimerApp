import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/widgets/profile_picture_widget.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_avatar_handler.dart';
import '../widgets/profile_info_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _resetScrollToTop() {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.jumpTo(0);
    }
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
          title: const Text('Profil'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthLoading ||
                authState is AuthUnauthenticated ||
                authState is AuthInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (authState is AuthAuthenticated) {
              final user = authState.user;
              final initials = _getInitials(user.fullName);
              final hasPhoto =
                  user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

              return BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, profileState) {
                  if (profileState.updatedAvatarUrl != null) {
                    context.read<AuthBloc>().add(
                          AuthUserAvatarUpdated(
                            profileState.updatedAvatarUrl,
                          ),
                        );
                  } else if (profileState.avatarRemoved) {
                    context.read<AuthBloc>().add(
                          const AuthUserAvatarUpdated(null),
                        );
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
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: ProfilePictureWidget(
                            imageUrl: user.avatarUrl,
                            initials: initials,
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
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: user.role == 'patient'
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role == 'patient' ? 'Hasta' : 'Takipçi',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: user.role == 'patient'
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ProfileInfoCard(user: user),
                        const SizedBox(height: 32),
                        ProfileActionButtons(
                          onEditProfile: () {
                            Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute<bool>(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                )
                                .then((updated) {
                              if (updated == true) {
                                _resetScrollToTop();
                              }
                            });
                          },
                          onLogout: () {
                            context
                                .read<AuthBloc>()
                                .add(AuthLogoutRequested());
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text('Kullanıcı bilgisi yüklenemedi.'),
            );
          },
        ),
      ),
    );
  }
}
