import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pocket_plus/core/network/network_info.dart';
import 'package:pocket_plus/core/auth/user_session_manager.dart';
import 'package:pocket_plus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pocket_plus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart';
import 'package:pocket_plus/features/auth/domain/usecases/get_current_user.dart';
import 'package:pocket_plus/features/auth/domain/usecases/login_user.dart';
import 'package:pocket_plus/features/auth/domain/usecases/logout_user.dart';
import 'package:pocket_plus/features/auth/domain/usecases/register_user.dart';
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart';

void initAuthFeature(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<Dio>()), // Pasa la instancia de Dio
  );

  // Repository (asegúrate que reciba UserSessionManager si lo registraste en el DI global)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl<NetworkInfo>(),
      sessionManager: sl<UserSessionManager>(), // Aquí se inyecta
    ),
  );      

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  sl.registerLazySingleton(
    () => AuthCubit(
      loginUserUseCase: sl(),
      registerUserUseCase: sl(),
      logoutUserUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
}
