import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine_log.dart';
import '../repositories/medicine_log_repository.dart';

@lazySingleton
class GetDailyLogsUseCase {
  final MedicineLogRepository repository;

  GetDailyLogsUseCase(this.repository);

  Future<Either<Failure, List<MedicineLog>>> call(
    String patientId,
    DateTime date,
  ) {
    return repository.getDailyLogs(patientId, date);
  }
}
