import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/push_notifications_service.dart';

import 'package:utmapa/screens/games/trivia_screen.dart';
import 'screens/home/home_page.dart';
import 'core/constants.dart';
import 'modules/sopa_letras/sopa_screen.dart';
import 'screens/games/atrapa_objetos.dart';
import 'modules/futbol/futbol_screen.dart';

// se agrego -> Notificador para el cambio de tema global
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationsService.initializeApp();

  runApp(const UTMapaApp());
}

class UTMapaApp extends StatelessWidget {
  const UTMapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // se agrego -> Reconstruye la app al cambiar el tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // Tema Claro
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(UTMConstants.colorGuinda),
              brightness: Brightness.light,
            ),
          ),
          // se agrego -> Configuración para Modo Oscuro
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(UTMConstants.colorGuinda),
              brightness: Brightness.dark,
            ),
          ),
          home: const HomePage(),
          routes: {
            '/sopa_letras': (context) => const SopaLetrasScreen(),
            '/futbol': (context) => const FutbolScreen(),
            '/atrapa_objetos': (context) => const AtrapaObjetosScreen(),
            '/trivia_utm': (context) => const TriviaScreen(),
          },
        );
      },
    );
  }
}
