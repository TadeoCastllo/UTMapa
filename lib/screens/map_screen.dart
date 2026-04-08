import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../core/constants.dart';
import 'details_screen.dart';
import '../modules/sopa_letras/sopa_screen.dart';
import '../modules/futbol/futbol_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explora la UTM"),
        backgroundColor: const Color(UTMConstants.colorGuinda),
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: UTMConstants.bibliotecaPos,
          initialZoom: 16.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.utm.utmapa',
          ),
          MarkerLayer(
            markers: [
              // MARCADOR DE LA BIBLIOTECA
              Marker(
                point: UTMConstants.bibliotecaPos,
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DetailsScreen(
                        nombre: "Biblioteca Central",
                        zona: "Campus Norte, Zona A",
                        horario: "8:00 AM — 11:00 PM",
                        redWifi: "biblioteca",
                        iconoPrincipal: Icons.menu_book_rounded,
                        descripcion:
                            "El corazón intelectual de la UTM. Un espacio dedicado al estudio, la investigación y el acceso a una vasta colección de recursos bibliográficos y digitales en un ambiente tranquilo.",
                        juegoDestino: SopaLetrasScreen(),
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(UTMConstants.colorGuinda),
                    size: 45,
                  ),
                ),
              ),

              // MARCADOR DE LAS CANCHAS
              Marker(
                point: UTMConstants.canchasPos,
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DetailsScreen(
                        nombre: "Canchas Deportivas",
                        zona: "Área Recreativa, Zona C",
                        horario: "Acceso 24 Horas",
                        redWifi: "No disponible",
                        iconoPrincipal: Icons.sports_soccer_rounded,
                        descripcion:
                            "Espacio deportivo abierto a toda la comunidad universitaria para la práctica de fútbol, ejercicio al aire libre y torneos internos. Un lugar ideal para liberar energía entre clases.",
                        juegoDestino: FutbolScreen(),
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
