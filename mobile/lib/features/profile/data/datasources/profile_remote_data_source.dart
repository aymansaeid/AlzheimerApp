import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/profile_user.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileUser> updateProfile(ProfileUser user);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<ProfileUser> updateProfile(ProfileUser user) async {
    // TODO: Implement when backend profile update endpoint is available.
    throw UnimplementedError(
      'Profil güncelleme endpointi henüz backend tarafında mevcut değil.',
    );
  }
}
