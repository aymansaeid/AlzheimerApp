import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/care_team_member.dart';
import '../../domain/repositories/care_network_repository.dart';
import '../datasources/care_network_remote_data_source.dart';

@LazySingleton(as: CareNetworkRepository)
class CareNetworkRepositoryImpl implements CareNetworkRepository {
  final CareNetworkRemoteDataSource remoteDataSource;
  final StreamController<void> _onNetworkChangedController = StreamController<void>.broadcast();

  CareNetworkRepositoryImpl(this.remoteDataSource);

  @override
  Stream<void> get onNetworkChanged => _onNetworkChangedController.stream;

  @override
  Future<Either<Failure, List<CareTeamMember>>> getCareTeam(String patientId) async {
    try {
      final team = await remoteDataSource.getCareTeam(patientId);
      return Right(team);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateInvite(String patientId) async {
    try {
      final code = await remoteDataSource.generateInvite(patientId);
      return Right(code);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeTeamMember(String patientId, String followerId) async {
    try {
      await remoteDataSource.removeTeamMember(patientId, followerId);
      _onNetworkChangedController.add(null);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(String patientId) async {
    try {
      await remoteDataSource.leaveTeam(patientId);
      _onNetworkChangedController.add(null);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> transferAdminRights(String patientId, String newAdminId) async {
    try {
      await remoteDataSource.transferAdminRights(patientId, newAdminId);
      _onNetworkChangedController.add(null);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
