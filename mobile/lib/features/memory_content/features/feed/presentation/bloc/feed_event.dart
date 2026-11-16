part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

final class FeedFetchPostsEvent extends FeedEvent {
  const FeedFetchPostsEvent();

  @override
  List<Object> get props => [];
}

final class RefreshFeedPostsEvent extends FeedEvent {
  const RefreshFeedPostsEvent();

  @override
  List<Object> get props => [];
}

final class FeedAddPostEvent extends FeedEvent {
  final Post post;

  const FeedAddPostEvent(this.post);

  @override
  List<Object> get props => [post];
}
