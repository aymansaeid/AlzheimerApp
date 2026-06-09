import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_data_source.dart';
import '../models/medicine_model.dart';

@LazySingleton(as: MedicineRepository)
class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;

  MedicineRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Medicine>> addMedicine(Medicine medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      final newMedicine = await remoteDataSource.addMedicine(model);
      return Right(newMedicine);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Medicine>>> getMedicines(
    String patientId,
  ) async {
    try {
      final medicines = await remoteDataSource.getMedicines(patientId);
      return Right(medicines);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Medicine>> updateMedicine(
    Medicine medicine,
  ) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      final updatedMedicine = await remoteDataSource.updateMedicine(model);
      return Right(updatedMedicine);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedicine(String id) async {
    try {
      await remoteDataSource.deleteMedicine(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
