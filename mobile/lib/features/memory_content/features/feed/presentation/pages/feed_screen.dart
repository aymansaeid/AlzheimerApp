import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import '../../domain/entities/memory_content.dart';
import '../bloc/memory_bloc.dart';
import '../bloc/memory_event.dart';
import '../bloc/memory_state.dart';
import '../widgets/audio_post_card.dart';
import '../widgets/speed_dial_fab.dart';
import '../widgets/text_post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemories();
    });
  }

  void _loadMemories() {
    String? patientId;
    String currentUserId = '';
    bool isPrimaryAdmin = false;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
      final role = authState.user.role.toLowerCase();
      if (role == 'patient') {
        patientId = authState.user.id;
        isPrimaryAdmin = false;
      } else if (role == 'caregiver' || role == 'follower') {
        try {
          final dashboardState = context.read<DashboardBloc>().state;
          if (dashboardState is DashboardLoaded) {
            patientId = dashboardState.summary.patientId;
            isPrimaryAdmin = dashboardState.isCurrentPatientAdmin;
          }
        } catch (_) {}
      }
    }

    if (patientId != null && patientId.isNotEmpty) {
      context.read<MemoryBloc>().add(
        LoadMemories(
          patientId: patientId,
          currentUserId: currentUserId,
          isPrimaryAdmin: isPrimaryAdmin,
        ),
      );
    }
  }

  void _refreshMemories() {
    String? patientId;
    String currentUserId = '';
    bool isPrimaryAdmin = false;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
      final role = authState.user.role.toLowerCase();
      if (role == 'patient') {
        patientId = authState.user.id;
        isPrimaryAdmin = false;
      } else if (role == 'caregiver' || role == 'follower') {
        try {
          final dashboardState = context.read<DashboardBloc>().state;
          if (dashboardState is DashboardLoaded) {
            patientId = dashboardState.summary.patientId;
            isPrimaryAdmin = dashboardState.isCurrentPatientAdmin;
          }
        } catch (_) {}
      }
    }

    context.read<MemoryBloc>().add(
      RefreshMemories(
        patientId: patientId,
        currentUserId: currentUserId,
        isPrimaryAdmin: isPrimaryAdmin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If MemoryBloc is not in the ancestor tree, provide it
    bool hasMemoryBloc = false;
    try {
      context.read<MemoryBloc>();
      hasMemoryBloc = true;
    } catch (_) {}

    if (!hasMemoryBloc) {
      return BlocProvider(
        create: (_) => getIt<MemoryBloc>(),
        child: Builder(
          builder: (nestedContext) => _buildView(nestedContext),
        ),
      );
    }

    return _buildView(context);
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
      builder: (context, authState) {
        bool isCaregiver = false;
        if (authState is AuthAuthenticated) {
          final role = authState.user.role.toLowerCase();
          isCaregiver = role == 'caregiver' || role == 'follower';
        }

        Widget scaffold = Scaffold(
          appBar: AppBar(
            title: Text(
              isCaregiver ? 'Anılar' : 'Anılarım',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            centerTitle: false,
          ),
          floatingActionButton: !isCaregiver
              ? null
              : SpeedDialFab(
                  onRecordAudioTap: () async {
                    String patientId = '';
                    final memoryState = context.read<MemoryBloc>().state;
                    if (memoryState is MemoryLoaded) {
                      patientId = memoryState.patientId;
                    }
                    if (patientId.isEmpty) {
                      try {
                        final dashboardState =
                            context.read<DashboardBloc>().state;
                        if (dashboardState is DashboardLoaded) {
                          patientId = dashboardState.summary.patientId;
                        }
                      } catch (_) {}
                    }
                    final result = await context.pushNamed(
                      'record-audio',
                      queryParameters: {
                        if (patientId.isNotEmpty) 'patientId': patientId,
                      },
                    );
                    if (result == true && mounted) {
                      _refreshMemories();
                    }
                  },
                  onCreatePostTap: () async {
                    String patientId = '';
                    final memoryState = context.read<MemoryBloc>().state;
                    if (memoryState is MemoryLoaded) {
                      patientId = memoryState.patientId;
                    }
                    if (patientId.isEmpty) {
                      try {
                        final dashboardState =
                            context.read<DashboardBloc>().state;
                        if (dashboardState is DashboardLoaded) {
                          patientId = dashboardState.summary.patientId;
                        }
                      } catch (_) {}
                    }
                    final result = await context.pushNamed(
                      'create-post',
                      queryParameters: {
                        if (patientId.isNotEmpty) 'patientId': patientId,
                      },
                    );
                    if (result == true && mounted) {
                      _refreshMemories();
                    }
                  },
                ),
          body: BlocConsumer<MemoryBloc, MemoryState>(
            listener: (context, state) {
              if (state is MemoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is MemoryOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MemoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MemoryError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadMemories,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is MemoryLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshMemories();
                  },
                  child: state.memories.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Henüz bir anı paylaşılmamış.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80, top: 4),
                          itemCount: state.memories.length,
                          itemBuilder: (context, index) {
                            final memory = state.memories[index];
                            final isOwner =
                                state.currentUserId.isNotEmpty &&
                                memory.uploaderId == state.currentUserId;
                            final canDelete = isOwner || state.isPrimaryAdmin;

                            void onDelete() {
                              context.read<MemoryBloc>().add(
                                DeleteMemory(memory.id),
                              );
                            }

                            if (memory.contentType == MemoryContentType.voice) {
                              return AudioPostCard(
                                memory: memory,
                                canDelete: canDelete,
                                onDelete: onDelete,
                              );
                            }
                            return TextPostCard(
                              memory: memory,
                              canDelete: canDelete,
                              onDelete: onDelete,
                            );
                          },
                        ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );

        // For caregivers, auto-load memories once DashboardBloc finishes loading the selected patient
        if (isCaregiver) {
          return BlocListener<DashboardBloc, DashboardState>(
            listenWhen: (previous, current) {
              if (previous is DashboardLoaded && current is DashboardLoaded) {
                return previous.summary.patientId != current.summary.patientId;
              }
              return current is DashboardLoaded &&
                  (context.read<MemoryBloc>().state is! MemoryLoaded) &&
                  (context.read<MemoryBloc>().state is! MemoryLoading);
            },
            listener: (context, state) {
              if (state is DashboardLoaded) {
                final auth = context.read<AuthBloc>().state;
                final userId = auth is AuthAuthenticated ? auth.user.id : '';
                context.read<MemoryBloc>().add(
                  LoadMemories(
                    patientId: state.summary.patientId,
                    currentUserId: userId,
                    isPrimaryAdmin: state.isCurrentPatientAdmin,
                  ),
                );
              }
            },
            child: scaffold,
          );
        }

        return scaffold;
      },
    );
  }
}
