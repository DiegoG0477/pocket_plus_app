import 'package:pocket_plus/features/content/domain/entities/tag.dart'; // Ajusta ruta

class TagModel extends Tag {
  const TagModel({
    required String id,
    required String nombre,
    String? usuarioId, // Ahora es opcional y se pasa al super
  }) : super(id: id, nombre: nombre, usuarioId: usuarioId);

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      usuarioId:
          json['usuarioId']
              as String?, // Asegúrate que el nombre de la clave sea correcto
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'nombre': nombre,
      'usuarioId': usuarioId, // Incluir usuarioId en toJson
    };
    map.removeWhere((key, value) => value == null); // Para no enviar nulos
    return map;
  }

  factory TagModel.fromEntity(Tag entity) {
    return TagModel(
      id: entity.id,
      nombre: entity.nombre,
      usuarioId: entity.usuarioId,
    );
  }
}
