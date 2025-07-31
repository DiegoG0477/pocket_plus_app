import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart'; // Ajusta ruta

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call({
    required String nombre,
    required String email,
    required String password,
    String? fotoPerfilUrl,
  }) async {
    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      return Left(InvalidInputFailure("Nombre, email y contraseña son requeridos."));
    }
    // Más validaciones...
    return await repository.register(
      nombre: nombre,
      email: email,
      password: password,
      fotoPerfilUrl: fotoPerfilUrl,
    );
  }
}