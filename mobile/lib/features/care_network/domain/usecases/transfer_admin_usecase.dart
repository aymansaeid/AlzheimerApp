import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/care_network_repository.dart';

@lazySingleton
class TransferAdminUseCase {
  final CareNetworkRepository repository;

  TransferAdminUseCase(this.repository);

  Future<Either<Failure, void>> call(String patientId, String newAdminId) {
    return repository.transferAdminRights(patientId, newAdminId);
  }
}
