import 'package:equatable/equatable.dart';
import 'package:pocket_plus/features/content/domain/entities/tag.dart'; // Ajusta ruta
import 'package:pocket_plus/core/constants/content_types.dart'; // Importar el ContentTypeGeneral estandarizado

enum ContentPriority { alta, media, baja }
enum ContentStatus { pendiente, completado, descartado }

class ContentItem extends Equatable {
  final String id;
  final String titulo;
  final String? descripcion; // Es opcional en tu overview
  final String? enlace;
  final String? imagenUrl;
  final ContentTypeGeneral tipoGeneral;
  final String subtipo; // ej: 🎥 Video, 📚 Libro, 🎵 Música, 📝 Nota rápida
  final ContentPriority prioridad;
  final ContentStatus estado;
  final DateTime fechaGuardado;
  final DateTime fechaActualizacion;
  final String usuarioId; // FK
  final List<Tag> tags; // Lista de tags asociados
  final String? notasPersonales; // Añadido de "Vista de detalle enriquecida"

  const ContentItem({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.enlace,
    this.imagenUrl,
    required this.tipoGeneral,
    required this.subtipo,
    required this.prioridad,
    required this.estado,
    required this.fechaGuardado,
    required this.fechaActualizacion,
    required this.usuarioId,
    this.tags = const [],
    this.notasPersonales,
  });

  @override
  List<Object?> get props => [
        id,
        titulo,
        descripcion,
        enlace,
        imagenUrl,
        tipoGeneral,
        subtipo,
        prioridad,
        estado,
        fechaGuardado,
        fechaActualizacion,
        usuarioId,
        tags,
        notasPersonales,
      ];

  ContentItem copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? enlace,
    String? imagenUrl,
    ContentTypeGeneral? tipoGeneral,
    String? subtipo,
    ContentPriority? prioridad,
    ContentStatus? estado,
    DateTime? fechaGuardado,
    DateTime? fechaActualizacion,
    String? usuarioId,
    List<Tag>? tags,
    String? notasPersonales,
  }) {
    return ContentItem(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      enlace: enlace ?? this.enlace,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      tipoGeneral: tipoGeneral ?? this.tipoGeneral,
      subtipo: subtipo ?? this.subtipo,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fechaGuardado: fechaGuardado ?? this.fechaGuardado,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      usuarioId: usuarioId ?? this.usuarioId,
      tags: tags ?? this.tags,
      notasPersonales: notasPersonales ?? this.notasPersonales,
    );
  }
}
