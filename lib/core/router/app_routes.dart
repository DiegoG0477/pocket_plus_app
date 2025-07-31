class AppRoutes {
  static const String overview = '/'; // Pantalla inicial
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String contentDetail = '/content/:id'; // Ruta con parámetro
  static const String addContent = '/add-content';
  static const String editContent = '/edit-content/:id'; // Ruta con parámetro
  static const String profile = '/profile';

  // Helper para construir rutas con parámetros
  static String contentDetailPath(String id) => '/content/$id';
  static String editContentPath(String id) => '/edit-content/$id';
}