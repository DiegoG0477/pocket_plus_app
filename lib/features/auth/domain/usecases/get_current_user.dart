import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart'; // Ajusta ruta

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, User?>> call() async {
    return await repository.getCurrentUser();
  }
}