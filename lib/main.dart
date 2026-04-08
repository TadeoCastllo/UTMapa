import 'package:flutter/material.dart';
import 'screens/home/home_page.dart';
import 'core/constants.dart';
import 'modules/sopa_letras/sopa_screen.dart';
import 'screens/games/atrapa_objetos.dart';
import 'modules/futbol/futbol_screen.dart';

void main() {
  runApp(const UTMapaApp());
}

class UTMapaApp extends StatelessWidget {
  const UTMapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(UTMConstants.colorGuinda),
        ),
      ),
      home: const HomePage(),
      routes: {
        '/sopa_letras': (context) => const SopaLetrasScreen(),
        '/futbol': (context) => const FutbolScreen(),
        '/atrapa_objetos': (context) => const AtrapaObjetosScreen(),
      },
    );
  }
}
