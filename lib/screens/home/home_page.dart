import 'package:flutter/material.dart';
import 'package:utmapa/core/constants.dart';
import 'package:utmapa/screens/map/map_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(UTMConstants.colorBeige),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 100,
              color: Color(UTMConstants.colorGuinda),
            ),
            const SizedBox(height: 20),
            const Text(
              "UTMapa",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(UTMConstants.colorGuinda),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(UTMConstants.colorGuinda),
                foregroundColor: Colors.white,
              ),
              child: const Text("EXPLORAR CAMPUS"),
            ),
          ],
        ),
      ),
    );
  }
}
