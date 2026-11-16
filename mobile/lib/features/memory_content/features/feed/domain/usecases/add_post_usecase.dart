import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/feed_repository.dart';

@lazySingleton
class AddPostUseCase {
  final FeedRepository repository;

  AddPostUseCase(this.repository);

  Future<Either<Failure, void>> call(Post post) async {
    return await repository.addPost(post);
  }
}
