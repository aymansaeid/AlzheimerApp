import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_memory_usecase.dart';
import '../../domain/usecases/delete_memory_usecase.dart';
import '../../domain/usecases/get_patient_memories_usecase.dart';
import 'memory_event.dart';
import 'memory_state.dart';

@injectable
class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final GetPatientMemoriesUseCase _getMemoriesUseCase;
  final DeleteMemoryUseCase _deleteMemoryUseCase;
  final CreateMemoryUseCase _createMemoryUseCase;

  MemoryBloc(
    this._getMemoriesUseCase,
    this._deleteMemoryUseCase,
    this._createMemoryUseCase,
  ) : super(MemoryInitial()) {
    on<LoadMemories>(_onLoadMemories);
    on<DeleteMemory>(_onDeleteMemory);
    on<CreateMemory>(_onCreateMemory);
  }

  Future<void> _onLoadMemories(
    LoadMemories event,
    Emitter<MemoryState> emit,
  ) async {
    emit(MemoryLoading());
    try {
      final memories = await _getMemoriesUseCase(event.patientId);
      emit(
        MemoryLoaded(
          memories: memories,
          currentUserId: event.currentUserId,
          isPrimaryAdmin: event.isPrimaryAdmin,
        ),
      );
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> _onDeleteMemory(
    DeleteMemory event,
    Emitter<MemoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is MemoryLoaded) {
      emit(currentState.copyWith(isActionInProgress: true));
      try {
        await _deleteMemoryUseCase(event.memoryId);

        // Başarıyla silindikten sonra listeyi güncelle
        final updatedMemories = currentState.memories
            .where((m) => m.id != event.memoryId)
            .toList();
        emit(
          currentState.copyWith(
            memories: updatedMemories,
            isActionInProgress: false,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isActionInProgress: false));
        // İstersen burada ayrı bir Event veya Error fırlatabilirsin
      }
    }
  }

  Future<void> _onCreateMemory(
    CreateMemory event,
    Emitter<MemoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is MemoryLoaded) {
      emit(currentState.copyWith(isActionInProgress: true));
      try {
        final newMemory = await _createMemoryUseCase(
          file: event.file,
          patientId: event.patientId,
          contentType: event.contentType,
          title: event.title,
          description: event.description,
          relationship: event.relationship,
          uploaderId:
              currentState.currentUserId, // Burada uploaderId'yi geçiyoruz
        );

        // Yeni anıyı listenin en başına ekle (Pull-to-refresh yapmadan anında görünsün)
        final updatedMemories = [newMemory, ...currentState.memories];
        emit(
          currentState.copyWith(
            memories: updatedMemories,
            isActionInProgress: false,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isActionInProgress: false));
      }
    }
  }
}
