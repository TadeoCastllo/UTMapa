import 'package:flutter/material.dart';
// Importa el archivo de tu mapa (ajusta la ruta si lo guardaste en otra carpeta)
import 'screens/map/map_screen.dart';

void main() {
  // Inicializamos los bindings de Flutter por si alguna librería (como geolocator) lo necesita antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UTMapa());
}

class UTMapa extends StatelessWidget {
  const UTMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTMapa',
      debugShowCheckedModeBanner:
          false, // Quita la tirita roja de "DEBUG" en la esquina
      theme: ThemeData(
        // Aplicamos los colores institucionales a toda la app
        primaryColor: const Color(0xFF800000), // Guinda
        scaffoldBackgroundColor: const Color(
          0xFFF5F5DC,
        ), // Beige clarito para los fondos
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800000),
          primary: const Color(0xFF800000),
          secondary: const Color(0xFFD2B48C), // Un tono arena/beige
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF800000),
          foregroundColor: Colors.white, // Letras blancas en la barra superior
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      // Aquí "conectamos" tu pantalla. Le decimos a Flutter que lo primero que muestre sea el mapa
      home: const MapScreen(),
    );
  }
}
