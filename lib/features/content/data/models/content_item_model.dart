import 'package:pocket_plus/features/content/domain/entities/content_item.dart'; // Ajusta ruta
import 'package:pocket_plus/features/content/data/models/tag_model.dart'; // Ajusta ruta
import 'package:pocket_plus/features/content/domain/entities/tag.dart'; // Explicitly import Tag
import 'package:pocket_plus/core/constants/content_types.dart'; // Para ContentTypeGeneral

// Helper para enums <-> String
String _priorityToString(ContentPriority p) => p.toString().split('.').last;
ContentPriority _priorityFromString(String s) =>
    ContentPriority.values.firstWhere(
      (e) => e.toString().split('.').last == s,
      orElse: () => ContentPriority.media,
    );

String _statusToString(ContentStatus s) => s.toString().split('.').last;
ContentStatus _statusFromString(String s) => ContentStatus.values.firstWhere(
  (e) => e.toString().split('.').last == s,
  orElse: () => ContentStatus.pendiente,
);

String _typeToString(ContentTypeGeneral t) => t.toString().split('.').last;
ContentTypeGeneral _typeFromString(String s) =>
    ContentTypeGeneral.values.firstWhere(
      (e) => e.toString().split('.').last == s,
      orElse: () => ContentTypeGeneral.otro,
    );

class ContentItemModel extends ContentItem {
  ContentItemModel({
    required String id,
    required String titulo,
    String? descripcion,
    String? enlace,
    String? imagenUrl,
    required ContentTypeGeneral tipoGeneral,
    required String subtipo,
    required ContentPriority prioridad,
    required ContentStatus estado,
    required DateTime fechaGuardado,
    required DateTime fechaActualizacion,
    required String usuarioId,
    List<TagModel> tags = const [],
    String? notasPersonales,
  }) : super(
         id: id,
         titulo: titulo,
         descripcion: descripcion,
         enlace: enlace,
         imagenUrl: imagenUrl,
         tipoGeneral: tipoGeneral,
         subtipo: subtipo,
         prioridad: prioridad,
         estado: estado,
         fechaGuardado: fechaGuardado,
         fechaActualizacion: fechaActualizacion,
         usuarioId: usuarioId,
         tags: tags.cast<Tag>(), // Cast to List<Tag> for the super constructor
         notasPersonales: notasPersonales,
       );

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    var tagsFromJson = json['tags'] as List<dynamic>?;
    List<TagModel> tagsList = tagsFromJson != null
        ? tagsFromJson
              .map(
                (tagJson) => TagModel.fromJson(tagJson as Map<String, dynamic>),
              )
              .toList()
        : [];

    return ContentItemModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      enlace: json['enlace'] as String?,
      imagenUrl:
          json['imagenUrl'] as String?, // Cambiar de imagen_url a imagenUrl
      tipoGeneral: _typeFromString(
        json['tipoGeneral'] as String,
      ), // Cambiar de tipo_general a tipoGeneral
      subtipo: json['subtipo'] as String,
      prioridad: _priorityFromString(json['prioridad'] as String),
      estado: _statusFromString(json['estado'] as String),
      fechaGuardado: DateTime.parse(
        json['fechaGuardado'] as String,
      ), // Cambiar de fecha_guardado a fechaGuardado
      fechaActualizacion: DateTime.parse(
        json['fechaActualizacion'] as String,
      ), // Cambiar de fecha_actualizacion a fechaActualizacion
      usuarioId:
          json['usuarioId'] as String, // Cambiar de usuario_id a usuarioId
      tags: tagsList,
      notasPersonales:
          json['notasPersonales']
              as String?, // Cambiar de notas_personales a notasPersonales
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'enlace': enlace,
      // 'imagen_url': imagenUrl, // No enviar, se maneja con FormData
      'tipoGeneral': _typeToString(
        tipoGeneral,
      ), // Cambiar de tipo_general a tipoGeneral
      'subtipo': subtipo,
      'prioridad': _priorityToString(prioridad),
      'estado': _statusToString(estado),
      // 'fecha_guardado': fechaGuardado.toIso8601String(), // No enviar, lo maneja el backend
      // 'fecha_actualizacion': fechaActualizacion.toIso8601String(), // No enviar, lo maneja el backend
      // 'usuario_id': usuarioId, // No enviar, se obtiene del token
      'tagIds': tags.map((tag) => tag.id).toList(), // Cambiar de tags a tagIds
      'notasPersonales':
          notasPersonales, // Cambiar de notas_personales a notasPersonales
    }..removeWhere(
      (key, value) =>
          value == null &&
          key != 'descripcion' &&
          key != 'enlace' &&
          key != 'notasPersonales',
    );
  }

  // Para convertir de Entity a Model si es necesario
  factory ContentItemModel.fromEntity(ContentItem entity) {
    return ContentItemModel(
      id: entity.id,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      enlace: entity.enlace,
      imagenUrl: entity.imagenUrl,
      tipoGeneral: entity.tipoGeneral,
      subtipo: entity.subtipo,
      prioridad: entity.prioridad,
      estado: entity.estado,
      fechaGuardado: entity.fechaGuardado,
      fechaActualizacion: entity.fechaActualizacion,
      usuarioId: entity.usuarioId,
      tags: entity.tags
          .map((tag) => TagModel(id: tag.id, nombre: tag.nombre))
          .toList(),
      notasPersonales: entity.notasPersonales,
    );
  }
}
