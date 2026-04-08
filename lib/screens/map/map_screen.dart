import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:utmapa/screens/poi_detail/details_screen.dart';
import 'package:utmapa/models/poi_model.dart';
import '../../core/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  List<POIModel> _pois = [];

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  Future<void> _loadInitData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/pois.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _pois = jsonList.map((json) => POIModel.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint("Error loading POIs: $e");
    }
    _determinePosition();
  }

  // Función para obtener la ubicación del usuario
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explora la UTM"),
        backgroundColor: const Color(UTMConstants.colorGuinda),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(UTMConstants.colorGuinda),
              ),
            )
          : FlutterMap(
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
                    // 1. Marcador del GPS del usuario (Punto Azul)
                    if (_currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Color(UTMConstants.colorGuinda),
                          size: 30,
                        ),
                      ),

                    // 2. Marcadores dinámicos de los POIs
                    ..._pois.map((poi) {
                      return Marker(
                        point: LatLng(poi.latitude, poi.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(poi: poi),
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            // Por defecto usamos el guinda de la institución para todos
                            color: Color(UTMConstants.colorGuinda),
                            size: 45,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
    );
  }
}
