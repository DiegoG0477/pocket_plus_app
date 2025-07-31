import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart'; // Ajusta ruta

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(InvalidInputFailure("Email y contraseña no pueden estar vacíos."));
    }
    // Aquí podrías añadir más validaciones de formato de email, etc.
    return await repository.login(email, password);
  }
}