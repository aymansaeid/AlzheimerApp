import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/feed_repository.dart';

@lazySingleton
class GetFeedUseCase {
  final FeedRepository _feedRepository;
  GetFeedUseCase(this._feedRepository);

  Future<Either<Failure, List<Post>>> execute() async {
    return await _feedRepository.getFeed();
  }
}
