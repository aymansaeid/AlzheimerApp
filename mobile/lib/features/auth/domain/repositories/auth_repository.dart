import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);

  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
    String phone,
    int role,
  );

  Future<Either<Failure, User>> checkAuthStatus();
  Future<Either<Failure, void>> logout();
}
