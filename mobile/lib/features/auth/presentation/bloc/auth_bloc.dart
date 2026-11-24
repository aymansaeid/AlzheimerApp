import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:mobile/features/caregiver/domain/usecases/get_followed_patients.dart';
import 'package:mobile/features/onboarding/domain/usecases/check_has_admin_usecase.dart';
import '../../domain/entities/user.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;
  final GetFollowedPatients _getFollowedPatients;
  final CheckHasAdminUseCase _checkHasAdminUseCase;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._authRepository,
    this._getFollowedPatients,
    this._checkHasAdminUseCase,
  ) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthUserAvatarUpdated>(_onUserAvatarUpdated);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckAuthStatus);
  }

  Future<bool> _checkSetupComplete(User user) async {
    if (user.role == 'patient') {
      final result = await _checkHasAdminUseCase(user.id);
      return result.fold((_) => false, (hasAdmin) => hasAdmin);
    } else if (user.role == 'caregiver') {
      final result = await _getFollowedPatients();
      return result.fold((_) => false, (patients) => patients.isNotEmpty);
    }
    return true;
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(event.email, event.password);

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        final isSetup = await _checkSetupComplete(user);
        emit(AuthAuthenticated(user, isSetupComplete: isSetup));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      event.email,
      event.password,
      event.fullName,
      event.phone,
      event.role,
      avatarUrl: event.avatarUrl,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user, isSetupComplete: false)),
    );
  }

  void _onUserAvatarUpdated(
    AuthUserAvatarUpdated event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final updatedUser = currentState.user.copyWith(
        avatarUrl: event.avatarUrl,
        clearAvatarUrl: event.avatarUrl == null,
      );
      emit(
        AuthAuthenticated(
          updatedUser,
          isSetupComplete: currentState.isSetupComplete,
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Zaten giriş yapılmışsa tekrar işlem yapma
    if (state is AuthAuthenticated) return;

    // 1. Splash ekranında bekletmek için Loading yayınla
    emit(AuthLoading());

    // 2. Storage'dan token kontrolü
    final result = await _authRepository.checkAuthStatus();

    await result.fold(
      (failure) async {
        // Token yoksa, süresi dolmuşsa veya geçersizse
        emit(AuthUnauthenticated());
      },
      (user) async {
        // Token geçerli, kullanıcının kurulum durumunu kontrol et
        final isSetup = await _checkSetupComplete(user);
        emit(AuthAuthenticated(user, isSetupComplete: isSetup));
      },
    );
  }
}
