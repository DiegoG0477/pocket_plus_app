import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/auth/user_session_manager.dart'; // Importa la nueva ubicación
import 'package:pocket_plus/core/errors/exceptions.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/core/network/network_info.dart';
import 'package:pocket_plus/features/content/data/datasources/content_remote_data_source.dart';
import 'package:pocket_plus/features/content/data/models/content_item_model.dart';
import 'package:pocket_plus/features/content/data/models/tag_model.dart'; // Para conversión si es necesario
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';
import 'package:pocket_plus/core/constants/content_types.dart'; // Para ContentTypeGeneral
import 'dart:io'; // Import for File

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final UserSessionManager sessionManager; // Ya se inyecta

  ContentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sessionManager, // Ya se inyecta desde el DI
  });

  Future<Either<Failure, T>> _performAuthOperation<T>(
      Future<T> Function(String token) operation) async {
    if (await networkInfo.isConnected) {
      final token = await sessionManager.getToken();
      if (token == null || token.isEmpty) {
        return Left(UnauthorizedFailure("Usuario no autenticado o token no encontrado."));
      }
      try {
        final result = await operation(token);
        return Right(result);
      } on UnauthorizedException catch (e) {
        // Considera limpiar la sesión si el token es definitivamente inválido
        // await sessionManager.clearSession(); // Descomentar si quieres forzar logout aquí
        return Left(UnauthorizedFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      } catch (e) {
        return Left(ServerFailure("Error inesperado: ${e.toString()}"));
      }
    } else {
      return Left(NetworkFailure("No hay conexión a internet."));
    }
  }

  @override
  Future<Either<Failure, List<ContentItem>>> getAllContentItems(String userId, {
      ContentStatus? filterByStatus,
      ContentTypeGeneral? filterByType,
      ContentPriority? filterByPriority,
      String? filterByTagId,
  }) async {
    // userId podría obtenerse del UserSessionManager si tu API no lo requiere explícitamente
    // final currentUser = await sessionManager.getCurrentUser();
    // if (currentUser == null) return Left(UnauthorizedFailure("No hay usuario en sesión"));
    // final effectiveUserId = currentUser.id;

    return _performAuthOperation((token) => remoteDataSource.getAllContentItems(
      token,
      userId, // O effectiveUserId si lo obtienes de la sesión
      filterByStatus: filterByStatus,
      filterByType: filterByType,
      filterByPriority: filterByPriority,
      filterByTagId: filterByTagId,
    ));
  }

  @override
  Future<Either<Failure, ContentItem>> getContentItemById(String itemId) async {
     return _performAuthOperation((token) => remoteDataSource.getContentItemById(token, itemId));
  }

  @override
  Future<Either<Failure, ContentItem>> addContentItem(
    ContentItem contentItem, {
    File? imageFile,
  }) async {
    final model = contentItem is ContentItemModel
        ? contentItem
        : ContentItemModel.fromEntity(contentItem);

    // El usuarioId debe estar en el 'model' o ser inferido por el token en el backend
    // o ser obtenido del sessionManager y añadido aquí si es necesario.

    return _performAuthOperation(
      (token) => remoteDataSource.addContentItem(token, model, imageFile: imageFile),
    );
  }

  @override
  Future<Either<Failure, ContentItem>> updateContentItem(
    ContentItem contentItem, {
    File? imageFile,
    bool removeCurrentImage = false, // Pasar el flag
  }) async {
    final model = contentItem is ContentItemModel
        ? contentItem
        : ContentItemModel.fromEntity(contentItem);
    return _performAuthOperation(
      (token) => remoteDataSource.updateContentItem(
        token,
        model,
        imageFile: imageFile,
        removeCurrentImage: removeCurrentImage,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteContentItem(String itemId) async {
    return _performAuthOperation((token) => remoteDataSource.deleteContentItem(token, itemId));
  }

  @override
  Future<Either<Failure, List<Tag>>> getUserTags(String userId) async {
    // final currentUser = await sessionManager.getCurrentUser();
    // if (currentUser == null) return Left(UnauthorizedFailure("No hay usuario en sesión"));
    // final effectiveUserId = currentUser.id;
    return _performAuthOperation((token) => remoteDataSource.getUserTags(token, userId /* o effectiveUserId */));
  }

  @override
  Future<Either<Failure, Tag>> createTag(String name, String userId) async {
    // final currentUser = await sessionManager.getCurrentUser();
    // if (currentUser == null) return Left(UnauthorizedFailure("No hay usuario en sesión"));
    // final effectiveUserId = currentUser.id;
    return _performAuthOperation((token) => remoteDataSource.createTag(token, name, userId /* o effectiveUserId */));
  }
}
