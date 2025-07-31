part of 'add_content_cubit.dart';

enum AddContentFormStatus {
  initial,
  submitting,
  success,
  failure,
  loadingItem,
} // Para cargar item en modo edición

class AddContentState extends Equatable {
  final AddContentFormStatus status;
  final ContentItem? initialItem; // Para modo edición
  final String? selectedSubtypeName;
  final String title;
  final String link;
  final String description;
  final ContentPriority priority;
  final List<Tag> selectedTags; // Lista de tags seleccionados
  final List<Tag> availableTags; // Tags disponibles para seleccionar
  final File? imageFile; // Archivo de imagen seleccionado
  final bool
  removeExistingImage; // Flag para indicar si se debe eliminar la imagen existente
  final String? errorMessage;
  final bool isEditMode;

  const AddContentState({
    this.status = AddContentFormStatus.initial,
    this.initialItem,
    this.selectedSubtypeName,
    this.title = '',
    this.link = '',
    this.description = '',
    this.priority = ContentPriority.media,
    this.selectedTags = const [], // Inicializar como lista vacía
    this.availableTags = const [], // Inicializar como lista vacía
    this.imageFile,
    this.removeExistingImage = false, // Por defecto no eliminar
    this.errorMessage,
    this.isEditMode = false,
  });

  // Helper para saber si el formulario es válido (simplificado)
  bool get isFormValid =>
      selectedSubtypeName != null &&
      selectedSubtypeName!.isNotEmpty &&
      title.isNotEmpty;

  AddContentState copyWith({
    AddContentFormStatus? status,
    ContentItem? initialItem,
    String? selectedSubtypeName,
    bool clearSelectedSubtypeName = false,
    String? title,
    String? link,
    String? description,
    ContentPriority? priority,
    List<Tag>? selectedTags, // Ahora es List<Tag>
    List<Tag>? availableTags, // Nuevo campo
    File? imageFile,
    bool clearImageFile = false, // Para poder quitar la imagen seleccionada
    bool? removeExistingImage, // Nuevo campo
    String? errorMessage,
    bool? isEditMode,
  }) {
    return AddContentState(
      status: status ?? this.status,
      initialItem: initialItem ?? this.initialItem,
      selectedSubtypeName: clearSelectedSubtypeName
          ? null
          : selectedSubtypeName ?? this.selectedSubtypeName,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      selectedTags:
          selectedTags ?? this.selectedTags, // Actualizar selectedTags
      availableTags:
          availableTags ?? this.availableTags, // Actualizar availableTags
      imageFile: clearImageFile ? null : imageFile ?? this.imageFile,
      removeExistingImage:
          removeExistingImage ?? this.removeExistingImage, // Actualizar
      errorMessage:
          errorMessage, // No se propaga el error, se establece nuevo o se limpia
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    initialItem,
    selectedSubtypeName,
    title,
    link,
    description,
    priority,
    selectedTags, // Actualizar props
    availableTags, // Actualizar props
    imageFile,
    errorMessage,
    isEditMode,
  ];
}
