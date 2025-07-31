part of 'content_cubit.dart';

// Enum para los filtros del dashboard
enum ContentListFilter { all, byStatus, byType, byTag }
enum SortContentBy { dateSavedDesc, dateSavedAsc, priority, title } // Opciones de ordenamiento

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {
  final String? message; // Opcional, para mostrar un mensaje específico durante la carga
  const ContentLoading({this.message});
   @override
  List<Object?> get props => [message];
}

// Estado principal cuando los datos están cargados
class ContentLoaded extends ContentState {
  final List<ContentItem> allItems; // Todos los ítems obtenidos del backend
  final List<ContentItem> filteredItems; // Ítems después de aplicar filtros y búsqueda
  final List<Tag> userTags; // Todos los tags del usuario para los filtros
  
  // Filtros activos
  final String? searchQuery;
  final ContentStatus? activeStatusFilter;
  final ContentTypeGeneral? activeTypeFilter;
  final Tag? activeTagFilter;
  final SortContentBy currentSortBy;

  const ContentLoaded({
    required this.allItems,
    required this.filteredItems,
    required this.userTags,
    this.searchQuery,
    this.activeStatusFilter,
    this.activeTypeFilter,
    this.activeTagFilter,
    this.currentSortBy = SortContentBy.dateSavedDesc,
  });

  @override
  List<Object?> get props => [
        allItems,
        filteredItems,
        userTags,
        searchQuery,
        activeStatusFilter,
        activeTypeFilter,
        activeTagFilter,
        currentSortBy,
      ];

  ContentLoaded copyWith({
    List<ContentItem>? allItems,
    List<ContentItem>? filteredItems,
    List<Tag>? userTags,
    String? searchQuery,
    ContentStatus? activeStatusFilter,
    bool clearActiveStatusFilter = false, // Para poder limpiar el filtro
    ContentTypeGeneral? activeTypeFilter,
    bool clearActiveTypeFilter = false,
    Tag? activeTagFilter,
    bool clearActiveTagFilter = false,
    SortContentBy? currentSortBy,
  }) {
    return ContentLoaded(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      userTags: userTags ?? this.userTags,
      searchQuery: searchQuery ?? this.searchQuery,
      activeStatusFilter: clearActiveStatusFilter ? null : activeStatusFilter ?? this.activeStatusFilter,
      activeTypeFilter: clearActiveTypeFilter ? null : activeTypeFilter ?? this.activeTypeFilter,
      activeTagFilter: clearActiveTagFilter ? null : activeTagFilter ?? this.activeTagFilter,
      currentSortBy: currentSortBy ?? this.currentSortBy,
    );
  }
}

// Estado para cuando se está obteniendo un solo ítem (detalle)
class ContentDetailLoading extends ContentState {}

class ContentDetailLoaded extends ContentState {
  final ContentItem item;
  const ContentDetailLoaded({required this.item});
  @override
  List<Object?> get props => [item];
}

// Estados para operaciones CRUD (añadir, editar, borrar)
class ContentOperationInProgress extends ContentState {} // Para CUD

class ContentOperationSuccess extends ContentState {
  final String message;
  final ContentItem? item; // Opcional, el ítem modificado/creado
  const ContentOperationSuccess({required this.message, this.item});
  @override
  List<Object?> get props => [message, item];
}

class ContentFailure extends ContentState {
  final String message;
  const ContentFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
