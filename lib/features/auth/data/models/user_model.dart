import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta ruta

class UserModel extends User {
  const UserModel({
    required String id,
    required String nombre,
    required String email,
    String? fotoPerfil,
    required DateTime fechaCreacion,
    String? token,
  }) : super(
         id: id,
         nombre: nombre,
         email: email,
         fotoPerfil: fotoPerfil,
         fechaCreacion: fechaCreacion,
         token: token,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      fotoPerfil: json['fotoPerfilUrl'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      token:
          json['token']
              as String?, // Asumiendo que el token viene en la respuesta del login/register
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'fotoPerfilUrl': fotoPerfil,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'token': token,
    };
  }

  // Si necesitas convertir de User (Entity) a UserModel (Model)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      nombre: user.nombre,
      email: user.email,
      fotoPerfil: user.fotoPerfil,
      fechaCreacion: user.fechaCreacion,
      token: user.token,
    );
  }
}
