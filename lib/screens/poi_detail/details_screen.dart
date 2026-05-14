import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:utmapa/core/constants.dart';
import 'package:utmapa/models/poi_model.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DetailsScreen extends StatefulWidget {
  final POIModel poi;
  const DetailsScreen({super.key, required this.poi});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _mostrarCalendario(BuildContext context) {
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
                      padding: const EdgeInsets.all(22),
                      child: const Text("Error al cargar Calendario.jpg"),
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

  void _mostrarEventos(BuildContext context) {
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
                  _buildEventTile(
                    context,
                    Icons.mic,
                    "Ciclo de Conferencias",
                    "18 May - 10:00 AM",
                    "Auditorio Rectoría",
                  ),
                  _buildEventTile(
                    context,
                    Icons.smart_toy,
                    "Competencias Robots",
                    "20 May - 02:00 PM",
                    "Plaza Estudiante",
                  ),
                  _buildEventTile(
                    context,
                    Icons.health_and_safety,
                    "Jornadas de Salud",
                    "22 May - 09:00 AM",
                    "Centro Salud",
                  ),
                  _buildEventTile(
                    context,
                    Icons.military_tech,
                    "Torneo de Ajedrez",
                    "25 May - 04:00 PM",
                    "Biblioteca",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(
    BuildContext context,
    IconData icon,
    String title,
    String time,
    String place,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: const Color(UTMConstants.colorGuinda)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        "$time \n$place",
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      ),
      isThreeLine: true,
    );
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-MX");
    await flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => isPlaying = false);
    });
  }

  Future<void> _toggleTts() async {
    if (isPlaying) {
      await flutterTts.stop();
      if (mounted) setState(() => isPlaying = false);
    } else {
      if (mounted) setState(() => isPlaying = true);
      await flutterTts.speak(
        "${widget.poi.name}. ${widget.poi.description}. Horario: ${widget.poi.schedule}",
      );
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final poi = widget.poi;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(UTMConstants.colorBeige),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_c_d",
            mini: true,
            onPressed: () => _mostrarCalendario(context),
            backgroundColor: const Color(UTMConstants.colorGuinda),
            child: const Icon(Icons.calendar_month, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn_e_d",
            mini: true,
            onPressed: () => _mostrarEventos(context),
            backgroundColor: const Color(UTMConstants.colorGuinda),
            child: const Icon(Icons.event_note, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn_t_d",
            onPressed: _toggleTts,
            backgroundColor: const Color(UTMConstants.colorGuinda),
            child: Icon(
              isPlaying ? Icons.stop : Icons.volume_up,
              color: Colors.white,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(UTMConstants.colorGuinda),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PUNTO DE INTERÉS",
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                poi.name,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(UTMConstants.colorGuinda),
                ),
              ),
              Text(
                "📍 Campus UTM",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              if (poi.imageUrls.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: poi.imageUrls.length > 1,
                    viewportFraction: 0.9,
                  ),
                  items: poi.imageUrls
                      .map(
                        (url) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(
                                UTMConstants.colorGuinda,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 25),
              Row(
                children: [
                  _infoCard(Icons.access_time_filled, "HORARIO", poi.schedule),
                  const SizedBox(width: 15),
                  _infoCard(Icons.map, "UBICACIÓN", "UTM"),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Sobre este espacio",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(UTMConstants.colorGuinda),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                poi.description,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(UTMConstants.colorGuinda),
                      Colors.red[900]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                      size: 45,
                    ),
                    const Text(
                      "Reto Disponible",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(UTMConstants.colorBeige),
                        foregroundColor: const Color(UTMConstants.colorGuinda),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (poi.gameRoute.isNotEmpty) {
                          Navigator.pushNamed(context, poi.gameRoute);
                        }
                      },
                      child: const Text(
                        "INICIAR JUEGO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String sub) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(UTMConstants.colorGuinda), size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(UTMConstants.colorGuinda),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
