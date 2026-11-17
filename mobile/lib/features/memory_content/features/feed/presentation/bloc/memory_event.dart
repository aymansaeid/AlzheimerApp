import 'package:equatable/equatable.dart';
import 'dart:io';

import '../../domain/entities/memory_content.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadMemories extends MemoryEvent {
  final String patientId;
  final String currentUserId;
  final bool isPrimaryAdmin;

  const LoadMemories({
    required this.patientId,
    required this.currentUserId,
    required this.isPrimaryAdmin,
  });

  @override
  List<Object?> get props => [patientId, currentUserId, isPrimaryAdmin];
}

class DeleteMemory extends MemoryEvent {
  final String memoryId;

  const DeleteMemory(this.memoryId);

  @override
  List<Object?> get props => [memoryId];
}

// Not: CreateMemory için ayrı bir BLoC (CreatePostBloc) da yapabilirsin, 
// ancak şimdilik kolaylık olması adına buraya ekliyoruz.
class CreateMemory extends MemoryEvent {
  final File file;
  final String patientId;
  final MemoryContentType contentType;
  final String title;
  final String description;
  final String relationship;

  const CreateMemory({
    required this.file,
    required this.patientId,
    required this.contentType,
    required this.title,
    required this.description,
    required this.relationship,
  });
}