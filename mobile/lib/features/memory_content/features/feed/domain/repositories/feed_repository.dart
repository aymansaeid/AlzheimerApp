import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<Post>>> getFeed();
  Future<Either<Failure, void>> addPost(Post post);
}
