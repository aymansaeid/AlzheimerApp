import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

@lazySingleton
class UpdateMedicineUseCase {
  final MedicineRepository repository;

  UpdateMedicineUseCase(this.repository);

  Future<Either<Failure, Medicine>> call(Medicine medicine) {
    return repository.updateMedicine(medicine);
  }
}
