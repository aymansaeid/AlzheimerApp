import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/network_user.dart';
import '../../domain/repositories/care_network_repository.dart';
import '../datasources/care_network_remote_data_source.dart';
import '../models/network_user_model.dart';

@LazySingleton(as: CareNetworkRepository)
class CareNetworkRepositoryImpl implements CareNetworkRepository {
  final CareNetworkRemoteDataSource remoteDataSource;

  CareNetworkRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<NetworkUser>>> getNetworkUsers() async {
    try {
      final data = await remoteDataSource.getNetworkUsers();
      final users = data.map((json) => NetworkUserModel.fromJson(json)).toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generatePatientInviteLink() async {
    try {
      final link = await remoteDataSource.generatePatientInviteLink();
      return Right(link);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateCaregiverInviteLink() async {
    try {
      final link = await remoteDataSource.generateCaregiverInviteLink();
      return Right(link);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
