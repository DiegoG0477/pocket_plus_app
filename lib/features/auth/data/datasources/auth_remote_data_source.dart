import 'package:dio/dio.dart'; // Importa Dio
import 'package:pocket_plus/core/constants/api_constants.dart';
import 'package:pocket_plus/core/errors/exceptions.dart';
import 'package:pocket_plus/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
    String? fotoPerfilUrl, // O podrías enviar un MultipartFile con Dio
  });
  Future<void> logout(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio; // Inyecta Dio

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      // Dio por defecto parsea JSON, así que response.data ya es un Map<String, dynamic>
      // Asumimos que la API devuelve el usuario y el token.
      // Ajusta según tu API.
      // Ejemplo: {'data': {'user': {...}, 'token': 'xyz'}} o {'user': {...}, 'token': 'xyz'}
      final responseData = response.data as Map<String, dynamic>;
      Map<String, dynamic> userData =
          responseData['user'] ?? responseData['data']?['user'] ?? responseData;
      String? token = responseData['token'] ?? responseData['data']?['token'];

      if (token != null) {
        userData['token'] = token;
      } else if (userData['token'] == null) {
        // Si el token está en user y no afuera
        // Intenta buscarlo en el encabezado de respuesta si tu API lo pone ahí
        // token = response.headers.value('authorization')?.replaceFirst('Bearer ', '');
        // if (token != null) userData['token'] = token;
      }

      if (userData['token'] == null) {
        throw ServerException(
          "Token no encontrado en la respuesta del login.",
          statusCode: response.statusCode,
        );
      }

      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data?['message'] ?? 'Credenciales incorrectas.',
        );
      }
      throw ServerException(
        e.response?.data?['message'] ?? 'Error en el servidor durante el login',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  @override
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
    String? fotoPerfilUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nombre': nombre,
        'email': email,
        'password': password,
      };
      if (fotoPerfilUrl != null) {
        // Si fotoPerfilUrl es una URL de una imagen ya subida:
        data['fotoPerfilUrl'] = fotoPerfilUrl;
        // Si necesitas subir un archivo, usarías FormData:
        // FormData formData = FormData.fromMap({
        //   ...data,
        //   'foto_perfil_file': await MultipartFile.fromFile(fotoPerfilPath, filename: 'profile.jpg'),
        // });
        // Y luego `await dio.post(ApiConstants.registerEndpoint, data: formData);`
      }

      final response = await dio.post(
        ApiConstants.registerEndpoint,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      Map<String, dynamic> userData =
          responseData['user'] ?? responseData['data']?['user'] ?? responseData;
      String? token = responseData['token'] ?? responseData['data']?['token'];

      if (token != null) {
        userData['token'] = token;
      } else if (userData['token'] == null) {
        // token = response.headers.value('authorization')?.replaceFirst('Bearer ', '');
        // if (token != null) userData['token'] = token;
      }

      if (userData['token'] == null) {
        throw ServerException(
          "Token no encontrado en la respuesta del registro.",
          statusCode: response.statusCode,
        );
      }
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ??
            'Error en el servidor durante el registro',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  @override
  Future<void> logout(String token) async {
    // Si tu API tiene un endpoint de logout que requiere el token:
    if (ApiConstants.logoutEndpoint.isNotEmpty) {
      try {
        await dio.post(
          ApiConstants.logoutEndpoint,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } on DioException catch (e) {
        // No fallar críticamente si el logout remoto falla, pero loguearlo.
        print("Error en logout remoto: ${e.message}");
        // Podrías lanzar una ServerException si quieres manejarlo más arriba,
        // pero para logout, a menudo es suficiente con limpiar localmente.
        // throw ServerException('Error al cerrar sesión en el servidor', statusCode: e.response?.statusCode);
      }
    }
    // Si no hay endpoint, no se hace nada aquí, la limpieza del token es local en el repo.
    return;
  }
}
