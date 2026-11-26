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
    on<RefreshMemories>(_onRefreshMemories);
    on<DeleteMemory>(_onDeleteMemory);
    on<CreateMemory>(_onCreateMemory);
    on<AddMemoryContentEvent>(_onAddMemoryDirectly);
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
          patientId: event.patientId,
          currentUserId: event.currentUserId,
          isPrimaryAdmin: event.isPrimaryAdmin,
        ),
      );
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> _onRefreshMemories(
    RefreshMemories event,
    Emitter<MemoryState> emit,
  ) async {
    String? targetPatientId = event.patientId;
    String? currentUserId = event.currentUserId;
    bool? isPrimaryAdmin = event.isPrimaryAdmin;

    if (state is MemoryLoaded) {
      final currentState = state as MemoryLoaded;
      targetPatientId ??= currentState.patientId;
      currentUserId ??= currentState.currentUserId;
      isPrimaryAdmin ??= currentState.isPrimaryAdmin;
    }

    if (targetPatientId == null || targetPatientId.isEmpty) {
      return;
    }

    emit(MemoryLoading());
    try {
      final memories = await _getMemoriesUseCase(targetPatientId);
      emit(
        MemoryLoaded(
          memories: memories,
          patientId: targetPatientId,
          currentUserId: currentUserId ?? '',
          isPrimaryAdmin: isPrimaryAdmin ?? false,
        ),
      );
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }

  void _onAddMemoryDirectly(
    AddMemoryContentEvent event,
    Emitter<MemoryState> emit,
  ) {
    if (state is MemoryLoaded) {
      final currentState = state as MemoryLoaded;
      final updatedMemories = [event.memory, ...currentState.memories];
      emit(currentState.copyWith(memories: updatedMemories));
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
          MemoryOperationSuccess(
            memories: updatedMemories,
            patientId: currentState.patientId,
            currentUserId: currentState.currentUserId,
            isPrimaryAdmin: currentState.isPrimaryAdmin,
            isActionInProgress: false,
            message: 'Anı başarıyla silindi.',
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isActionInProgress: false));
        emit(MemoryError('Anı silinirken bir hata oluştu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCreateMemory(
    CreateMemory event,
    Emitter<MemoryState> emit,
  ) async {
    final currentState = state;
    final currentUserId =
        (event.uploaderId != null && event.uploaderId!.isNotEmpty)
        ? event.uploaderId!
        : (currentState is MemoryLoaded ? currentState.currentUserId : '');

    if (currentState is MemoryLoaded) {
      emit(currentState.copyWith(isActionInProgress: true));
    } else {
      emit(MemoryLoading());
    }

    try {
      final newMemory = await _createMemoryUseCase(
        file: event.file,
        patientId: event.patientId,
        contentType: event.contentType,
        title: event.title,
        description: event.description,
        relationship: event.relationship,
        uploaderId: currentUserId,
      );

      if (currentState is MemoryLoaded) {
        final updatedMemories = [newMemory, ...currentState.memories];
        emit(
          MemoryOperationSuccess(
            memories: updatedMemories,
            patientId: currentState.patientId,
            currentUserId: currentState.currentUserId,
            isPrimaryAdmin: currentState.isPrimaryAdmin,
            isActionInProgress: false,
            message: 'Anı başarıyla paylaşıldı.',
          ),
        );
      } else {
        emit(
          MemoryOperationSuccess(
            memories: [newMemory],
            patientId: event.patientId,
            currentUserId: currentUserId,
            isPrimaryAdmin: false,
            isActionInProgress: false,
            message: 'Anı başarıyla paylaşıldı.',
          ),
        );
      }
    } catch (e) {
      if (currentState is MemoryLoaded) {
        emit(currentState.copyWith(isActionInProgress: false));
      }
      emit(MemoryError('Anı kaydedilemedi: ${e.toString()}'));
    }
  }
}
