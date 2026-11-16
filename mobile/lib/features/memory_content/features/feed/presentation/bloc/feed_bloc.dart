import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/post.dart';
import '../../domain/usecases/add_post_usecase.dart';
import '../../domain/usecases/get_feed_usecase.dart';

part 'feed_event.dart';
part 'feed_state.dart';

@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedUseCase _getFeedUseCase;
  final AddPostUseCase _addPostUseCase;

  FeedBloc(this._getFeedUseCase, this._addPostUseCase) : super(FeedInitial()) {
    on<FeedFetchPostsEvent>(_onFetchPosts);
    on<RefreshFeedPostsEvent>(_onRefreshPosts);
    on<FeedAddPostEvent>(_onAddPostLocally);
  }

  Future<void> _onFetchPosts(
    FeedFetchPostsEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());

    final result = await _getFeedUseCase.execute();

    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (posts) => emit(FeedLoaded(posts)),
    );
  }

  Future<void> _onRefreshPosts(
    RefreshFeedPostsEvent event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());

    final result = await _getFeedUseCase.execute();

    result.fold(
      (failure) => emit(FeedError(failure.message)),
      (posts) => emit(FeedLoaded(posts)),
    );
  }

  Future<void> _onAddPostLocally(
    FeedAddPostEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is FeedLoaded) {
      final Post newPost = event.post;
      // Add the new post to the existing list of posts
      final result = await _addPostUseCase.call(newPost);

      if (result.isLeft()) {
        result.fold((failure) => emit(FeedError(failure.message)), (_) {});
        return;
      }

      final updatedFeedResult = await _getFeedUseCase.execute();

      updatedFeedResult.fold(
        (failure) => emit(FeedError(failure.message)),
        (posts) => emit(FeedLoaded(posts)),
      );
    }
  }
}
