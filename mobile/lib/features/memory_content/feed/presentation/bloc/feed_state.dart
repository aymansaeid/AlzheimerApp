part of 'feed_bloc.dart';

sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object> get props => [];
}

final class FeedInitial extends FeedState {}

final class FeedLoading extends FeedState {}

final class FeedLoaded extends FeedState {
  final List<Post> posts;

  const FeedLoaded(this.posts);

  @override
  List<Object> get props => [posts];
}

final class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object> get props => [message];
}
