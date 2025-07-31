import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_plus/features/auth/data/models/user_model.dart'; // Ajusta la ruta

const String _authTokenKey = 'auth_token';
const String _userDataKey = 'user_data';

class UserSessionManager {
  final SharedPreferences _prefs;

  UserSessionManager(this._prefs);

  Future<void> saveSession(UserModel user, String token) async {
    await _prefs.setString(_authTokenKey, token);
    // Guardamos el UserModel completo porque tiene el token, que es parte de la sesión.
    // El UserModel que pasamos aquí debe ser el que ya incluye el token.
    await _prefs.setString(_userDataKey, json.encode(user.toJson()));
  }

  Future<UserModel?> getCurrentUser() async {
    final userDataString = _prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return UserModel.fromJson(json.decode(userDataString) as Map<String, dynamic>);
      } catch (e) {
        // Si hay error al parsear, es mejor limpiar la sesión corrupta.
        print("Error al decodificar datos del usuario: $e");
        await clearSession();
        return null;
      }
    }
    return null;
  }

  Future<String?> getToken() async {
    return _prefs.getString(_authTokenKey);
  }

  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_userDataKey);
  }
}