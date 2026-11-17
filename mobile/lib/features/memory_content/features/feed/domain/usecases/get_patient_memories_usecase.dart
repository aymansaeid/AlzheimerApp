import 'package:injectable/injectable.dart';
import '../entities/memory_content.dart';
import '../repositories/memory_repository.dart';

@lazySingleton
class GetPatientMemoriesUseCase {
  final MemoryRepository _repository;

  GetPatientMemoriesUseCase(this._repository);

  Future<List<MemoryContent>> call(
    String patientId, {
    String? uploaderId,
    String? personName,
    int? contentType,
  }) async {
    return await _repository.getPatientMemories(
      patientId,
      uploaderId: uploaderId,
      personName: personName,
      contentType: contentType,
    );
  }
}
