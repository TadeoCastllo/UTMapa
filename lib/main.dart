import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'core/constants.dart';

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
    );
  }
}
