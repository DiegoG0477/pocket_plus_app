import 'package:flutter/material.dart';
import 'package:pocket_plus/core/constants/content_types.dart'; // Donde está allContentSubtypes

class SubtypeSelectorGrid extends StatelessWidget {
  final String? selectedSubtypeName;
  final ValueChanged<ContentSubtype> onSubtypeSelected;

  const SubtypeSelectorGrid({
    super.key,
    this.selectedSubtypeName,
    required this.onSubtypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mapeo de subtipo a emoji (todos los subtipos)
    String getEmojiForSubtype(String name) {
      switch (name) {
        // Texto/Documentos
        case 'Artículo': return '📰';
        case 'Libro': return '📚';
        case 'Lista lectura': return '📝';
        case 'Noticia': return '🗞️';
        case 'PDF': return '📄';
        case 'Nota': return '🗒️';
        case 'Post': return '✉️';
        // Multimedia
        case 'Video': return '📹';
        case 'Película': return '🎬';
        case 'Podcast': return '🎧';
        case 'Música': return '🎵';
        case 'Juego': return '🎮';
        case 'Trailer': return '🎞️';
        // Productividad/Educación
        case 'Curso': return '🏫';
        case 'Técnica': return '🧠';
        case 'Productividad': return '✅';
        case 'Creativo': return '🎨';
        case 'Proyecto': return '📁';
        case 'Herramienta': return '🛠️';
        case 'Plugin': return '🧩';
        case 'Recurso': return '🧰';
        case 'Idea': return '💡';
        // Lugares/Eventos
        case 'Restaurante': return '🍽️';
        case 'Lugar': return '📍';
        case 'Actividad': return '🏃';
        case 'Hotel': return '🏨';
        case 'Evento': return '🎉';
        case 'Viaje': return '✈️';
        case 'Reunión': return '👥';
        // Compras
        case 'Producto': return '📦';
        case 'Tienda': return '🏪';
        case 'Regalo': return '🎁';
        case 'Cosmético': return '💄';
        // Comida
        case 'Alimento': return '🍞';
        case 'Receta': return '📖';
        case 'Platillo': return '🍽️';
        // Misceláneos
        case 'Experimento': return '🧪';
        case 'Colección': return '🗂️';
        case 'Web': return '🌐';
        case 'App': return '📱';
        case 'Otro': return '✨';
        default: return '🔖';
      }
    }

    return SizedBox(
      height: 220, // Altura estándar para el grid de subtipos
      child: GridView.builder(
        shrinkWrap: true, // Para que funcione dentro de un SingleChildScrollView
        physics: const ScrollPhysics(), // Permite scroll solo en el grid
        itemCount: allContentSubtypes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 columnas como en el maquetado
          childAspectRatio: 1.0, // Hace que los ítems sean cuadrados
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final subtype = allContentSubtypes[index];
          final bool isSelected = selectedSubtypeName == subtype.name;

          return InkWell(
            onTap: () => onSubtypeSelected(subtype),
            borderRadius: BorderRadius.circular(12.0),
            child: Card(
              elevation: isSelected ? 4.0 : 1.0,
              color: isSelected ? theme.colorScheme.primaryContainer : theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getEmojiForSubtype(subtype.name),
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtype.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}