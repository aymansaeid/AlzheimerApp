import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

@lazySingleton
class GetMedicineByIdUseCase {
  final MedicineRepository repository;

  GetMedicineByIdUseCase(this.repository);

  Future<Either<Failure, Medicine>> call(String id) {
    return repository.getMedicineById(id);
  }
}
