import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String id;
  final String nombre;
  final String? usuarioId; // Hacerlo opcional para flexibilidad

  const Tag({
    required this.id,
    required this.nombre,
    this.usuarioId, // Ahora es opcional
  });

  @override
  List<Object?> get props => [id, nombre, usuarioId];
}
