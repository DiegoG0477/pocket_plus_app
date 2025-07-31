import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta la ruta

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String nombre,
    required String email,
    required String password,
    String? fotoPerfilUrl, // Para el path del archivo o URL si ya está subida
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser(); // Para chequear si hay sesión activa
}