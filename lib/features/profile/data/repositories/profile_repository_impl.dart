import 'package:dartz/dartz.dart';
import 'package:pocket_plus/core/errors/failure.dart';
import 'package:pocket_plus/features/auth/domain/entities/user.dart';
import 'package:pocket_plus/features/auth/domain/repositories/auth_repository.dart'; // Para obtener el usuario
import 'package:pocket_plus/features/content/domain/entities/content_item.dart'; // Para tipos y estados
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart'; // Para obtener items y tags
import 'package:pocket_plus/features/profile/domain/entities/user_statistics.dart';
import 'package:pocket_plus/features/profile/domain/repositories/profile_repository.dart';
import 'package:collection/collection.dart'; // Para groupBy y otras utilidades de colección

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthRepository authRepository;
  final ContentRepository contentRepository;

  ProfileRepositoryImpl({
    required this.authRepository,
    required this.contentRepository,
  });

  @override
  Future<Either<Failure, User?>> getCurrentUserProfile() async {
    // Simplemente delegamos al AuthRepository
    return authRepository.getCurrentUser();
  }

  @override
  Future<Either<Failure, UserStatistics>> getUserStatistics(String userId) async {
    final contentItemsResult = await contentRepository.getAllContentItems(userId);

    return contentItemsResult.fold(
      (failure) => Left(failure),
      (items) {
        try {
          final totalItemsSaved = items.length;
          final itemsCompleted = items.where((item) => item.estado == ContentStatus.completado).length;
          final itemsDiscarded = items.where((item) => item.estado == ContentStatus.descartado).length;

          // Porcentaje por tipo general
          Map<String, double> contentByTypePercentage = {};
          if (totalItemsSaved > 0) {
            final itemsByType = groupBy(items, (ContentItem item) => item.tipoGeneral);
            itemsByType.forEach((type, list) {
              // Usamos el nombre del enum como clave, ej: "multimedia"
              contentByTypePercentage[type.toString().split('.').last] = list.length / totalItemsSaved;
            });
          }

          // Tags más usados (ejemplo: top 5)
          final allTagsFromItems = items.expand((item) => item.tags).toList();
          final tagCounts = allTagsFromItems.fold<Map<String, int>>({}, (map, tag) {
            map[tag.id] = (map[tag.id] ?? 0) + 1;
            return map;
          });

          final sortedTagCounts = tagCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final mostUsedTagsFull = sortedTagCounts
              .take(5) // Tomar los 5 más usados
              .map((entry) {
                // Encontrar el objeto Tag original para tener el nombre
                return allTagsFromItems.firstWhere((tag) => tag.id == entry.key);
              }).toList();

          return Right(UserStatistics(
            totalItemsSaved: totalItemsSaved,
            itemsCompleted: itemsCompleted,
            itemsDiscarded: itemsDiscarded,
            contentByTypePercentage: contentByTypePercentage,
            mostUsedTags: mostUsedTagsFull,
          ));
        } catch (e) {
          // Captura cualquier error durante el procesamiento de datos
          return Left(ServerFailure("Error al calcular estadísticas: ${e.toString()}"));
        }
      },
    );
  }
}