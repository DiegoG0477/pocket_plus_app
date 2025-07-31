import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes
import 'package:cached_network_image/cached_network_image.dart'; // Importar CachedNetworkImage
import 'package:pocket_plus/core/constants/content_types.dart';
import 'package:pocket_plus/core/router/app_routes.dart';
import 'package:pocket_plus/features/content/domain/entities/content_item.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart'; // Import Tag entity
import 'package:pocket_plus/features/content/presentation/cubit/add_content_cubit.dart';
import 'package:pocket_plus/features/content/presentation/widgets/priority_selector.dart';
import 'package:pocket_plus/features/content/presentation/widgets/subtype_selector_grid.dart';
import 'package:get_it/get_it.dart'; // Para obtener el Cubit

class AddContentPage extends StatelessWidget {
  final String? itemId; // Null si es para crear, con valor si es para editar

  const AddContentPage({super.key, this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddContentCubit>(
      create: (context) => GetIt.I.get<AddContentCubit>(param1: itemId),
      child: const _AddContentView(),
    );
  }
}

class _AddContentView extends StatefulWidget {
  const _AddContentView();

  @override
  State<_AddContentView> createState() => _AddContentViewState();
}

class _AddContentViewState extends State<_AddContentView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Removed _tagsController

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Escuchar el estado inicial para poblar los controladores si es modo edición
    final initialState = context.read<AddContentCubit>().state;
    if (initialState.isEditMode && initialState.initialItem != null) {
      _titleController.text = initialState.title;
      _linkController.text = initialState.link;
      _descriptionController.text = initialState.description;
      // _tagsController.text = initialState.tagsString; // Removed
    }

    _titleController.addListener(
      () => context.read<AddContentCubit>().titleChanged(_titleController.text),
    );
    _linkController.addListener(
      () => context.read<AddContentCubit>().linkChanged(_linkController.text),
    );
    _descriptionController.addListener(
      () => context.read<AddContentCubit>().descriptionChanged(
        _descriptionController.text,
      ),
    );
    // _tagsController.addListener(() => context.read<AddContentCubit>().tagsChanged(_tagsController.text)); // Removed
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    // _tagsController.dispose(); // Removed
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      context.read<AddContentCubit>().imageSelected(File(pickedFile.path));
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  // New method to show tag selection dialog
  Future<void> _showTagSelectionDialog(BuildContext context) async {
    final cubit = context.read<AddContentCubit>();
    final state = cubit.state;

    TextEditingController newTagController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Seleccionar o crear Tags'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Input para nuevo tag
                TextField(
                  controller: newTagController,
                  decoration: InputDecoration(
                    hintText: 'Nuevo tag',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (newTagController.text.isNotEmpty) {
                          cubit.createAndAddTag(newTagController.text);
                          newTagController.clear();
                          Navigator.of(
                            dialogContext,
                          ).pop(); // Cerrar diálogo después de crear
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      cubit.createAndAddTag(value);
                      newTagController.clear();
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Lista de tags disponibles
                if (state.availableTags.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tags existentes:',
                        style: Theme.of(dialogContext).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: state.availableTags.map((tag) {
                          final isSelected = state.selectedTags.any(
                            (t) => t.id == tag.id,
                          );
                          return FilterChip(
                            label: Text(tag.nombre),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                cubit.addTag(tag);
                              } else {
                                cubit.removeTag(tag);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  )
                else
                  const Text('No hay tags disponibles. Crea uno nuevo.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final primaryColor = theme.colorScheme.primary; // Not used directly anymore

    return BlocConsumer<AddContentCubit, AddContentState>(
      listener: (context, state) {
        if (state.status == AddContentFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
        } else if (state.status == AddContentFormStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.isEditMode
                      ? 'Contenido actualizado'
                      : 'Contenido guardado',
                ),
                backgroundColor: Colors.green,
              ),
            );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.dashboard);
          }
        }
        // Si es modo edición y el estado cambia, repopular controladores
        if (state.isEditMode && state.initialItem != null) {
          if (_titleController.text != state.title)
            _titleController.text = state.title;
          if (_linkController.text != state.link)
            _linkController.text = state.link;
          if (_descriptionController.text != state.description)
            _descriptionController.text = state.description;
          // _tagsController.text = state.tagsString; // Removed
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddContentCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.isEditMode ? 'Editar contenido' : 'Agregar contenido',
            ),
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Tipo de contenido*'),
                  SubtypeSelectorGrid(
                    selectedSubtypeName: state.selectedSubtypeName,
                    onSubtypeSelected: (subtype) =>
                        cubit.subtypeSelected(subtype),
                  ),
                  if (state.selectedSubtypeName == null &&
                      state.status == AddContentFormStatus.failure)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Por favor, selecciona un tipo.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  _buildSectionTitle(context, 'Título*'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Título del contenido',
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'El título es requerido'
                        : null,
                  ),

                  _buildSectionTitle(context, 'Enlace (opcional)'),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      hintText: 'https://...',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                  ),

                  _buildSectionTitle(context, 'Descripción (opcional)'),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Agrega notas o comentarios...',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),

                  _buildSectionTitle(context, 'Prioridad'),
                  PrioritySelector(
                    selectedPriority: state.priority,
                    onPrioritySelected: (priority) =>
                        cubit.priorityChanged(priority),
                  ),

                  _buildSectionTitle(context, 'Imagen (opcional)'),
                  if (state.imageFile != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            state.imageFile!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          onPressed: () => cubit.clearImage(),
                        ),
                      ],
                    )
                  else if (state.isEditMode &&
                      state.initialItem?.imagenUrl != null &&
                      state.initialItem!.imagenUrl!.isNotEmpty)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            // Mostrar imagen existente si está en modo edición
                            imageUrl: state.initialItem!.imagenUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              height: 150,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) =>
                                const SizedBox(
                                  height: 150,
                                  child: Icon(Icons.error),
                                ),
                          ),
                        ),
                        if (state.initialItem?.imagenUrl != null &&
                            state.initialItem!.imagenUrl!.isNotEmpty &&
                            !state.removeExistingImage)
                          IconButton(
                            icon: const CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            onPressed: () => cubit
                                .clearImage(), // This will set removeExistingImage to true
                          ),
                      ],
                    ),

                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      state.imageFile != null ||
                              (state.isEditMode &&
                                  state.initialItem?.imagenUrl != null &&
                                  !state.removeExistingImage)
                          ? 'Cambiar imagen'
                          : 'Adjuntar imagen',
                    ),
                    onPressed: _pickImage,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        40,
                      ), // Para que ocupe el ancho
                    ),
                  ),

                  _buildSectionTitle(context, 'Tags'),
                  // Display selected tags
                  if (state.selectedTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: state.selectedTags.map((tag) {
                          return Chip(
                            label: Text(tag.nombre),
                            onDeleted: () => cubit.removeTag(tag),
                          );
                        }).toList(),
                      ),
                    ),
                  // Button to add/select tags
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar/Seleccionar Tags'),
                    onPressed: () => _showTagSelectionDialog(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              state.status == AddContentFormStatus.submitting
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate() &&
                                      state.isFormValid) {
                                    cubit.submitForm();
                                  } else if (!state.isFormValid) {
                                    // Forzar un error si el tipo no está seleccionado,
                                    // ya que no es parte del _formKey.currentState.validate()
                                    cubit.emit(
                                      state.copyWith(
                                        status: AddContentFormStatus.failure,
                                        errorMessage:
                                            "Por favor, selecciona un tipo de contenido.",
                                      ),
                                    );
                                  }
                                },
                          child: state.status == AddContentFormStatus.submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  state.isEditMode
                                      ? 'Guardar Cambios'
                                      : 'Guardar',
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
