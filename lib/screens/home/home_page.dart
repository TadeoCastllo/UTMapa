import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/score_manager.dart';
import '../map/map_screen.dart';
// AGREGADO -> Importamos el notifier del archivo main
import '../../main.dart';

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

  Future<void> _cargarRecords() async {
    final rMochila = await ScoreManager.getScore('highscore_mochila');
    final rTrivia = await ScoreManager.getScore('highscore_trivia');
    final rFutbol = await ScoreManager.getScore('highscore_futbol');
    final rSopa = await ScoreManager.getScore('best_time_sopa');

    setState(() {
      recordMochila = rMochila;
      recordTrivia = rTrivia;
      recordFutbol = rFutbol;
      bestSopa = rSopa == 0 ? 999999 : rSopa;
    });
  }

  @override
  Widget build(BuildContext context) {
    // AGREGADO -> Detectar si el modo actual es oscuro para ajustar colores
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // AGREGADO -> El fondo cambia a oscuro automáticamente si se selecciona
      backgroundColor: isDarkMode ? null : const Color(UTMConstants.colorBeige),
      // AGREGADO -> Stack para colocar el selector de tema por encima de todo
      body: Stack(
        children: [
          // --- DISEÑO ORIGINAL (COLUMNA PRINCIPAL) ---
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
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

                // DASHBOARD DE RÉCORDS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Tus Mejores Marcas",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(UTMConstants.colorGuinda),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

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

                // BOTONES INFERIORES
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(),
                            ),
                          );
                          _cargarRecords();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            UTMConstants.colorGuinda,
                          ),
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
                        onPressed: () => _mostrarAcercaDe(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.grey[850]
                              : Colors.white,
                          foregroundColor: const Color(
                            UTMConstants.colorGuinda,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(UTMConstants.colorGuinda),
                              width: 2,
                            ),
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

          // AGREGADO -> EL BOTÓN SELECTOR DE TEMA
          Positioned(
            top: 50,
            left: 15,
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) {
                final isDark =
                    mode == ThemeMode.dark ||
                    (mode == ThemeMode.system &&
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark);

                return IconButton(
                  icon: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    themeNotifier.value = isDark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // SE CORRIGIÓ -> Problema de RenderFlex Overflow y visibilidad en modo oscuro
  void _mostrarAcercaDe(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Color(UTMConstants.colorGuinda)),
            const SizedBox(width: 10),
            // FIX: Flexible evita que el Row se desborde horizontalmente
            Flexible(
              child: Text(
                "Acerca de UTMapa",
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
        content: Text(
          "Bienvenido a UTMapa.\n\nAplicación diseñada para recorrer el campus, encontrar puntos de interés y disfrutar de divertidos minijuegos. ¡Supera tus récords!\n\n Esta app fue diseñada por Zaeinmd Navarrete Marín, encargada de los minijuegos de futbol y sopa de letras y mapa. Junto a Fernando Tadeo Jimenez Castillo, encargado del mapa y los minijuegos de trivia y atrapa objetos.",
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CERRAR",
              style: TextStyle(
                color: Color(UTMConstants.colorGuinda),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    String titulo,
    String valor,
    IconData icono,
    Color colorIcono,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
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
