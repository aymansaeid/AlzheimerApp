import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/medicine_repository.dart';

@lazySingleton
class DeleteMedicineUseCase {
  final MedicineRepository repository;

  DeleteMedicineUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteMedicine(id);
  }
}
