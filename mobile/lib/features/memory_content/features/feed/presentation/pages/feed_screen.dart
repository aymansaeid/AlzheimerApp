import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/injection.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/audio_post_card.dart';
import '../widgets/speed_dial_fab.dart';
import '../widgets/text_post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeedBloc>()..add(const FeedFetchPostsEvent()),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: SpeedDialFab(
        onRecordAudioTap: () async {
          final result = await context.pushNamed('record-audio');
          if (result == true && context.mounted) {
            context.read<FeedBloc>().add(const RefreshFeedPostsEvent());
          }
        },
        onCreatePostTap: () async {
          final result = await context.pushNamed('create-post');
          if (result == true && context.mounted) {
            context.read<FeedBloc>().add(const RefreshFeedPostsEvent());
          }
        },
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeedError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<FeedBloc>().add(
                      const FeedFetchPostsEvent(),
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (state is FeedLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text('Henüz paylaşım yapılmamış.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(const RefreshFeedPostsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 4),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  if (post.type == PostType.audio) {
                    return AudioPostCard(post: post);
                  }
                  return TextPostCard(post: post);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
