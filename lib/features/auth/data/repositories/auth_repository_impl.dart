import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/auth/user_session_manager.dart'; // Importa la nueva ubicación
import 'package:pocket_plus/core/errors/exceptions.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/network/network_info.dart';
import 'package:pocket_plus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pocket_plus/features/auth/data/models/user_model.dart'; // Necesario para conversión
import 'package:pocket_plus/features/auth/domain/entities/user.dart';
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final UserSessionManager sessionManager; // Ya se inyecta

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sessionManager, // Ya se inyecta desde el DI
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        // userModel ya debería incluir el token desde el DataSource
        if (userModel.token == null || userModel.token!.isEmpty) {
          return Left(ServerFailure("El token no fue proporcionado o está vacío tras el login."));
        }
        await sessionManager.saveSession(userModel, userModel.token!);
        return Right(userModel); // UserModel es un User
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      } catch (e) { // Catch genérico por si algo más falla
        return Left(ServerFailure("Error inesperado durante el login: ${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure("No hay conexión a internet."));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String nombre,
    required String email,
    required String password,
    String? fotoPerfilUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.register(
          nombre: nombre,
          email: email,
          password: password,
          fotoPerfilUrl: fotoPerfilUrl,
        );
        if (userModel.token == null || userModel.token!.isEmpty) {
          return Left(ServerFailure("El token no fue proporcionado o está vacío tras el registro."));
        }
        await sessionManager.saveSession(userModel, userModel.token!);
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure("Error inesperado durante el registro: ${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure("No hay conexión a internet."));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final token = await sessionManager.getToken();
    if (token != null && token.isNotEmpty && await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout(token);
      } on ServerException catch (e) {
        print("Error en logout remoto (ignorado para logout local): ${e.message}");
      } catch (e) {
        print("Error inesperado en logout remoto (ignorado para logout local): ${e.toString()}");
      }
    }
    await sessionManager.clearSession();
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await sessionManager.getCurrentUser();
      // UserModel es un User, así que se puede retornar directamente.
      // La validez del token se asume si está presente. Podrías añadir lógica de
      // validación de token con el backend aquí si es necesario (ej. /auth/me).
      return Right(userModel);
    } catch (e) {
      // Esto sería una CacheException si usaras un LocalDataSource dedicado con manejo de errores.
      // Con SharedPreferences directo, un error al leer es menos probable a menos que los datos estén corruptos.
      print("Error al obtener usuario de la sesión: $e");
      return Left(CacheFailure("Error al obtener usuario de la sesión local."));
    }
  }
}