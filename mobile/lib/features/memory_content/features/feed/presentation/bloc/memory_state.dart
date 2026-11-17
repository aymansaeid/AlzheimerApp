import 'package:equatable/equatable.dart';

import '../../domain/entities/memory_content.dart';

abstract class MemoryState extends Equatable {
  const MemoryState();

  @override
  List<Object?> get props => [];
}

class MemoryInitial extends MemoryState {}

class MemoryLoading extends MemoryState {}

class MemoryLoaded extends MemoryState {
  final List<MemoryContent> memories;
  final String patientId;
  final String currentUserId;
  final bool isPrimaryAdmin;
  final bool isActionInProgress; // Silme veya Ekleme işlemi sürerken (UI'da loader göstermek için)

  const MemoryLoaded({
    required this.memories,
    this.patientId = '',
    required this.currentUserId,
    required this.isPrimaryAdmin,
    this.isActionInProgress = false,
  });

  MemoryLoaded copyWith({
    List<MemoryContent>? memories,
    String? patientId,
    String? currentUserId,
    bool? isPrimaryAdmin,
    bool? isActionInProgress,
  }) {
    return MemoryLoaded(
      memories: memories ?? this.memories,
      patientId: patientId ?? this.patientId,
      currentUserId: currentUserId ?? this.currentUserId,
      isPrimaryAdmin: isPrimaryAdmin ?? this.isPrimaryAdmin,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [
    memories,
    patientId,
    currentUserId,
    isPrimaryAdmin,
    isActionInProgress,
  ];
}

class MemoryOperationSuccess extends MemoryLoaded {
  final String message;

  const MemoryOperationSuccess({
    required super.memories,
    super.patientId = '',
    required super.currentUserId,
    required super.isPrimaryAdmin,
    super.isActionInProgress = false,
    required this.message,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

class MemoryError extends MemoryState {
  final String message;

  const MemoryError(this.message);

  @override
  List<Object?> get props => [message];
}
