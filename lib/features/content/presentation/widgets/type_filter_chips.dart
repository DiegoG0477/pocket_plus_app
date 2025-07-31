import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Para context.watch
import 'package:pocket_plus/core/constants/content_types.dart'; // Donde definimos ContentTypeGeneral
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart'; // Para el Cubit

class TypeFilterChips extends StatelessWidget {
  const TypeFilterChips({super.key});

  // Mapeo de ContentTypeGeneral a nombres amigables para mostrar en la UI
  static const Map<ContentTypeGeneral, String> _contentTypeDisplayNames = {
    ContentTypeGeneral.texto: "Texto",
    ContentTypeGeneral.multimedia: "Multimedia",
    ContentTypeGeneral.productividad: "Productividad",
    ContentTypeGeneral.ubicacion: "Ubicación",
    ContentTypeGeneral.compra: "Compra",
    ContentTypeGeneral.comida: "Comida",
    ContentTypeGeneral.evento: "Evento",
    ContentTypeGeneral.enlace: "Enlace",
    ContentTypeGeneral.otro: "Otro",
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentCubit = context.watch<ContentCubit>();
    final currentLoadedState = contentCubit.state is ContentLoaded
        ? (contentCubit.state as ContentLoaded)
        : null;
    final activeTypeFilter = currentLoadedState?.activeTypeFilter;

    // Construir la lista de chips dinámicamente
    List<Widget> chips = [];

    // Añadir el chip "Todos"
    chips.add(
      Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: FilterChip(
          label: const Text("Todos"),
          selected: activeTypeFilter == null,
          onSelected: (bool selected) {
            if (selected) {
              contentCubit.applyFilters(clearTypeFilter: true);
            }
          },
          backgroundColor: activeTypeFilter == null
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          selectedColor: theme.colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: activeTypeFilter == null
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: activeTypeFilter == null
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 13,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          visualDensity: VisualDensity.compact,
          checkmarkColor: activeTypeFilter == null
              ? theme.colorScheme.onPrimaryContainer
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: activeTypeFilter == null
                  ? theme.colorScheme.primaryContainer
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
      ),
    );

    // Añadir chips para cada ContentTypeGeneral
    for (var type in ContentTypeGeneral.values) {
      final label =
          _contentTypeDisplayNames[type] ??
          type.name; // Fallback a .name if not in map
      final bool isSelected = activeTypeFilter == type;

      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                contentCubit.applyFilters(typeFilter: type);
              } else {
                // If the currently selected chip is deselected, clear the filter
                contentCubit.applyFilters(clearTypeFilter: true);
              }
            },
            backgroundColor: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            selectedColor: theme.colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            visualDensity: VisualDensity.compact,
            checkmarkColor: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(children: chips),
    );
  }
}
