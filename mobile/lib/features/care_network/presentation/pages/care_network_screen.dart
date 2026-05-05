import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        appBar: AppBar(
          title: const Text('Bağlantılar Ağı'),
        ),
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
                        onAddPressed: () {},
                      ),
                      const SizedBox(height: 8),
                      _buildUserList(context, state.patients),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                        context,
                        title: 'Diğer Takipçiler',
                        onAddPressed: () {},
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

  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onAddPressed}) {
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
        child: Text('Henüz kimse eklenmemiş.', style: Theme.of(context).textTheme.bodyMedium),
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
              ? theme.colorScheme.primaryContainer.withOpacity(0.5) 
              : theme.colorScheme.surfaceVariant,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: user.isMe ? theme.colorScheme.primary.withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(user.avatarUrl, style: const TextStyle(fontSize: 24)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            onTap: () {},
          ),
        );
      },
    );
  }
}
