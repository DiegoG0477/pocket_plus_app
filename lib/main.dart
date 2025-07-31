// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Necesario para MultiBlocProvider
import 'package:get_it/get_it.dart'; // Para acceder al AuthCubit
import 'package:pocket_plus/core/di/injection_container.dart' as di;
import 'package:pocket_plus/core/router/app_router.dart';
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Importa AuthCubit
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart'; // Importa ContentCubit

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  // Llama a appStarted para verificar el estado de autenticación inicial
  GetIt.I<AuthCubit>().appStarted();
  // Inicializar ContentCubit para que esté listo cuando se necesite
  GetIt.I<ContentCubit>();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Si vas a usar BlocProvider en múltiples lugares o para temas globales,
    // podrías envolver MaterialApp.router con MultiBlocProvider.
    // Por ahora, GoRouter maneja la provisión a nivel de ruta para LoginPage/RegisterPage.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: GetIt.I<AuthCubit>()),
        BlocProvider.value(value: GetIt.I<ContentCubit>()),
      ],
      child: Directionality(
        textDirection:
            TextDirection.ltr, // O TextDirection.rtl si tu app es RTL
        child: MaterialApp.router(
          title: 'Pocket+',
          theme: ThemeData(
            // Define tus colores primarios y de acento para que coincidan con el amarillo si es necesario
            primaryColor: const Color(0xFFF2C94C), // Amarillo principal
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(
                0xFFF2C94C,
              ), // Amarillo para generar esquema
              // Puedes personalizar más colores aquí si es necesario
              // primary: const Color(0xFFF2C94C),
              // secondary: Colors.blueAccent, // Un color secundario
              background: Colors.white, // Fondo general
              surface: Colors.white, // Superficie de tarjetas, diálogos
              onPrimary: Colors.black87, // Color del texto sobre el primario
              onBackground: Colors.black87, // Color del texto sobre el fondo
              onSurface: Colors.black87, // Color del texto sobre superficies
            ),
            useMaterial3: true,
            scaffoldBackgroundColor:
                Colors.white, // Fondo de scaffold explícito
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              // Estilos base para TextFormField
              filled: true,
              fillColor: Colors.grey[100], // Un gris muy claro para los campos
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: const Color(0xFFF2C94C),
                  width: 1.5,
                ),
              ),
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2C94C), // Amarillo
                foregroundColor: Colors.black87, // Texto negro sobre amarillo
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                  0xFFF2C94C,
                ), // Amarillo para texto de botones de texto
              ),
            ),
            dividerTheme: DividerThemeData(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
