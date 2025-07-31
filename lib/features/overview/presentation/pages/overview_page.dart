import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/router/app_routes.dart'; // Ajusta la ruta
import 'package:pocket_plus/features/overview/presentation/widgets/benefit_item.dart'; // Ajusta la ruta

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const Color backgroundColor = Color(0xFFF9D46B); // Color amarillo del maquetado
  static const Color buttonTextColor = Color(0xFF8B572A); // Color marrón para texto de botón "Comenzar"

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox( // Para asegurar que el contenido pueda ocupar la pantalla y los botones al final
             constraints: BoxConstraints(minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
             child: Column(
             mainAxisAlignment: MainAxisAlignment.spaceBetween, // Empuja botones al final si hay espacio
             children: [
               Column( // Contenido superior
                 children: [
                   SizedBox(height: screenHeight * 0.05),
                   Container(
                     padding: const EdgeInsets.all(20.0),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(24.0),
                     ),
                     child: const Icon(
                       Icons.bookmark_outline, // Icono de bookmark
                       size: 50,
                       color: Colors.white,
                     ),
                   ),
                   const SizedBox(height: 20),
                   Text(
                     'Pocket+',
                     style: theme.textTheme.displaySmall?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 12),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                     child: Text(
                       'Guarda y organiza todo lo que quieres leer, ver o probar... después',
                       textAlign: TextAlign.center,
                       style: theme.textTheme.titleMedium?.copyWith(
                         color: Colors.white.withOpacity(0.9),
                         height: 1.4,
                       ),
                     ),
                   ),
                   SizedBox(height: screenHeight * 0.05),
                   const BenefitItem(
                     icon: Icons.inventory_2_outlined, // O Icons.bookmark_add_outlined
                     title: 'Guarda cualquier contenido',
                     subtitle: 'Artículos, videos, lugares, recetas y más',
                   ),
                   const BenefitItem(
                     icon: Icons.sell_outlined, // O Icons.local_offer_outlined
                     title: 'Organiza con tags',
                     subtitle: 'Encuentra todo fácilmente',
                   ),
                   const BenefitItem(
                     icon: Icons.filter_list_alt, // O Icons.search_outlined
                     title: 'Filtra por prioridad',
                     subtitle: 'Ve primero lo más importante',
                   ),
                 ],
               ),
               
               Padding( // Botones al final
                 padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.white,
                         foregroundColor: buttonTextColor, // Color de texto del botón "Comenzar"
                         minimumSize: Size(screenWidth * 0.85, 52),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(16.0),
                         ),
                         textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                       ),
                       onPressed: () {
                         context.push(AppRoutes.register); // Ir a la página de registro
                       },
                       child: const Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text('Comenzar'),
                           SizedBox(width: 8),
                           Icon(Icons.arrow_forward, size: 20),
                         ],
                       ),
                     ),
                     const SizedBox(height: 16),
                     OutlinedButton(
                       style: OutlinedButton.styleFrom(
                         foregroundColor: Colors.white, // Color de texto del botón "Ya tengo cuenta"
                         minimumSize: Size(screenWidth * 0.85, 52),
                         side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(16.0),
                         ),
                          textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                       ),
                       onPressed: () {
                         context.push(AppRoutes.login); // Ir a la página de login
                       },
                       child: const Text('Ya tengo cuenta'),
                     ),
                   ],
                 ),
               ),
             ],
           ),
          ),
        ),
      ),
    );
  }
}