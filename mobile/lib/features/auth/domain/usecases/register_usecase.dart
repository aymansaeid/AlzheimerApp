import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(
    String email,
    String password,
    String fullName,
    String phone,
    int role, {
    String? avatarUrl,
  }) {
    return repository.register(
      email,
      password,
      fullName,
      phone,
      role,
      avatarUrl: avatarUrl,
    );
  }
}
