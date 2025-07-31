import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/profile/domain/entities/user_statistics.dart'; // Ajusta la ruta

abstract class ProfileRepository {
  // Obtener el usuario actual ya está en AuthRepository.
  // Podríamos tener un método que combine User y UserStatistics.
  Future<Either<Failure, User?>> getCurrentUserProfile(); // Reutiliza AuthRepository
  Future<Either<Failure, UserStatistics>> getUserStatistics(String userId);
}