import 'dart:convert'; // Puede no ser necesario si Dio maneja bien el JSON
import 'package:dio/dio.dart'; // Importa Dio
import 'dart:io'; // Para File
import 'package:dio/dio.dart';
import 'package:pocket_plus/core/constants/api_constants.dart';
import 'package:pocket_plus/core/errors/exceptions.dart';
import 'package:pocket_plus/features/content/data/models/content_item_model.dart';
import 'package:pocket_plus/features/content/data/models/tag_model.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart'; // Para enums
import 'package:pocket_plus/core/constants/content_types.dart'; // Para ContentTypeGeneral

abstract class ContentRemoteDataSource {
  Future<List<ContentItemModel>> getAllContentItems(
    String token,
    String userId, {
    ContentStatus? filterByStatus,
    ContentTypeGeneral? filterByType,
    ContentPriority? filterByPriority,
    String? filterByTagId,
  });
  Future<ContentItemModel> getContentItemById(String token, String itemId);
  Future<ContentItemModel> addContentItem(
    String token,
    ContentItemModel contentItem, {
    File? imageFile, // Archivo de imagen opcional
  });

  Future<ContentItemModel> updateContentItem(
    String token,
    ContentItemModel contentItem, {
    File? imageFile, // Archivo de imagen opcional
    bool
    removeCurrentImage, // Para indicar si se debe eliminar la imagen actual en la API
  });
  Future<void> deleteContentItem(String token, String itemId);

  Future<List<TagModel>> getUserTags(String token, String userId);
  Future<TagModel> createTag(String token, String name, String userId);
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final Dio dio; // Inyecta Dio

  ContentRemoteDataSourceImpl({required this.dio});

  Options _getOptionsWithToken(String token, {String? contentType}) {
    final Map<String, dynamic> headers = {'Authorization': 'Bearer $token'};
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    return Options(headers: headers);
  }

  // Helper para manejar errores de Dio de forma consistente
  Exception _handleDioError(DioException e, String operation) {
    if (e.response?.statusCode == 401) {
      return UnauthorizedException(
        e.response?.data?['message'] ??
            'Token inválido o expirado durante $operation.',
      );
    }
    if (e.response?.statusCode == 404) {
      return ServerException(
        e.response?.data?['message'] ?? '$operation: Recurso no encontrado.',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
    return ServerException(
      e.response?.data?['message'] ??
          'Error en el servidor durante $operation.',
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }

  @override
  Future<List<ContentItemModel>> getAllContentItems(
    String token,
    String userId, {
    ContentStatus? filterByStatus,
    ContentTypeGeneral? filterByType,
    ContentPriority? filterByPriority,
    String? filterByTagId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'user_id': userId,
      }; // Asumiendo que user_id se pasa así
      if (filterByStatus != null)
        queryParams['status'] = filterByStatus.toString().split('.').last;
      if (filterByType != null)
        queryParams['type'] = filterByType.toString().split('.').last;
      if (filterByPriority != null)
        queryParams['priority'] = filterByPriority.toString().split('.').last;
      if (filterByTagId != null) queryParams['tag_id'] = filterByTagId;

      final response = await dio.get(
        ApiConstants.contentBaseEndpoint, // ej: '/content'
        queryParameters: queryParams,
        options: _getOptionsWithToken(token, contentType: 'application/json'),
      );

      final List<dynamic> jsonData = response.data as List<dynamic>;
      return jsonData
          .map(
            (item) => ContentItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'obtener todos los contenidos');
    }
  }

  @override
  Future<ContentItemModel> getContentItemById(
    String token,
    String itemId,
  ) async {
    try {
      final response = await dio.get(
        '${ApiConstants.contentBaseEndpoint}/$itemId', // ej: '/content/123'
        options: _getOptionsWithToken(token, contentType: 'application/json'),
      );
      return ContentItemModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'obtener contenido por ID');
    }
  }

  @override
  Future<ContentItemModel> addContentItem(
    String token,
    ContentItemModel contentItem, {
    File? imageFile,
  }) async {
    try {
      final Map<String, dynamic> itemData = contentItem.toJson();
      // Remover campos que no deben enviarse
      itemData.remove('id');
      itemData.remove('imagenUrl');
      itemData.remove('fechaGuardado');
      itemData.remove('fechaActualizacion');
      itemData.remove('usuarioId');

      // Manejar el campo 'enlace' (link) si es opcional y está vacío
      if (itemData.containsKey('enlace') &&
          itemData['enlace'] != null && // Add null check here
          (itemData['enlace'] as String).isEmpty) {
        itemData['enlace'] = null; // Enviar como null si está vacío
      }

      // Convertir los tags a tagIds si es necesario
      if (itemData.containsKey('tags')) {
        itemData['tagIds'] = (itemData['tags'] as List)
            .map((tag) => tag['id'] as String)
            .toList(); // Enviar la lista directamente
        itemData.remove('tags');
      }

      // Convertir todos los valores no nulos a String para FormData, excepto los archivos.
      // Esto es para asegurar que FormData.fromMap no encuentre un tipo inesperado.
      final Map<String, dynamic> formDataMap = {};
      itemData.forEach((key, value) {
        if (value != null) {
          // LÓGICA CORREGIDA Y CONSISTENTE
          if (key == 'tagIds' && value is List) {
            // Unir la lista en una cadena separada por comas
            formDataMap[key] = value.join(',');
          } else {
            formDataMap[key] = value.toString();
          }
        }
      });

      // Si tagIds está vacío, no se debe enviar una cadena vacía
      if (formDataMap['tagIds'] == '') {
        formDataMap.remove('tagIds');
      }

      final FormData formData = FormData.fromMap(formDataMap);

      if (imageFile != null) {
        formData.files.add(
          MapEntry('imagen_file', await MultipartFile.fromFile(imageFile.path)),
        );
      }

      Response response;
      try {
        response = await dio.post(
          ApiConstants.contentBaseEndpoint,
          data: formData,
          options: _getOptionsWithToken(
            token,
          ), // Let Dio handle Content-Type for FormData
        );
      } catch (e) {
        print('Error during dio.post: $e');
        if (e is DioException) {
          if (e.response?.statusCode == 400) {
            throw ServerException(
              e.response?.data?['message'] ??
                  'Datos inválidos para crear contenido.',
              statusCode: e.response?.statusCode,
              data: e.response?.data,
            );
          }
          throw _handleDioError(e, 'añadir contenido');
        }
        throw ServerException('Error inesperado al enviar contenido: $e');
      }
      return ContentItemModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow; // Rethrow our custom ServerException
    } catch (e) {
      // Catch any other unexpected errors
      print('Unhandled error in addContentItem: $e');
      throw ServerException('Error desconocido al añadir contenido: $e');
    }
  }

  @override
  Future<ContentItemModel> updateContentItem(
    String token,
    ContentItemModel contentItem, {
    File? imageFile,
    bool removeCurrentImage = false,
  }) async {
    try {
      final Map<String, dynamic> itemData = contentItem.toJson();
      itemData.remove('id'); // Remove id from the body
      itemData.remove(
        'imagen_url',
      ); // No enviamos la URL directamente si subimos archivo o la eliminamos

      // Manejar el campo 'enlace' (link) si es opcional y está vacío
      if (itemData.containsKey('enlace') &&
          itemData['enlace'] != null &&
          (itemData['enlace'] as String).isEmpty) {
        itemData['enlace'] = null; // Enviar como null si está vacío
      }

      final Map<String, dynamic> formDataMap = {};
      itemData.forEach((key, value) {
        if (value != null) {
          // LÓGICA CORREGIDA Y CONSISTENTE
          if (key == 'tagIds' && value is List) {
            // Unir la lista en una cadena separada por comas
            formDataMap[key] = value.join(',');
          } else {
            formDataMap[key] = value.toString();
          }
        }
      });

      // Si tagIds está vacío, no se debe enviar una cadena vacía
      if (formDataMap['tagIds'] == '') {
        formDataMap.remove('tagIds');
      }

      // Añadir el flag para eliminar la imagen
      if (removeCurrentImage) {
        formDataMap['removeCurrentImage'] = 'true';
      }

      final FormData formData = FormData.fromMap(formDataMap);

      if (removeCurrentImage) {
        // Tu API debe tener una forma de indicar que se elimine la imagen,
        // ej. enviando un campo 'remove_image_flag': true o imagen_file: null
        // o un endpoint específico para desasociar imagen.
        // Por ahora, asumimos que no enviar un nuevo archivo y que la API lo maneja
        // o que si se envía `imagen_file` nuevo, reemplaza al anterior.
        // Si necesitas un flag explícito:
        // formData.fields.add(MapEntry('remove_current_image', 'true'));
      }

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'imagen_file', // El nombre del campo que espera tu API para el archivo
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }
      // Si no se envía imageFile y no se marca removeCurrentImage,
      // la API no debería modificar la imagen existente.

      final response = await dio.patch(
        '${ApiConstants.contentBaseEndpoint}/${contentItem.id}',
        data: formData,
        options: _getOptionsWithToken(
          token,
        ), // Let Dio handle Content-Type for FormData
      );
      return ContentItemModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(
          e.response?.data?['message'] ??
              'Datos inválidos para actualizar contenido.',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      }
      throw _handleDioError(e, 'actualizar contenido');
    }
  }

  @override
  Future<void> deleteContentItem(String token, String itemId) async {
    try {
      await dio.delete(
        '${ApiConstants.contentBaseEndpoint}/$itemId',
        options: _getOptionsWithToken(token, contentType: 'application/json'),
      );
      // Dio considera status codes 2xx como éxito, un 204 (No Content) no lanzará error.
    } on DioException catch (e) {
      throw _handleDioError(e, 'eliminar contenido');
    }
  }

  @override
  Future<List<TagModel>> getUserTags(String token, String userId) async {
    try {
      // Asume un endpoint /tags?user_id=userId o /users/userId/tags
      // Ajusta el endpoint y queryParams según tu API
      final response = await dio.get(
        ApiConstants.tagsBaseEndpoint, // ej: '/tags'
        queryParameters: {'user_id': userId},
        options: _getOptionsWithToken(token, contentType: 'application/json'),
      );
      final List<dynamic> jsonData = response.data as List<dynamic>;
      return jsonData
          .map((tag) => TagModel.fromJson(tag as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'obtener tags de usuario');
    }
  }

  @override
  Future<TagModel> createTag(String token, String name, String userId) async {
    try {
      final response = await dio.post(
        ApiConstants.tagsBaseEndpoint,
        data: {'nombre': name}, // `usuario_id` podría ser inferido del token
        options: _getOptionsWithToken(token, contentType: 'application/json'),
      );
      return TagModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // Bad Request, ej. validación
        throw ServerException(
          e.response?.data?['message'] ?? 'Datos inválidos para crear tag.',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      }
      throw _handleDioError(e, 'crear tag');
    }
  }
}
