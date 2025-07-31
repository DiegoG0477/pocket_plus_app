import 'package:equatable/equatable.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart'; // Ajusta la ruta

class UserStatistics extends Equatable {
  final int totalItemsSaved;
  final int itemsCompleted;
  final int itemsDiscarded;
  final Map<String, double> contentByTypePercentage; // Ej: {"multimedia": 0.6, "fisico": 0.4}
  final List<Tag> mostUsedTags; // Podría ser List<Map<Tag, int>> para incluir conteo

  const UserStatistics({
    required this.totalItemsSaved,
    required this.itemsCompleted,
    required this.itemsDiscarded,
    required this.contentByTypePercentage,
    required this.mostUsedTags,
  });

  @override
  List<Object?> get props => [
        totalItemsSaved,
        itemsCompleted,
        itemsDiscarded,
        contentByTypePercentage,
        mostUsedTags,
      ];
}