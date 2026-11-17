import 'package:injectable/injectable.dart';

import '../repositories/memory_repository.dart';

@lazySingleton
class UpdateMemoryUseCase {
  final MemoryRepository _repository;

  UpdateMemoryUseCase(this._repository);

  Future<void> call(
    String id, {
    String? title,
    String? description,
    String? relationship,
    bool? isActive,
  }) async {
    return await _repository.updateMemory(
      id,
      title: title,
      description: description,
      relationship: relationship,
      isActive: isActive,
    );
  }
}
