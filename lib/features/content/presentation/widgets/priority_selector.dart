import 'package:flutter/material.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart'; // Para ContentPriority

class PrioritySelector extends StatelessWidget {
  final ContentPriority selectedPriority;
  final ValueChanged<ContentPriority> onPrioritySelected;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildChip(ContentPriority priority, String label) {
      final bool isSelected = selectedPriority == priority;
      Color getPriorityBgColor() {
        switch (priority) {
          case ContentPriority.alta:
            return const Color(0xFF90CAF9); // Azul pastel
          case ContentPriority.media:
            return const Color(0xFFFFF59D); // Amarillo pastel
          case ContentPriority.baja:
            return const Color(0xFFC8E6C9); // Verde pastel
          default:
            return theme.colorScheme.surfaceVariant.withOpacity(0.5);
        }
      }
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: FilterChip(
            label: Center(child: Text(label)),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) { // Solo reacciona si se selecciona, no al deseleccionar
                onPrioritySelected(priority);
              }
            },
            showCheckmark: false,
            backgroundColor: isSelected ? getPriorityBgColor() : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            selectedColor: getPriorityBgColor(),
            labelStyle: TextStyle(
              color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: isSelected ? getPriorityBgColor() : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildChip(ContentPriority.alta, 'Alta'),
        buildChip(ContentPriority.media, 'Media'),
        buildChip(ContentPriority.baja, 'Baja'),
      ],
    );
  }
}