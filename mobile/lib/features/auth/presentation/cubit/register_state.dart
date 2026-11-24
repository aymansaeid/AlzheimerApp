import 'dart:io';

import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  final String selectedRole;
  final File? selectedAvatarFile;
  final bool isLoading;
  final String? errorMessage;
  final String? permissionDeniedType;

  const RegisterState({
    this.selectedRole = 'patient',
    this.selectedAvatarFile,
    this.isLoading = false,
    this.errorMessage,
    this.permissionDeniedType,
  });

  RegisterState copyWith({
    String? selectedRole,
    File? selectedAvatarFile,
    bool clearAvatarFile = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? permissionDeniedType,
    bool clearPermissionDenied = false,
  }) {
    return RegisterState(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedAvatarFile: clearAvatarFile
          ? null
          : (selectedAvatarFile ?? this.selectedAvatarFile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      permissionDeniedType: clearPermissionDenied
          ? null
          : (permissionDeniedType ?? this.permissionDeniedType),
    );
  }

  @override
  List<Object?> get props => [
        selectedRole,
        selectedAvatarFile,
        isLoading,
        errorMessage,
        permissionDeniedType,
      ];
}
