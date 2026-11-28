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

class RefreshMemories extends MemoryEvent {
  final String? patientId;
  final String? currentUserId;
  final bool? isPrimaryAdmin;
  final bool silent;

  const RefreshMemories({
    this.patientId,
    this.currentUserId,
    this.isPrimaryAdmin,
    this.silent = false,
  });

  @override
  List<Object?> get props => [patientId, currentUserId, isPrimaryAdmin, silent];
}

class RefreshMemoriesIfStale extends MemoryEvent {
  final String patientId;
  final String currentUserId;
  final bool isPrimaryAdmin;
  final Duration staleDuration;

  const RefreshMemoriesIfStale({
    required this.patientId,
    required this.currentUserId,
    required this.isPrimaryAdmin,
    this.staleDuration = const Duration(minutes: 1),
  });

  @override
  List<Object?> get props => [
    patientId,
    currentUserId,
    isPrimaryAdmin,
    staleDuration,
  ];
}

class DeleteMemory extends MemoryEvent {
  final String memoryId;

  const DeleteMemory(this.memoryId);

  @override
  List<Object?> get props => [memoryId];
}

class CreateMemory extends MemoryEvent {
  final File? file;
  final String patientId;
  final MemoryContentType contentType;
  final String? title;
  final String? description;
  final String relationship;
  final String? uploaderId;

  const CreateMemory({
    this.file,
    required this.patientId,
    required this.contentType,
    this.title,
    this.description,
    required this.relationship,
    this.uploaderId,
  });

  @override
  List<Object?> get props => [
    file,
    patientId,
    contentType,
    title,
    description,
    relationship,
    uploaderId,
  ];
}

class AddMemoryContentEvent extends MemoryEvent {
  final MemoryContent memory;

  const AddMemoryContentEvent(this.memory);

  @override
  List<Object?> get props => [memory];
}
