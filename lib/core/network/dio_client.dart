import 'package:dio/dio.dart';
import 'package:pocket_plus/core/constants/api_constants.dart';
// Importar interceptores si los creamos más adelante
// import 'interceptors/auth_interceptor.dart';
// import 'interceptors/logging_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient(
    /* UserSessionManager userSessionManager // Para inyectar al AuthInterceptor */
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 15000), // 15 segundos
        receiveTimeout: const Duration(milliseconds: 15000), // 15 segundos
        headers: {'Accept': 'application/json'},
      ),
    );

    // Añadir interceptores
    // _dio.interceptors.add(LoggingInterceptor());
    // _dio.interceptors.add(AuthInterceptor(_dio, userSessionManager)); // Necesita Dio para refresh token si se implementa
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    ); // Interceptor de logging de Dio
  }

  Dio get dio => _dio;
}
