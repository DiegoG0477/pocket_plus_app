import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Para proveer AuthCubit
import 'package:cached_network_image/cached_network_image.dart'; // Para imágenes de red con caché
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart'; // Import ContentCubit
import 'package:timeago/timeago.dart' as timeago; // Para "hace 2 horas"
import 'package:go_router/go_router.dart'; // Para navegación
import 'package:pocket_plus/core/router/app_routes.dart'; // Para rutas

// Custom timeago messages for Spanish to be more precise
class PocketPlusEsMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'hace';
  @override
  String prefixFromNow() => 'dentro de';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'un instante'; // More precise
  @override
  String aboutAMinute(int minutes) => '1 minuto';
  @override
  String minutes(int minutes) => '$minutes minutos';
  @override
  String aboutAnHour(int minutes) => '1 hora';
  @override
  String hours(int hours) => '$hours horas';
  @override
  String aDay(int hours) => '1 día';
  @override
  String days(int days) => '$days días';
  @override
  String aboutAMonth(int days) => '1 mes';
  @override
  String months(int months) => '$months meses';
  @override
  String aboutAYear(int year) => '1 año';
  @override
  String years(int years) => '$years años';
  @override
  String wordSeparator() => ' ';
}

class ContentCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback? onRefresh; // New callback parameter

  const ContentCard({super.key, required this.item, this.onRefresh});

  // Helper para obtener el color de la prioridad
  Color _getPriorityColor(ContentPriority priority, BuildContext context) {
    switch (priority) {
      case ContentPriority.alta:
        return const Color(0xFF90CAF9); // Azul pastel
      case ContentPriority.media:
        return const Color(0xFFFFF59D); // Amarillo pastel
      case ContentPriority.baja:
        return const Color(0xFFC8E6C9); // Verde pastel
      default:
        return Colors.grey;
    }
  }

  // Helper para obtener el emoji del subtipo
  String _getSubtypeEmoji(String subtype) {
    switch (subtype.toLowerCase()) {
      case 'artículo':
        return '📄';
      case 'libro':
        return '📚';
      case 'lista lectura':
        return '📖';
      case 'noticia':
        return '📰';
      case 'pdf':
        return '📄';
      case 'nota':
        return '📝';
      case 'post':
        return '✍️';
      case 'video':
        return '📹';
      case 'película':
        return '🎬';
      case 'podcast':
        return '🎙️';
      case 'música':
        return '🎵';
      case 'juego':
        return '🎮';
      case 'trailer':
        return '🎞️';
      case 'curso':
        return '🎓';
      case 'técnica':
        return '🧠';
      case 'productividad':
        return '📈';
      case 'creativo':
        return '🎨';
      case 'proyecto':
        return '🏗️';
      case 'herramienta':
        return '🛠️';
      case 'plugin':
        return '🔌';
      case 'recurso':
        return '📦';
      case 'idea':
        return '💡';
      case 'restaurante':
        return '🍽️';
      case 'lugar':
        return '📍';
      case 'actividad':
        return '🤸';
      case 'hotel':
        return '🏨';
      case 'evento':
        return '🗓️';
      case 'viaje':
        return '✈️';
      case 'reunión':
        return '🤝';
      case 'producto':
        return '🛍️';
      case 'tienda':
        return '🏪';
      case 'regalo':
        return '🎁';
      case 'cosmético':
        return '💄';
      case 'alimento':
        return '🍎';
      case 'receta':
        return '🍲';
      case 'platillo':
        return '🍝';
      case 'experimento':
        return '🧪';
      case 'colección':
        return '🗄️';
      case 'web':
        return '🌐';
      case 'app':
        return '📱';
      default:
        return '✨'; // Default emoji
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    timeago.setLocaleMessages(
      'es',
      PocketPlusEsMessages(),
    ); // Use custom messages for Spanish

    return Card(
      elevation: 4.0, // Increased elevation for better contrast
      color: theme.cardColor, // Explicitly set card color
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 0,
      ), // Adjust as per design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // For image to respect rounded borders
      child: InkWell(
        onTap: () async {
          final result = await context.push(
            AppRoutes.contentDetailPath(item.id),
          );
          // Después de regresar de la página de detalles, invocar el callback de refresco si el resultado es true
          // Después de regresar de la página de detalles, invocar el callback de refresco
          // independientemente del resultado, ya que el estado del dashboard debe ser consistente.
          if (context.mounted) {
            onRefresh?.call();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imagenUrl != null && item.imagenUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: item.imagenUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getSubtypeEmoji(item.subtipo), // Display emoji
                            style: const TextStyle(
                              fontSize: 18,
                            ), // Adjust size as needed
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.subtipo.isNotEmpty
                                ? item.subtipo
                                : item.tipoGeneral.toString().split('.').last,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurface, // Use onSurface for better contrast
                              fontWeight: FontWeight.bold, // Make it bold
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ), // Increased horizontal padding
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            item.prioridad,
                            context,
                          ), // Solid color
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          item.prioridad
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                Colors.white, // White text for better contrast
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.titulo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.descripcion != null &&
                      item.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.descripcion!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (item.tags.isNotEmpty)
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: item.tags
                          .take(3)
                          .map(
                            (tag) => Chip(
                              // Show only first 3 tags
                              label: Text(tag.nombre),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ), // Adjusted padding
                              labelStyle: theme.textTheme.labelSmall?.copyWith(
                                color: theme
                                    .colorScheme
                                    .primary, // Use primary color for text
                                fontWeight: FontWeight.w500,
                              ),
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(
                                    0.1,
                                  ), // Lighter primary background
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  if (item.tags.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "+${item.tags.length - 3} más",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(item.fechaGuardado, locale: 'es'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
