import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

@lazySingleton
class AddMedicineUseCase {
  final MedicineRepository repository;

  AddMedicineUseCase(this.repository);

  Future<Either<Failure, Medicine>> call(Medicine medicine) {
    return repository.addMedicine(medicine);
  }
}
