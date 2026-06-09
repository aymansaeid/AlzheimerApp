import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/medicine_log_model.dart';

abstract class MedicineLogRepository {
  Future<Either<Failure, List<MedicineLogModel>>> getDailyLogs(
    String patientId,
    DateTime date,
  );

  Future<Either<Failure, void>> updateMedicineStatus(
    String logId,
    int status,
    String? note,
  );
}
