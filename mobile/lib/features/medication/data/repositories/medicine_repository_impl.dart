import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../notifications/domain/repository/notification_repository.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_remote_data_source.dart';
import '../models/medicine_model.dart';

@LazySingleton(as: MedicineRepository)
class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;
  final NotificationRepository notificationRepository;
  final StreamController<void> _medicinesChangedController =
      StreamController<void>.broadcast();

  MedicineRepositoryImpl(
    this.remoteDataSource,
    this.notificationRepository,
  );

  @override
  Stream<void> get onMedicinesChanged => _medicinesChangedController.stream;

  @override
  Future<Either<Failure, Medicine>> addMedicine(Medicine medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      final newMedicine = await remoteDataSource.addMedicine(model);
      _medicinesChangedController.add(null);
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
      // UI akışını bloklamadan asenkron olarak yerel bildirimleri senkronize et
      unawaited(notificationRepository.syncMedicationReminders(medicines));
      return Right(medicines);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Medicine>> getMedicineById(String id) async {
    try {
      final medicine = await remoteDataSource.getMedicineById(id);
      return Right(medicine);
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
      _medicinesChangedController.add(null);
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
      // Silinen ilacın yerel bildirimini de temizle
      unawaited(notificationRepository.cancelMedicationReminders(id));
      _medicinesChangedController.add(null);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
