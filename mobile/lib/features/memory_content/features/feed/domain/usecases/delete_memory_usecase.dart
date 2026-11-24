import 'package:injectable/injectable.dart';

import '../repositories/memory_repository.dart';

@lazySingleton
class DeleteMemoryUseCase {
  final MemoryRepository _repository;

  DeleteMemoryUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteMemory(id);
  }
}
