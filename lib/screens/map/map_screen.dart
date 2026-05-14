import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:utmapa/screens/poi_detail/details_screen.dart';
import 'package:utmapa/models/poi_model.dart';
import '../../core/constants.dart';
import 'package:utmapa/screens/qr/qr_scanner_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentPosition;
  bool _isLoading = true;
  List<POIModel> _pois = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  void _mostrarCalendario() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Calendario Escolar",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : const Color(UTMConstants.colorGuinda),
                ),
              ),
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),

                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    'assets/images/Calendario.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error: No se encontró 'Calendario.jpg' en assets/images/",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CERRAR",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarEventos() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? Colors.grey[900]
          : const Color(UTMConstants.colorBeige),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ACTIVIDADES PLANEADAS",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : const Color(UTMConstants.colorGuinda),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildEventItem(
                    context,
                    Icons.mic_external_on,
                    "Ciclo de Conferencias",
                    "18 de Mayo - 10:00 AM",
                    "Auditorio de Rectoría",
                    Colors.blue,
                  ),
                  _buildEventItem(
                    context,
                    Icons.smart_toy,
                    "Competencias de Robots",
                    "20 de Mayo - 02:00 PM",
                    "Plaza del Estudiante",
                    Colors.green,
                  ),
                  _buildEventItem(
                    context,
                    Icons.health_and_safety,
                    "Jornadas de Salud",
                    "22 de Mayo - 09:00 AM",
                    "Centro de Salud Universitario",
                    Colors.red,
                  ),
                  _buildEventItem(
                    context,
                    Icons.school,
                    "Ceremonia de Graduación",
                    "30 de Mayo - 11:00 AM",
                    "Auditorio Central",
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(
    BuildContext context,
    IconData icon,
    String title,
    String dateTime,
    String location,
    Color iconColor,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        "$dateTime\n$location",
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      ),
      isThreeLine: true,
    );
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

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!mounted) return;

    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    var controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> _openQrScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (result != null && result is String) {
      try {
        final poi = _pois.firstWhere((p) => p.id == result);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailsScreen(poi: poi)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código QR no válido para la UTM'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
              mapController: _mapController,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnCalendario",
            backgroundColor: const Color(UTMConstants.colorGuinda),
            foregroundColor: Colors.white,
            onPressed: _mostrarCalendario,
            child: const Icon(Icons.calendar_month, size: 30),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: "btnEventos",
            backgroundColor: const Color(UTMConstants.colorGuinda),
            foregroundColor: Colors.white,
            onPressed: _mostrarEventos,
            child: const Icon(Icons.event_note, size: 30),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: "btnQr",
            backgroundColor: const Color(UTMConstants.colorBeige),
            foregroundColor: const Color(UTMConstants.colorGuinda),
            onPressed: _openQrScanner,
            child: const Icon(Icons.qr_code_scanner, size: 30),
          ),
          const SizedBox(height: 15),
          if (_currentPosition != null)
            FloatingActionButton(
              heroTag: "btnGps",
              backgroundColor: const Color(UTMConstants.colorGuinda),
              foregroundColor: Colors.white,
              onPressed: () {
                _animatedMapMove(_currentPosition!, 16.5);
              },
              child: const Icon(Icons.my_location),
            ),
        ],
      ),
    );
  }
}
