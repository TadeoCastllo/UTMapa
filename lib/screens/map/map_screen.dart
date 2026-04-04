import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../data/mock_details.dart';
import '../../models/poi_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Función para obtener la ubicación del usuario
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  // Función que muestra la información al tocar el pin (BottomSheet)
  void _showPOIDetails(BuildContext context, POIModel poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poi.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ), // Guinda UTM
              ),
              const SizedBox(height: 5),
              Text(
                poi.schedule,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // --- INICIO DE LA GALERÍA CON CAROUSEL SLIDER ---
              if (poi.imageUrls.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    enlargeCenterPage:
                        true, // Hace que la imagen central se vea un poco más grande
                    enableInfiniteScroll:
                        false, // Falso para que no dé vueltas infinitas si son pocas fotos
                    viewportFraction:
                        0.85, // Qué tanto espacio de la pantalla ocupa cada foto
                  ),
                  items: poi.imageUrls.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            // Mantenemos el salvavidas por si la foto no existe aún en tus assets
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                    Text(
                                      'Imagen no encontrada',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 15),

              // --- FIN DE LA GALERÍA ---
              Text(poi.description),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Abriendo minijuego de ${poi.name}...'),
                      ),
                    );
                  },
                  child: const Text(
                    'Jugar Actividad',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa UTM', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF800000), // Guinda institucional
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF800000)),
            )
          : FlutterMap(
              options: MapOptions(
                // Centramos el mapa en la UTM (o en el usuario si está en el campus)
                initialCenter: const LatLng(17.8055, -97.7733),
                initialZoom: 16.5,
              ),
              children: [
                TileLayer(
                  // Usamos OpenStreetMap que es gratuito y plano
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tuapp.orientacion_utm',
                ),
                MarkerLayer(
                  markers: [
                    // 1. Marcador del GPS del usuario (Punto Azul)
                    if (_currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    // 2. Marcadores de los Puntos de Interés (Iteramos sobre tu lista mockPois)
                    ...mockPois.map(
                      (poi) => Marker(
                        point: LatLng(poi.latitude, poi.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showPOIDetails(context, poi),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF800000),
                            size: 45,
                          ), // Pin Guinda
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
