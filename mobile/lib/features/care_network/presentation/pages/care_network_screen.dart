import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/care_network_bloc.dart';
import '../bloc/care_network_event.dart';
import '../bloc/care_network_state.dart';
import '../../domain/entities/network_user.dart';

class CareNetworkScreen extends StatelessWidget {
  const CareNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareNetworkBloc>()..add(FetchNetworkUsers()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Bağlantılar Ağı')),
        body: BlocBuilder<CareNetworkBloc, CareNetworkState>(
          builder: (context, state) {
            if (state is CareNetworkLoading || state is CareNetworkInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CareNetworkError) {
              return Center(child: Text('Hata: ${state.message}'));
            } else if (state is CareNetworkLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CareNetworkBloc>().add(FetchNetworkUsers());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context,
                        title: 'Takip Ettiğim Hastalar',
                        onAddPressed: () {
                          _showInviteDialog(
                            context,
                            'patient',
                            context.read<CareNetworkBloc>(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildUserList(context, state.patients),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        context,
                        title: 'Diğer Takipçiler',
                        onAddPressed: () {
                          _showInviteDialog(
                            context,
                            'caregiver',
                            context.read<CareNetworkBloc>(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildUserList(context, state.caregivers),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onAddPressed,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        IconButton(
          onPressed: onAddPressed,
          icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildUserList(BuildContext context, List<NetworkUser> users) {
    if (users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Henüz kimse eklenmemiş.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final theme = Theme.of(context);

        return Card(
          elevation: 0,
          color: user.isMe
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: user.isMe
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.avatarUrl,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user.isMe)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ben',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              user.role == 'patient' ? 'Hasta' : 'Takipçi',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              context.pushNamed(
                'user_detail',
                pathParameters: {'id': user.id},
                extra: context.read<CareNetworkBloc>(),
              );
            },
          ),
        );
      },
    );
  }

  void _showInviteDialog(
    BuildContext context,
    String role,
    CareNetworkBloc bloc,
  ) {
    bloc.add(ClearGeneratedLink());
    if (role == 'patient') {
      bloc.add(GeneratePatientInviteLink());
    } else {
      bloc.add(GenerateCaregiverInviteLink());
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<CareNetworkBloc, CareNetworkState>(
                builder: (context, state) {
                  if (state is CareNetworkLoaded) {
                    if (state.isGeneratingLink) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            role == 'patient'
                                ? 'Hasta davet linki oluşturuluyor...'
                                : 'Takipçi davet linki oluşturuluyor...',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    } else if (state.generatedLink != null) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            role == 'patient'
                                ? 'Hasta Daveti'
                                : 'Takipçi Daveti',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bu linki kopyalayıp davet etmek istediğiniz kişiyle paylaşın.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.generatedLink!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Clipboard entegrasyonu (flutter/services.dart gerektirir, şimdilik yorum satırı)
                                    Clipboard.setData(
                                      ClipboardData(text: state.generatedLink!),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Link kopyalandı!'),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.copy,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Kapat'),
                          ),
                        ],
                      );
                    }
                  } else if (state is CareNetworkError) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Hata oluştu: ${state.message}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    );
                  }

                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
