import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine_log.dart';

abstract class MedicineLogRepository {
  Future<Either<Failure, List<MedicineLog>>> getDailyLogs(
    String patientId,
    DateTime date,
  );
}
