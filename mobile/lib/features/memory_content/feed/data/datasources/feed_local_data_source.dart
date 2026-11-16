import 'package:injectable/injectable.dart';

import '../../domain/entities/post.dart';

abstract class FeedLocalDataSource {
  Future<List<Post>> getFeed();
  Future<void> addPost(Post post);
}

@LazySingleton(as: FeedLocalDataSource)
class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  final List<Post> _posts = [
    Post(
      id: '1',
      type: PostType.text,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      title: 'İlk Gönderi',
      content: 'Clean architecture ile tasarladığımız feed akışı hazır!',
      imageUrl: 'https://picsum.photos/600/400',
      userId: 'user_1',
      userName: 'Ekrem',
    ),
  ];

  @override
  Future<List<Post>> getFeed() async {
    // Gerçekçi bir ağ/yükleme hissi için kısa bir gecikme
    await Future.delayed(const Duration(milliseconds: 400));
    // Referans yerine kopyasını dönerek immutability koruyoruz
    return List<Post>.from(_posts);
  }

  @override
  Future<void> addPost(Post post) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Yeni eklenen postun en üstte görünmesi için başa ekliyoruz
    _posts.insert(0, post);
  }
}
