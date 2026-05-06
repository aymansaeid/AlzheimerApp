import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_data_source.dart';

@LazySingleton(as: MedicationRepository)
class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;

  MedicationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Medication>>> getMedicationsByDate(
    String patientId,
    DateTime date,
  ) async {
    try {
      final medications = await remoteDataSource.getMedicationsByDate(
        patientId,
        date,
      );
      return Right(medications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Medication>> addMedication(
    Medication medication,
  ) async {
    try {
      final newMedication = await remoteDataSource.addMedication(medication);
      return Right(newMedication);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Medication>> updateMedication(
    Medication medication,
  ) async {
    try {
      final updatedMedication = await remoteDataSource.updateMedication(
        medication,
      );
      return Right(updatedMedication);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      await remoteDataSource.deleteMedication(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsTaken(String id, DateTime date) async {
    try {
      await remoteDataSource.markAsTaken(id, date);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
