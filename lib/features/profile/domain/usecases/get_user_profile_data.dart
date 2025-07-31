import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/profile/domain/entities/user_statistics.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/profile/domain/repositories/profile_repository.dart'; // Ajusta la ruta

class GetUserProfileData {
  final ProfileRepository repository;

  GetUserProfileData(this.repository);

  // Podríamos devolver un objeto combinado o un tuple/record
  Future<Either<Failure, ({User user, UserStatistics statistics})>> call() async {
    final userResult = await repository.getCurrentUserProfile();
    return userResult.fold(
      (failure) => Left(failure),
      (user) async {
        if (user == null) {
          return Left(UnauthorizedFailure("No hay usuario en sesión."));
        }
        final statisticsResult = await repository.getUserStatistics(user.id);
        return statisticsResult.fold(
          (failure) => Left(failure),
          (statistics) => Right((user: user, statistics: statistics)),
        );
      },
    );
  }
}