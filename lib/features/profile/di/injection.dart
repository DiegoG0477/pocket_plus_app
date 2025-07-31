import 'package:get_it/get_it.dart';
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';
import 'package:pocket_plus/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:pocket_plus/features/profile/domain/repositories/profile_repository.dart';
import 'package:pocket_plus/features/profile/domain/usecases/get_user_profile_data.dart';
import 'package:pocket_plus/features/auth/domain/usecases/logout_user.dart'; // Para inyectar LogoutUser
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Para inyectar AuthCubit
import 'package:pocket_plus/features/profile/presentation/cubit/profile_cubit.dart';

void initProfileFeature(GetIt sl) {
  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      authRepository: sl<AuthRepository>(),
      contentRepository: sl<ContentRepository>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileData(sl()));

sl.registerFactory( // Factory porque ProfilePage es una pantalla específica
    () => ProfileCubit(
      getUserProfileDataUseCase: sl(),
      logoutUserUseCase: sl<LogoutUser>(), // Reutilizamos el use case de Auth
      authCubit: sl<AuthCubit>(),       // Inyectamos el AuthCubit global
    ),
  );
}