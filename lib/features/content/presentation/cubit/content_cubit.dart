import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Para escuchar cambios de Auth y obtener User
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/features/content/domain/usecases/add_content_item.dart';
import 'package:pocket_plus/features/content/domain/usecases/create_tag.dart';
import 'package:pocket_plus/features/content/domain/usecases/delete_content_item.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_all_content_items.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_content_item_by_id.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_user_tags.dart';
import 'package:pocket_plus/features/content/domain/usecases/update_content_item.dart';
import 'package:pocket_plus/core/constants/content_types.dart'; // Para ContentTypeGeneral
import 'dart:io'; // Para File

part 'content_state.dart';

class ContentCubit extends Cubit<ContentState> {
  final GetAllContentItems getAllContentItemsUseCase;
  final GetContentItemById getContentItemByIdUseCase;
  final AddContentItem addContentItemUseCase;
  final UpdateContentItem updateContentItemUseCase;
  final DeleteContentItem deleteContentItemUseCase;
  final GetUserTags getUserTagsUseCase;
  final CreateTag createTagUseCase;
  final AuthCubit authCubit; // Para obtener el User y su ID

  String? _currentUserId;
  ContentLoaded? _lastListState; // Para mantener el último estado de lista

  ContentCubit({
    required this.getAllContentItemsUseCase,
    required this.getContentItemByIdUseCase,
    required this.addContentItemUseCase,
    required this.updateContentItemUseCase,
    required this.deleteContentItemUseCase,
    required this.getUserTagsUseCase,
    required this.createTagUseCase,
    required this.authCubit,
  }) : super(ContentInitial()) {
    // Escuchar cambios en AuthCubit para obtener el userId cuando el usuario se loguea
    authCubit.stream.listen((authState) {
      if (authState is AuthSuccess) {
        _currentUserId = authState.user.id;
        loadContent(); // Cargar contenido cuando el usuario está autenticado
      } else if (authState is AuthLoggedOut ||
          authState is AuthInitial && authState is! AuthLoading) {
        _currentUserId = null;
        emit(ContentInitial()); // Limpiar contenido si el usuario cierra sesión
      }
    });
    // Comprobar estado inicial de AuthCubit
    if (authCubit.state is AuthSuccess) {
      _currentUserId = (authCubit.state as AuthSuccess).user.id;
      loadContent();
    }
  }

  Future<void> loadContent() async {
    if (_currentUserId == null) {
      emit(const ContentFailure(message: "Usuario no autenticado."));
      return;
    }
    emit(const ContentLoading(message: "Cargando contenido..."));
    print(
      'DEBUG: Calling getAllContentItemsUseCase for user: $_currentUserId',
    ); // Added debug print

    final failureOrItems = await getAllContentItemsUseCase(
      GetAllContentItemsParams(userId: _currentUserId!),
    );
    final failureOrTags = await getUserTagsUseCase(
      GetUserTagsParams(userId: _currentUserId!),
    );

    // Manejar ambos resultados
    failureOrItems.fold(
      (failure) => emit(
        ContentFailure(message: "Error al cargar ítems: ${failure.message}"),
      ),
      (items) {
        failureOrTags.fold(
          (tagFailure) => emit(
            ContentFailure(
              message: "Error al cargar tags: ${tagFailure.message}",
            ),
          ),
          (tags) {
            // Aplicar filtros iniciales (ninguno por defecto) y ordenamiento
            final filtered = _applyFiltersAndSort(
              allItems: items,
              searchQuery: null,
              statusFilter: null,
              typeFilter: null,
              tagFilter: null,
              sortBy: SortContentBy.dateSavedDesc, // Orden inicial
            );
            final contentLoadedState = ContentLoaded(
              allItems: items,
              filteredItems: filtered,
              userTags: tags,
            );
            _lastListState = contentLoadedState; // Guardar referencia
            emit(contentLoadedState);
          },
        );
      },
    );
  }

  // Método para aplicar filtros y búsqueda (se llamará desde la UI o internamente)
  void applyFilters({
    String? searchQuery,
    ContentStatus? statusFilter,
    bool clearStatusFilter = false,
    ContentTypeGeneral? typeFilter,
    bool clearTypeFilter = false,
    Tag? tagFilter,
    bool clearTagFilter = false,
    SortContentBy? sortBy,
  }) {
    if (state is ContentLoaded) {
      final currentState = state as ContentLoaded;
      final newFilteredItems = _applyFiltersAndSort(
        allItems: currentState.allItems,
        searchQuery: searchQuery ?? currentState.searchQuery,
        statusFilter: clearStatusFilter
            ? null
            : statusFilter ?? currentState.activeStatusFilter,
        typeFilter: clearTypeFilter
            ? null
            : typeFilter ?? currentState.activeTypeFilter,
        tagFilter: clearTagFilter
            ? null
            : tagFilter ?? currentState.activeTagFilter,
        sortBy: sortBy ?? currentState.currentSortBy,
      );
      final updatedState = currentState.copyWith(
        filteredItems: newFilteredItems,
        searchQuery:
            searchQuery ??
            currentState
                .searchQuery, // Actualizar query de búsqueda en el estado
        activeStatusFilter: clearStatusFilter
            ? null
            : statusFilter ?? currentState.activeStatusFilter,
        clearActiveStatusFilter: clearStatusFilter,
        activeTypeFilter: clearTypeFilter
            ? null
            : typeFilter ?? currentState.activeTypeFilter,
        clearActiveTypeFilter: clearTypeFilter,
        activeTagFilter: clearTagFilter
            ? null
            : tagFilter ?? currentState.activeTagFilter,
        clearActiveTagFilter: clearTagFilter,
        currentSortBy: sortBy ?? currentState.currentSortBy,
      );
      _lastListState = updatedState; // Actualizar referencia
      emit(updatedState);
    }
  }

  List<ContentItem> _applyFiltersAndSort({
    required List<ContentItem> allItems,
    String? searchQuery,
    ContentStatus? statusFilter,
    ContentTypeGeneral? typeFilter,
    Tag? tagFilter,
    required SortContentBy sortBy,
  }) {
    List<ContentItem> itemsToFilter = List.from(allItems);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      itemsToFilter = itemsToFilter.where((item) {
        final query = searchQuery.toLowerCase();
        return item.titulo.toLowerCase().contains(query) ||
            (item.descripcion?.toLowerCase().contains(query) ?? false) ||
            item.tags.any((tag) => tag.nombre.toLowerCase().contains(query));
      }).toList();
    }
    if (statusFilter != null) {
      itemsToFilter = itemsToFilter
          .where((item) => item.estado == statusFilter)
          .toList();
    }
    if (typeFilter != null) {
      itemsToFilter = itemsToFilter
          .where((item) => item.tipoGeneral == typeFilter)
          .toList();
    }
    if (tagFilter != null) {
      itemsToFilter = itemsToFilter
          .where((item) => item.tags.any((t) => t.id == tagFilter.id))
          .toList();
    }

    // Aplicar ordenamiento
    switch (sortBy) {
      case SortContentBy.dateSavedDesc:
        itemsToFilter.sort(
          (a, b) => b.fechaGuardado.compareTo(a.fechaGuardado),
        );
        break;
      case SortContentBy.dateSavedAsc:
        itemsToFilter.sort(
          (a, b) => a.fechaGuardado.compareTo(b.fechaGuardado),
        );
        break;
      case SortContentBy.priority:
        // Alta (0) > Media (1) > Baja (2)
        itemsToFilter.sort(
          (a, b) => a.prioridad.index.compareTo(b.prioridad.index),
        );
        break;
      case SortContentBy.title:
        itemsToFilter.sort(
          (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()),
        );
        break;
    }
    return itemsToFilter;
  }

  Future<void> getContentDetails(String itemId) async {
    emit(ContentDetailLoading());
    final failureOrItem = await getContentItemByIdUseCase(
      Params(itemId: itemId),
    );
    failureOrItem.fold(
      (failure) => emit(
        ContentFailure(message: "Error al cargar detalle: ${failure.message}"),
      ),
      (item) => emit(ContentDetailLoaded(item: item)),
    );
  }

  // Método para volver al estado de lista desde el detalle
  void backToList() {
    print('🔄 backToList() called - Current state: ${state.runtimeType}');
    // Si estamos en ContentDetailLoaded, volver al último estado de lista guardado
    if (state is ContentDetailLoaded && _lastListState != null) {
      print(
        '📋 Restoring last list state with ${_lastListState!.filteredItems.length} items',
      );
      emit(_lastListState!);
    } else if (state is ContentDetailLoaded) {
      // Si no tenemos estado guardado, recargar
      print('🔄 No saved state, reloading content...');
      loadContent();
    } else {
      print('⚠️ backToList() called but not in ContentDetailLoaded state');
    }
  }

  Future<void> addNewContent({
    required ContentItem contentItemData, // Este ya debe tener usuarioId
    File? imageFile,
    List<String> newTagNames = const [], // Nombres de tags nuevos a crear
  }) async {
    if (_currentUserId == null) {
      emit(const ContentFailure(message: "Usuario no autenticado."));
      return;
    }
    emit(ContentOperationInProgress());

    // 1. Crear o reutilizar los tags nuevos si los hay
    List<Tag> createdAndExistingTags = List.from(
      contentItemData.tags,
    ); // Tags ya existentes seleccionados (ej. en modo edición)

    // Obtener tags actuales del usuario para verificar duplicados
    List<Tag> currentUserTags = [];
    if (state is ContentLoaded) {
      currentUserTags = (state as ContentLoaded).userTags;
    } else {
      // Si el estado no es ContentLoaded, recargar los tags
      final failureOrTags = await getUserTagsUseCase(
        GetUserTagsParams(userId: _currentUserId!),
      );
      failureOrTags.fold(
        (failure) =>
            print("Error al cargar tags existentes: ${failure.message}"),
        (tags) => currentUserTags = tags,
      );
    }

    if (newTagNames.isNotEmpty) {
      for (String tagName in newTagNames) {
        final trimmedTagName = tagName.trim();
        if (trimmedTagName.isEmpty) continue;

        // Verificar si el tag ya existe para el usuario
        final existingTag = currentUserTags.firstWhere(
          (t) => t.nombre.toLowerCase() == trimmedTagName.toLowerCase(),
          orElse: () =>
              const Tag(id: '', nombre: ''), // Placeholder para no encontrado
        );

        if (existingTag.id.isNotEmpty) {
          // El tag ya existe, añadirlo a la lista si no está ya
          if (!createdAndExistingTags.any((t) => t.id == existingTag.id)) {
            createdAndExistingTags.add(existingTag);
          }
        } else {
          // El tag no existe, intentar crearlo
          final failureOrTag = await createTagUseCase(
            CreateTagParams(name: trimmedTagName, userId: _currentUserId!),
          );
          failureOrTag.fold((failure) {
            // Si falla la creación (ej. por conflicto si otro proceso lo creó justo ahora),
            // intentar buscarlo de nuevo o simplemente loggear el error y continuar.
            // Por ahora, solo loggeamos y no añadimos el tag si falla la creación.
            print("Error creando tag '$trimmedTagName': ${failure.message}");
          }, (newTag) => createdAndExistingTags.add(newTag));
        }
      }
    }

    // Crear una instancia de ContentItem con los tags actualizados (incluyendo los nuevos)
    // y el usuarioId correcto.
    final itemToSave = ContentItem(
      id: '', // El backend generará el ID
      titulo: contentItemData.titulo,
      descripcion: contentItemData.descripcion,
      enlace: contentItemData.enlace,
      // imagenUrl se establecerá por el backend después de procesar imageFile
      tipoGeneral: contentItemData.tipoGeneral,
      subtipo: contentItemData.subtipo,
      prioridad: contentItemData.prioridad,
      estado: contentItemData.estado, // Usualmente 'pendiente' al crear
      fechaGuardado:
          DateTime.now(), // El cliente puede poner una fecha, o el backend
      fechaActualizacion: DateTime.now(),
      usuarioId: _currentUserId!,
      tags: createdAndExistingTags,
      notasPersonales: contentItemData.notasPersonales,
    );

    print('Attempting to add content item with title: ${itemToSave.titulo}');
    print('Link: ${itemToSave.enlace}');
    print('Tags: ${itemToSave.tags.map((t) => t.nombre).join(', ')}');

    final failureOrItem = await addContentItemUseCase(
      AddContentItemParams(contentItem: itemToSave, imageFile: imageFile),
    );

    failureOrItem.fold(
      (failure) => emit(ContentFailure(message: failure.message)),
      (newItem) {
        emit(
          ContentOperationSuccess(
            message: "Contenido añadido con éxito",
            item: newItem,
          ),
        );
        loadContent(); // Recargar la lista para reflejar el nuevo ítem
      },
    );
  }

  Future<void> updateExistingContent({
    required ContentItem contentItemData,
    File? imageFile,
    bool removeCurrentImage = false,
    List<String> newTagNames = const [],
  }) async {
    if (_currentUserId == null) {
      emit(const ContentFailure(message: "Usuario no autenticado."));
      return;
    }
    emit(ContentOperationInProgress());

    List<Tag> updatedTagsList = List.from(contentItemData.tags);
    if (newTagNames.isNotEmpty) {
      for (String tagName in newTagNames) {
        final failureOrTag = await createTagUseCase(
          CreateTagParams(name: tagName.trim(), userId: _currentUserId!),
        );
        failureOrTag.fold(
          (failure) => print(
            "Error creando tag '$tagName' durante actualización: ${failure.message}",
          ),
          (newTag) => updatedTagsList.add(newTag),
        );
      }
    }

    // El contentItemData ya debería tener el ID y otros campos correctos.
    // Solo actualizamos los tags y la fecha de actualización.
    final itemToUpdate = ContentItem(
      id: contentItemData.id,
      titulo: contentItemData.titulo,
      descripcion: contentItemData.descripcion,
      enlace: contentItemData.enlace,
      imagenUrl: contentItemData
          .imagenUrl, // Puede ser null si se va a cambiar o eliminar
      tipoGeneral: contentItemData.tipoGeneral,
      subtipo: contentItemData.subtipo,
      prioridad: contentItemData.prioridad,
      estado: contentItemData.estado,
      fechaGuardado: contentItemData.fechaGuardado,
      fechaActualizacion: DateTime.now(), // Actualizar fecha
      usuarioId: _currentUserId!,
      tags: updatedTagsList,
      notasPersonales: contentItemData.notasPersonales,
    );

    final failureOrItem = await updateContentItemUseCase(
      UpdateContentItemParams(
        contentItem: itemToUpdate,
        imageFile: imageFile,
        removeCurrentImage: removeCurrentImage,
      ),
    );
    failureOrItem.fold(
      (failure) => emit(ContentFailure(message: failure.message)),
      (updatedItem) {
        emit(
          ContentOperationSuccess(
            message: "Contenido actualizado con éxito",
            item: updatedItem,
          ),
        );
        loadContent(); // Recargar para ver cambios
      },
    );
  }

  Future<void> deleteContent(String itemId) async {
    emit(ContentOperationInProgress());
    final failureOrVoid = await deleteContentItemUseCase(
      DeleteContentItemParams(itemId: itemId),
    );
    failureOrVoid.fold(
      (failure) => emit(ContentFailure(message: failure.message)),
      (_) {
        emit(
          const ContentOperationSuccess(
            message: "Contenido eliminado con éxito",
          ),
        );
        loadContent(); // Recargar
      },
    );
  }

  // Helper para cambiar el estado de un ítem rápidamente (ej. marcar como completado)
  Future<void> updateContentStatus(
    ContentItem item,
    ContentStatus newStatus,
  ) async {
    final updatedItemData = ContentItem(
      id: item.id,
      titulo: item.titulo,
      descripcion: item.descripcion,
      enlace: item.enlace,
      imagenUrl: item.imagenUrl,
      tipoGeneral: item.tipoGeneral,
      subtipo: item.subtipo,
      prioridad: item.prioridad,
      estado: newStatus, // <-- Cambio aquí
      fechaGuardado: item.fechaGuardado,
      fechaActualizacion: DateTime.now(),
      usuarioId: item.usuarioId,
      tags: item.tags,
      notasPersonales: item.notasPersonales,
    );

    // No hay cambio de imagen ni de tags aquí, solo estado
    await updateExistingContent(contentItemData: updatedItemData);
  }
}
