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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationsService.initializeApp();

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
        '/trivia_utm': (context) => const TriviaScreen(),
      },
    );
  }
}
