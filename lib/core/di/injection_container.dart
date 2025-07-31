import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import 'package:pocket_plus/core/network/dio_client.dart';
import 'package:pocket_plus/core/network/network_info.dart';
import 'package:pocket_plus/core/auth/user_session_manager.dart'; // Importa la nueva ubicación

// Importaciones de DI de features
import 'package:pocket_plus/features/auth/di/injection.dart' as auth_di;
import 'package:pocket_plus/features/content/di/injection.dart' as content_di;
import 'package:pocket_plus/features/profile/di/injection.dart' as profile_di;

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // External (como SharedPreferences)
  // Debe ser 'await' y registrar como instancia, no como factory/singleton que lo crea después.
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core
  // Network
  sl.registerLazySingleton<Dio>(() => DioClient().dio);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Auth Core
  sl.registerLazySingleton<UserSessionManager>(
    () => UserSessionManager(sl<SharedPreferences>()), // Inyecta SharedPreferences
  );

  // Features
  auth_di.initAuthFeature(sl);
  content_di.initContentFeature(sl);
  profile_di.initProfileFeature(sl);
}