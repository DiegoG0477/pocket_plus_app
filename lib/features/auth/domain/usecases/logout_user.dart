import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart'; // Ajusta ruta

class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}