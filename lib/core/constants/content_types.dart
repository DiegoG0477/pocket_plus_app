import 'package:flutter/material.dart'; // Para IconData

// El enum ContentTypeGeneral que ya teníamos
enum ContentTypeGeneral {
  texto,
  multimedia,
  productividad,
  ubicacion,
  compra,
  comida,
  evento,
  enlace,
  otro,
}

class ContentSubtype {
  final String name;
  final IconData icon;
  final ContentTypeGeneral generalType;
  // Podrías añadir un color aquí también si cada tipo tiene un color asociado
  // final Color color;

  const ContentSubtype({
    required this.name,
    required this.icon,
    required this.generalType,
    // this.color = Colors.grey
  });
}

// Lista de todos los subtipos disponibles
final List<ContentSubtype> allContentSubtypes = [
  // Texto/Documentos
  ContentSubtype(name: 'Artículo', icon: Icons.article_outlined, generalType: ContentTypeGeneral.texto),
  ContentSubtype(name: 'Libro', icon: Icons.book_outlined, generalType: ContentTypeGeneral.texto),
  ContentSubtype(name: 'Lista lectura', icon: Icons.list_alt_outlined, generalType: ContentTypeGeneral.texto),
  ContentSubtype(name: 'Noticia', icon: Icons.newspaper_outlined, generalType: ContentTypeGeneral.texto),
  ContentSubtype(name: 'PDF', icon: Icons.picture_as_pdf_outlined, generalType: ContentTypeGeneral.texto),
  ContentSubtype(name: 'Nota', icon: Icons.note_alt_outlined, generalType: ContentTypeGeneral.texto),
  ContentSubtype(name: 'Post', icon: Icons.post_add_outlined, generalType: ContentTypeGeneral.texto),

  // Multimedia
  ContentSubtype(name: 'Video', icon: Icons.videocam_outlined, generalType: ContentTypeGeneral.multimedia),
  ContentSubtype(name: 'Película', icon: Icons.movie_creation_outlined, generalType: ContentTypeGeneral.multimedia),
  ContentSubtype(name: 'Podcast', icon: Icons.podcasts_outlined, generalType: ContentTypeGeneral.multimedia),
  ContentSubtype(name: 'Música', icon: Icons.music_note_outlined, generalType: ContentTypeGeneral.multimedia),
  ContentSubtype(name: 'Juego', icon: Icons.sports_esports_outlined, generalType: ContentTypeGeneral.multimedia),
  ContentSubtype(name: 'Trailer', icon: Icons.local_movies_outlined, generalType: ContentTypeGeneral.multimedia),

  // Productividad/Educación
  ContentSubtype(name: 'Curso', icon: Icons.school_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Técnica', icon: Icons.psychology_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Productividad', icon: Icons.task_alt_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Creativo', icon: Icons.brush_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Proyecto', icon: Icons.workspaces_outline, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Herramienta', icon: Icons.build_circle_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Plugin', icon: Icons.extension_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Recurso', icon: Icons.folder_special_outlined, generalType: ContentTypeGeneral.productividad),
  ContentSubtype(name: 'Idea', icon: Icons.lightbulb_outline, generalType: ContentTypeGeneral.productividad),

  // Lugares/Eventos
  ContentSubtype(name: 'Restaurante', icon: Icons.restaurant_outlined, generalType: ContentTypeGeneral.ubicacion),
  ContentSubtype(name: 'Lugar', icon: Icons.place_outlined, generalType: ContentTypeGeneral.ubicacion),
  ContentSubtype(name: 'Actividad', icon: Icons.local_activity_outlined, generalType: ContentTypeGeneral.evento),
  ContentSubtype(name: 'Hotel', icon: Icons.hotel_outlined, generalType: ContentTypeGeneral.ubicacion),
  ContentSubtype(name: 'Evento', icon: Icons.event_outlined, generalType: ContentTypeGeneral.evento),
  ContentSubtype(name: 'Viaje', icon: Icons.flight_takeoff_outlined, generalType: ContentTypeGeneral.ubicacion),
  ContentSubtype(name: 'Reunión', icon: Icons.people_alt_outlined, generalType: ContentTypeGeneral.evento),

  // Compras
  ContentSubtype(name: 'Producto', icon: Icons.shopping_bag_outlined, generalType: ContentTypeGeneral.compra),
  ContentSubtype(name: 'Tienda', icon: Icons.storefront_outlined, generalType: ContentTypeGeneral.compra),
  ContentSubtype(name: 'Regalo', icon: Icons.card_giftcard_outlined, generalType: ContentTypeGeneral.compra),
  ContentSubtype(name: 'Cosmético', icon: Icons.spa_outlined, generalType: ContentTypeGeneral.compra),

  // Comida
  ContentSubtype(name: 'Alimento', icon: Icons.bakery_dining_outlined, generalType: ContentTypeGeneral.comida),
  ContentSubtype(name: 'Receta', icon: Icons.menu_book_outlined, generalType: ContentTypeGeneral.comida),
  ContentSubtype(name: 'Platillo', icon: Icons.dinner_dining_outlined, generalType: ContentTypeGeneral.comida),

  // Misceláneos
  ContentSubtype(name: 'Experimento', icon: Icons.science_outlined, generalType: ContentTypeGeneral.otro),
  ContentSubtype(name: 'Colección', icon: Icons.collections_bookmark_outlined, generalType: ContentTypeGeneral.otro),
  ContentSubtype(name: 'Web', icon: Icons.link_outlined, generalType: ContentTypeGeneral.enlace),
  ContentSubtype(name: 'App', icon: Icons.apps_outlined, generalType: ContentTypeGeneral.otro),
  ContentSubtype(name: 'Otro', icon: Icons.more_horiz_outlined, generalType: ContentTypeGeneral.otro),
];

// Funciones helper
ContentTypeGeneral getGeneralTypeForSubtypeName(String subtypeName) {
  final found = allContentSubtypes.firstWhere(
    (s) => s.name == subtypeName,
    orElse: () => allContentSubtypes.firstWhere((s) => s.name == 'Otro'),
  );
  return found.generalType;
}

IconData getIconForSubtypeName(String subtypeName) {
   final found = allContentSubtypes.firstWhere(
    (s) => s.name == subtypeName,
    orElse: () => allContentSubtypes.firstWhere((s) => s.name == 'Otro'),
  );
  return found.icon;
}

// Podrías querer un helper para obtener el ContentSubtype completo
ContentSubtype getContentSubtypeByName(String subtypeName) {
  return allContentSubtypes.firstWhere(
    (s) => s.name == subtypeName,
    orElse: () => allContentSubtypes.firstWhere((s) => s.name == 'Otro'),
  );
}