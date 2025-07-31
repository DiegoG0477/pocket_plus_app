import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/constants/content_types.dart'; // Para getIconForSubtypeName
import 'package:pocket_plus/core/router/app_routes.dart'; // Para AppRoutes
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart'; // Para abrir enlaces

class ContentDetailPage extends StatefulWidget {
  final String itemId;

  const ContentDetailPage({super.key, required this.itemId});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    // Solicitar los detalles del ítem al ContentCubit
    context.read<ContentCubit>().getContentDetails(widget.itemId);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateNotes(ContentItem item) {
    // Aquí podríamos tener un debounce o guardar al perder el foco.
    // Por ahora, asumimos que se guarda al salir de la pantalla o con un botón explícito (no presente en el maquetado)
    // o que el botón de "Marcar como completado/descartado" también guarda las notas.
    // Para simplificar, la edición de notas se reflejará en el estado del item en el Cubit
    // y se guardará cuando se actualice el item por otra razón (ej. cambio de estado).

    // O mejor, tener un botón de guardar notas o un guardado automático.
    // Por ahora, solo actualizaremos el Cubit si el item se modifica por otra acción.
    // Si quisiéramos guardar solo las notas:
    /*
    final updatedItem = item.copyWith(
      notasPersonales: _notesController.text,
      fechaActualizacion: DateTime.now(),
    );
    context.read<ContentCubit>().updateExistingContent(contentItemData: updatedItemData);
    */
    print(
      "Notas actualizadas (localmente en controller): ${_notesController.text}",
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    timeago.setLocaleMessages('es', timeago.EsMessages());

    return Scaffold(
      body: BlocConsumer<ContentCubit, ContentState>(
        listener: (context, state) {
          if (state is ContentOperationSuccess &&
              state.message.contains("actualizado")) {
            // Si el ítem se actualizó (ej. cambio de estado), recargar los detalles
            // para asegurar que la UI refleje el item más reciente del backend.
            // O si `state.item` está presente y es el correcto, usarlo directamente.
            if (state.item != null && state.item!.id == widget.itemId) {
              _notesController.text = state.item!.notasPersonales ?? '';
            } else {
              context.read<ContentCubit>().getContentDetails(widget.itemId);
            }
          } else if (state is ContentOperationSuccess &&
              state.message.contains("eliminado")) {
            // Si el ítem fue eliminado, volver al dashboard
            if (context.canPop())
              context.pop();
            else
              context.go(AppRoutes.dashboard);
          }
        },
        // listenWhen: (previous, current) => current is ContentOperationSuccess || current is ContentDetailLoaded,
        buildWhen: (previous, current) =>
            current is ContentDetailLoading ||
            current is ContentDetailLoaded ||
            current is ContentFailure,
        builder: (context, state) {
          if (state is ContentDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContentDetailLoaded) {
            final item = state.item;
            // Asignar notas al controlador solo si es la primera vez o el item cambió
            if (_notesController.text != (item.notasPersonales ?? '')) {
              _notesController.text = item.notasPersonales ?? '';
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 1,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(true), // Pass true as a result
                  ),
                  title: Row(
                    children: [
                      Icon(getIconForSubtypeName(item.subtipo), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        // Wrap with Expanded to prevent overflow
                        child: Text(
                          item.subtipo,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    // TODO: Implementar acción de compartir
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'Compartir',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Compartir no implementado'),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      onPressed: () {
                        // Navegar a AddContentPage en modo edición, pasando el item.id o el item completo
                        context.push(AppRoutes.editContentPath(item.id));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Eliminar',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar Eliminación'),
                            content: const Text(
                              '¿Estás seguro de que deseas eliminar este elemento? Esta acción no se puede deshacer.',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                              TextButton(
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  context.read<ContentCubit>().deleteContent(
                                    item.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Chip(
                        label: Text(
                          item.prioridad
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getPriorityColor(item.prioridad, context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getPriorityColor(
                          item.prioridad,
                          context,
                        ).withOpacity(0.15),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.imagenUrl != null &&
                            item.imagenUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: item.imagenUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          item.titulo,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (item.descripcion != null &&
                            item.descripcion!.isNotEmpty) ...[
                          Text(
                            item.descripcion!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (item.enlace != null && item.enlace!.isNotEmpty) ...[
                          InkWell(
                            onTap: () => _launchUrl(item.enlace!),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Abrir enlace',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Guardado ${timeago.format(item.fechaGuardado, locale: 'es')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (item.tags.isNotEmpty) ...[
                          Text(
                            'Tags',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: item.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag.nombre),
                                    backgroundColor:
                                        theme.chipTheme.backgroundColor
                                            ?.withOpacity(0.7) ??
                                        theme.colorScheme.surfaceVariant
                                            .withOpacity(0.7),
                                    side: BorderSide.none,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Text(
                          'Notas',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe tus notas personales aquí...',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            maxLines: null, // Permite múltiples líneas
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            onChanged: (text) {
                              // Podríamos tener lógica de autoguardado aquí o simplemente permitir que el usuario edite
                              // y luego, si cambia el estado del item (completado/descartado), estas notas se envían
                            },
                            // onEditingComplete: () => _updateNotes(item), // Opcional
                            // onSubmitted: (_) => _updateNotes(item), // Opcional
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (item.estado != ContentStatus.completado)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Marcar como completado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context
                                    .read<ContentCubit>()
                                    .updateContentStatus(
                                      item.copyWith(
                                        notasPersonales: _notesController.text,
                                      ), // Enviar notas actualizadas
                                      ContentStatus.completado,
                                    );
                              },
                            ),
                          ),
                        if (item.estado != ContentStatus.completado &&
                            item.estado != ContentStatus.descartado)
                          const SizedBox(height: 12),

                        if (item.estado != ContentStatus.descartado)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Marcar como descartado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[600],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context
                                    .read<ContentCubit>()
                                    .updateContentStatus(
                                      item.copyWith(
                                        notasPersonales: _notesController.text,
                                      ), // Enviar notas actualizadas
                                      ContentStatus.descartado,
                                    );
                              },
                            ),
                          ),
                        if (item.estado == ContentStatus.completado ||
                            item.estado == ContentStatus.descartado) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.undo_outlined),
                              label: const Text('Marcar como pendiente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[700],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context
                                    .read<ContentCubit>()
                                    .updateContentStatus(
                                      item.copyWith(
                                        notasPersonales: _notesController.text,
                                      ),
                                      ContentStatus.pendiente,
                                    );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is ContentFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ContentCubit>()
                        .getContentDetails(widget.itemId),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink(); // Estado inicial o no manejado
        },
      ),
    );
  }
}
