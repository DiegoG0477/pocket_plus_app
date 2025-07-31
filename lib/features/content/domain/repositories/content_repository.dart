import 'package:dartz/dartz.dart';
import 'dart:io'; // Import for File
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/core/constants/content_types.dart'; // Para ContentTypeGeneral

abstract class ContentRepository {
  // ContentItem CRUD
  Future<Either<Failure, List<ContentItem>>> getAllContentItems(String userId, {
      ContentStatus? filterByStatus,
      ContentTypeGeneral? filterByType,
      ContentPriority? filterByPriority,
      String? filterByTagId,
  });
  Future<Either<Failure, ContentItem>> getContentItemById(String itemId);
 Future<Either<Failure, ContentItem>> addContentItem(
    ContentItem contentItem, {
    File? imageFile,
  });
  Future<Either<Failure, ContentItem>> updateContentItem(
    ContentItem contentItem, {
    File? imageFile,
    bool removeCurrentImage,
  });
  Future<Either<Failure, void>> deleteContentItem(String itemId);

  // Tag Management
  Future<Either<Failure, List<Tag>>> getUserTags(String userId);
  Future<Either<Failure, Tag>> createTag(String name, String userId);
  // Asignar/Desasignar tags a un ContentItem podría estar aquí o ser parte de updateContentItem
  // Future<Either<Failure, void>> addTagToContentItem(String itemId, String tagId);
  // Future<Either<Failure, void>> removeTagFromContentItem(String itemId, String tagId);
}
