import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_data_source.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  final FeedLocalDataSource _feedLocalDataSource;

  FeedRepositoryImpl(this._feedLocalDataSource);

  @override
  Future<Either<Failure, List<Post>>> getFeed() async {
    try {
      final posts = await _feedLocalDataSource.getFeed();
      return Right(posts);
    } catch (e) {
      // Projenizde tanımlı olan Failure sınıfını (örn. CacheFailure, ServerFailure) dönebilirsiniz
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPost(Post post) async {
    try {
      await _feedLocalDataSource.addPost(post);
      return const Right(null);
    } catch (e) {
      // Projenizde tanımlı olan Failure sınıfını (örn. CacheFailure, ServerFailure) dönebilirsiniz
      return Left(CacheFailure(e.toString()));
    }
  }
}
