import 'package:flutter/material.dart';
import '../../core/constants.dart'; // Ajusta tus rutas
import '../../core/score_manager.dart';
import '../map/map_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int recordMochila = 0;
  int recordTrivia = 0;
  int recordFutbol = 0;
  int bestSopa = 999999;

  @override
  void initState() {
    super.initState();
    _cargarRecords();
  }

  // Cargamos los récords desde SharedPreferences
  Future<void> _cargarRecords() async {
    final rMochila = await ScoreManager.getScore('highscore_mochila');
    final rTrivia = await ScoreManager.getScore('highscore_trivia');
    final rFutbol = await ScoreManager.getScore('highscore_futbol');
    // Si tu ScoreManager usa getScore para la sopa, ajusta aquí, o usa un método específico.
    final rSopa = await ScoreManager.getScore('best_time_sopa');

    setState(() {
      recordMochila = rMochila;
      recordTrivia = rTrivia;
      recordFutbol = rFutbol;
      bestSopa = rSopa == 0 ? 999999 : rSopa; // Manejo por si devuelve 0
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(UTMConstants.colorBeige),
      body: SafeArea(
        child: Column(
          children: [
            // --- CABECERA MODERNA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(UTMConstants.colorGuinda),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.white),
                  const SizedBox(height: 15),
                  const Text(
                    "UTMapa",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Descubre tu campus, rompe tus récords.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- DASHBOARD DE RÉCORDS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Tus Mejores Marcas",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(UTMConstants.colorGuinda),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Grid para los 4 minijuegos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRecordCard(
                      "Trivia UTM",
                      "$recordTrivia Pts",
                      Icons.quiz,
                      Colors.blue,
                    ),
                    _buildRecordCard(
                      "Atrapa Objetos",
                      "$recordMochila Pts",
                      Icons.backpack,
                      Colors.orange,
                    ),
                    _buildRecordCard(
                      "Tiros Libres",
                      "$recordFutbol Goles",
                      Icons.sports_soccer,
                      Colors.green,
                    ),
                    _buildRecordCard(
                      "Sopa Letras",
                      ScoreManager.formatTime(bestSopa),
                      Icons.search,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTONES INFERIORES ---
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // El await hace que espere a que regreses del mapa
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapScreen()),
                      );
                      // Cuando regresas (haces pop), recargamos los récords por si rompiste alguno
                      _cargarRecords();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(UTMConstants.colorGuinda),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.explore, size: 28),
                        SizedBox(width: 15),
                        Text(
                          "EXPLORAR CAMPUS",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Row(
                            children: [
                              Icon(Icons.info, color: Color(UTMConstants.colorGuinda)),
                              SizedBox(width: 10),
                              Text("Acerca de UTMapa"),
                            ],
                          ),
                          content: const Text(
                            "Bienvenido a UTMapa.\n\nAplicación diseñada para recorrer el campus, encontrar puntos de interés y disfrutar de divertidos minijuegos. ¡Supera tus récords!\n\n Esta app fue diseñada por Zaeinmd Navarrete Marín, encargada de los minijuegos de futbol y sopa de letras y mapa. Junto a Fernando Tadeo Jimenez Castillo, encargado del mapa y los minijuegos de trivia y atrapa objetos.",
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "CERRAR",
                                style: TextStyle(color: Color(UTMConstants.colorGuinda), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(UTMConstants.colorGuinda),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Color(UTMConstants.colorGuinda), width: 2),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.help_outline, size: 26),
                        SizedBox(width: 15),
                        Text(
                          "ACERCA DE...",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    String titulo,
    String valor,
    IconData icono,
    Color colorIcono,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 35, color: colorIcono),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(UTMConstants.colorGuinda),
            ),
          ),
        ],
      ),
    );
  }
}
