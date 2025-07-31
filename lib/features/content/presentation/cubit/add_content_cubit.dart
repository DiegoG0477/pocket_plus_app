import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/core/constants/content_types.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart';
import 'package:pocket_plus/features/content/data/models/tag_model.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_user_tags.dart';
import 'package:pocket_plus/features/content/domain/usecases/create_tag.dart'; // Importar CreateTagParams
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart';
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Importar AuthSuccess

part 'add_content_state.dart';

class AddContentCubit extends Cubit<AddContentState> {
  final ContentCubit _contentCubit;
  final GetUserTags _getUserTagsUseCase;
  final String? _itemIdToEdit;

  AddContentCubit({
    required ContentCubit contentCubit,
    required GetUserTags getUserTagsUseCase,
    String? itemIdToEdit,
  }) : _contentCubit = contentCubit,
       _getUserTagsUseCase = getUserTagsUseCase,
       _itemIdToEdit = itemIdToEdit,
       super(const AddContentState()) {
    _init();
  }

  Future<void> _init() async {
    await _loadAvailableTags();
    if (_itemIdToEdit != null) {
      await _loadItemForEditing(_itemIdToEdit);
    }
  }

  Future<void> _loadAvailableTags() async {
    final currentUserId = _contentCubit.authCubit.state is AuthSuccess
        ? (_contentCubit.authCubit.state as AuthSuccess).user.id
        : null;

    if (currentUserId == null) {
      emit(
        state.copyWith(
          errorMessage: "Usuario no autenticado para cargar tags.",
        ),
      );
      return;
    }

    final failureOrTags = await _getUserTagsUseCase(
      GetUserTagsParams(userId: currentUserId),
    );
    failureOrTags.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: "Error al cargar tags disponibles: ${failure.message}",
        ),
      ),
      (tags) => emit(state.copyWith(availableTags: tags)),
    );
  }

  Future<void> _loadItemForEditing(String? itemId) async {
    if (itemId == null) return;
    emit(
      state.copyWith(
        status: AddContentFormStatus.loadingItem,
        isEditMode: true,
      ),
    );

    final contentState = _contentCubit.state;
    ContentItem? itemToEdit;

    if (contentState is ContentLoaded) {
      try {
        itemToEdit = contentState.allItems.firstWhere(
          (item) => item.id == itemId,
        );
      } catch (_) {
        /* Item no encontrado en la lista actual */
      }
    }

    if (itemToEdit == null &&
        contentState is ContentDetailLoaded &&
        contentState.item.id == itemId) {
      itemToEdit = contentState.item;
    }

    if (itemToEdit != null) {
      emit(
        state.copyWith(
          status: AddContentFormStatus.initial,
          initialItem: itemToEdit,
          selectedSubtypeName: itemToEdit.subtipo,
          title: itemToEdit.titulo,
          link: itemToEdit.enlace ?? '',
          description: itemToEdit.descripcion ?? '',
          priority: itemToEdit.prioridad,
          selectedTags: itemToEdit.tags, // Usar selectedTags
          isEditMode: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AddContentFormStatus.failure,
          errorMessage: "No se pudo cargar el ítem para editar.",
        ),
      );
    }
  }

  void subtypeSelected(ContentSubtype subtype) {
    emit(state.copyWith(selectedSubtypeName: subtype.name));
  }

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void linkChanged(String value) {
    emit(state.copyWith(link: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void priorityChanged(ContentPriority value) {
    emit(state.copyWith(priority: value));
  }

  void addTag(Tag tag) {
    if (!state.selectedTags.any((t) => t.id == tag.id)) {
      emit(
        state.copyWith(selectedTags: List.from(state.selectedTags)..add(tag)),
      );
    }
  }

  void removeTag(Tag tag) {
    emit(
      state.copyWith(
        selectedTags: state.selectedTags.where((t) => t.id != tag.id).toList(),
      ),
    );
  }

  Future<void> createAndAddTag(String tagName) async {
    if (tagName.trim().isEmpty) return;

    final currentUserId = _contentCubit.authCubit.state is AuthSuccess
        ? (_contentCubit.authCubit.state as AuthSuccess).user.id
        : null;

    if (currentUserId == null) {
      emit(
        state.copyWith(errorMessage: "Usuario no autenticado para crear tags."),
      );
      return;
    }

    // Verificar si el tag ya existe en la lista de disponibles
    final existingTag = state.availableTags.firstWhere(
      (t) => t.nombre.toLowerCase() == tagName.trim().toLowerCase(),
      orElse: () => const TagModel(id: '', nombre: ''),
    );

    if (existingTag.id.isNotEmpty) {
      // Si ya existe, simplemente añadirlo a los seleccionados
      addTag(existingTag);
    } else {
      // Si no existe, intentar crearlo
      emit(
        state.copyWith(status: AddContentFormStatus.submitting),
      ); // O un estado más específico
      final failureOrTag = await _contentCubit.createTagUseCase(
        CreateTagParams(name: tagName.trim(), userId: currentUserId),
      );
      failureOrTag.fold(
        (failure) => emit(
          state.copyWith(
            errorMessage: "Error al crear tag: ${failure.message}",
            status: AddContentFormStatus.failure,
          ),
        ),
        (newTag) {
          addTag(newTag); // Añadir el nuevo tag a los seleccionados
          _loadAvailableTags(); // Recargar la lista de tags disponibles
          emit(
            state.copyWith(status: AddContentFormStatus.initial),
          ); // Volver a estado inicial
        },
      );
    }
  }

  void imageSelected(File? image) {
    emit(state.copyWith(imageFile: image, clearImageFile: image == null));
  }

  void clearImage() {
    emit(
      state.copyWith(imageFile: null, removeExistingImage: true),
    ); // Actualizar para eliminar imagen existente
  }

  Future<void> submitForm() async {
    emit(
      state.copyWith(
        status: AddContentFormStatus.submitting,
        errorMessage: null,
      ),
    );

    if (state.selectedSubtypeName == null ||
        state.selectedSubtypeName!.isEmpty) {
      emit(
        state.copyWith(
          status: AddContentFormStatus.failure,
          errorMessage: "Por favor, selecciona un subtipo de contenido.",
        ),
      );
      return;
    }

    print('Debug: selectedSubtypeName: ${state.selectedSubtypeName}');

    final contentItemData = ContentItem(
      id: state.isEditMode ? state.initialItem!.id : '',
      titulo: state.title,
      descripcion: state.description.isNotEmpty ? state.description : null,
      enlace: state.link.isNotEmpty ? state.link : null,
      imagenUrl:
          (state.isEditMode &&
              state.imageFile == null &&
              !state.removeExistingImage)
          ? state.initialItem?.imagenUrl
          : null,
      tipoGeneral: getGeneralTypeForSubtypeName(state.selectedSubtypeName!),
      subtipo: state.selectedSubtypeName!,
      prioridad: state.priority,
      estado: state.isEditMode
          ? state.initialItem!.estado
          : ContentStatus.pendiente,
      fechaGuardado: state.isEditMode
          ? state.initialItem!.fechaGuardado
          : DateTime.now(),
      fechaActualizacion: DateTime.now(),
      usuarioId: '', // El ContentCubit principal lo asignará
      tags: state.selectedTags, // Usar la lista de tags seleccionados
      notasPersonales: state.isEditMode
          ? state.initialItem?.notasPersonales
          : null,
    );

    try {
      if (state.isEditMode) {
        await _contentCubit.updateExistingContent(
          contentItemData: contentItemData,
          imageFile: state.imageFile,
          removeCurrentImage: state.removeExistingImage, // Pasar el flag
        );
      } else {
        await _contentCubit.addNewContent(
          contentItemData: contentItemData,
          imageFile: state.imageFile,
        );
      }
      emit(state.copyWith(status: AddContentFormStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddContentFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
