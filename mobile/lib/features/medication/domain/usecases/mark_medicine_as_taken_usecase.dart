import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/medication/domain/repositories/medicine_log_repository.dart';
import '../../../../core/errors/failures.dart';

@lazySingleton
class MarkMedicineAsTakenUseCase {
  final MedicineLogRepository repository;

  MarkMedicineAsTakenUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, int status) {
    return repository.updateMedicineStatus(id, status, null);
  }
}
