import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/invite_response.dart';
import '../../domain/repositories/follower_repository.dart';
import '../datasources/follower_remote_data_source.dart';

@LazySingleton(as: FollowerRepository)
class FollowerRepositoryImpl implements FollowerRepository {
  final FollowerRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final StreamController<void> _onInviteAcceptedController = StreamController<void>.broadcast();

  FollowerRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Stream<void> get onInviteAccepted => _onInviteAcceptedController.stream;

  @override
  Future<Either<Failure, bool>> checkHasAdmin(String patientId) async {
    try {
      final result = await remoteDataSource.checkHasAdmin(patientId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InviteResponse>> generateInvite(
    String patientId,
    bool isPrimary,
  ) async {
    try {
      final result = await remoteDataSource.generateInvite(
        patientId,
        isPrimary,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> acceptInvite(
    String inviteCode,
    String relationship,
  ) async {
    try {
      final result = await remoteDataSource.acceptInvite(
        inviteCode,
        relationship,
      );
      if (result) {
        // Save connection state locally to dynamically manage mock caregiver dashboard redirects
        await secureStorage.write(key: 'has_accepted_invite', value: 'true');
        _onInviteAcceptedController.add(null);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
