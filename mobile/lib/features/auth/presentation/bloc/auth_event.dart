import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final int role;
  final String? avatarUrl;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        fullName,
        phone,
        role,
        avatarUrl,
      ];
}

class AuthUserAvatarUpdated extends AuthEvent {
  final String? avatarUrl;

  const AuthUserAvatarUpdated(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class AuthUserProfileUpdated extends AuthEvent {
  final String? fullName;
  final String? email;
  final String? phone;

  const AuthUserProfileUpdated({
    this.fullName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [fullName, email, phone];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
