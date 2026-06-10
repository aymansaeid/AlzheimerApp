import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/care_network_bloc.dart';
import '../bloc/care_network_event.dart';
import '../bloc/care_network_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/user_detail_card.dart';

class UserDetailScreen extends StatelessWidget {
  final String userId;
  final String? patientId;

  const UserDetailScreen({super.key, required this.userId, this.patientId});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final bloc = extra?['bloc'] as CareNetworkBloc?;
    return Scaffold(
      appBar: AppBar(title: const Text('Bağlantı Detayı')),
      body: BlocBuilder<CareNetworkBloc, CareNetworkState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is CareNetworkLoaded) {
            // Find user specifically in the team of patientId
            final targetTeam =
                (patientId != null && state.patientTeams.containsKey(patientId))
                ? state.patientTeams[patientId]!
                : state.patientTeams.values.expand((team) => team).toList();

            final userIndex = targetTeam.indexWhere((u) => u.id == userId);

            if (userIndex == -1) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kullanıcı bulunamadı veya ağdan çıkarıldı.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            final user = targetTeam[userIndex];
            final theme = Theme.of(context);

            // Find patient ID for this user
            String? resolvedPatientId = patientId;
            if (resolvedPatientId == null) {
              for (final entry in state.patientTeams.entries) {
                if (entry.value.any((u) => u.id == userId)) {
                  resolvedPatientId = entry.key;
                  break;
                }
              }
            }
            final bool isCurrentUserAdmin =
                resolvedPatientId != null &&
                (state.isAdminForPatient[resolvedPatientId] ?? false);

            // Resolve isMe dynamically
            final authState = context.read<AuthBloc>().state;
            final bool isMe =
                authState is AuthAuthenticated && authState.user.id == user.id;

            return SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UserDetailCard(user: user, isMe: isMe),
                      const Spacer(),
                      if (!isMe && isCurrentUserAdmin) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _showTransferAdminConfirmDialog(
                              context,
                              resolvedPatientId!,
                              user.fullName,
                            ),
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text(
                              'Yönetici Yap',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _showRemoveDialog(
                              context,
                              resolvedPatientId!,
                              user.fullName,
                            ),
                            child: const Text(
                              'Bağlantıyı Kes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    String patientId,
    String fullName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Emin misiniz?'),
          content: Text(
            '$fullName adlı kullanıcıyı ağınızdan çıkarmak istediğinize emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Hayır',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                context.read<CareNetworkBloc>().add(
                  RemoveMemberClicked(patientId: patientId, followerId: userId),
                );
                context.pop(); // Go back to network list
              },
              child: Text(
                'Evet, Çıkar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTransferAdminConfirmDialog(
    BuildContext context,
    String patientId,
    String newAdminName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Emin misiniz?'),
          content: const Text(
            'Yöneticilik yetkilerini devrederseniz, bu hastanın ayarlarını bir daha değiştiremezsiniz ve kimseyi takımdan çıkaramazsınız.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                context.read<CareNetworkBloc>().add(
                  TransferAdminClicked(
                    patientId: patientId,
                    newAdminId: userId,
                  ),
                );
                context.pop(); // Go back to network list
              },
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }
}
