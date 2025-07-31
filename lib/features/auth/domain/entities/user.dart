import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String? fotoPerfil; // Opcional
  final DateTime fechaCreacion;
  final String? token; // El token JWT se suele recibir aquí

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoPerfil,
    required this.fechaCreacion,
    this.token,
  });

  @override
  List<Object?> get props => [id, nombre, email, fotoPerfil, fechaCreacion, token];
}