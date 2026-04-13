import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/pregunta_model.dart';
import 'package:utmapa/core/score_manager.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  List<PreguntaModel> preguntas = [];
  int preguntaActualIndex = 0;
  int puntuacion = 0;
  bool cargando = true;
  String tituloTrivia = "";

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  // --- 1. LECTURA DEL JSON Y SELECCIÓN DE 10 PREGUNTAS ---
  Future<void> _cargarPreguntas() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/trivia.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final List<dynamic> preguntasJson = jsonData['preguntas'];

      setState(() {
        tituloTrivia = jsonData['titulo'];

        // 1. Convertimos TODAS las preguntas del JSON a objetos
        List<PreguntaModel> todasLasPreguntas = preguntasJson
            .map((q) => PreguntaModel.fromJson(q))
            .toList();

        // 2. Las revolvemos todas al azar
        todasLasPreguntas.shuffle();

        // 3. ¡EL TRUCO! Solo tomamos las primeras 10 de la lista ya revuelta
        preguntas = todasLasPreguntas.take(10).toList();

        cargando = false;
      });
    } catch (e) {
      debugPrint("Error cargando JSON: $e");
      setState(() => cargando = false);
    }
  }

  // --- 2. LÓGICA DE RESPUESTA ---
  void _verificarRespuesta(int indexSeleccionado) {
    PreguntaModel preguntaActual = preguntas[preguntaActualIndex];
    bool esCorrecta =
        indexSeleccionado == preguntaActual.respuestaCorrectaIndex;

    if (esCorrecta) {
      puntuacion++;
    }

    // Muestra la retroalimentación antes de avanzar
    _mostrarRetroalimentacion(esCorrecta, preguntaActual);
  }

  void _mostrarRetroalimentacion(bool esCorrecta, PreguntaModel pregunta) {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Obliga al usuario a tocar el botón para continuar
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                esCorrecta ? Icons.check_circle : Icons.cancel,
                color: esCorrecta ? Colors.green : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 15),
              Text(
                esCorrecta ? "¡Correcto!" : "Incorrecto",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: esCorrecta ? Colors.green[800] : Colors.red[800],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                pregunta.retroalimentacion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000), // Guinda UTM
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Cierra el modal
                    _siguientePregunta();
                  },
                  child: const Text(
                    "Continuar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _siguientePregunta() {
    setState(() {
      if (preguntaActualIndex < preguntas.length - 1) {
        preguntaActualIndex++;
      } else {
        // Fin de la trivia
        _mostrarResultadosFinales();
      }
    });
  }

  void _mostrarResultadosFinales() {
    ScoreManager.checkAndSaveScore('highscore_trivia', puntuacion, context: context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Trivia Finalizada", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 80, color: Color(0xFF800000)),
              const SizedBox(height: 20),
              Text(
                "Puntaje: $puntuacion / ${preguntas.length}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Regresa al mapa (o pantalla anterior)
              },
              child: const Text(
                "Volver al Mapa",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                setState(() {
                  cargando = true;
                  preguntaActualIndex = 0;
                  puntuacion = 0;
                });
                _cargarPreguntas(); // Recarga las preguntas (las vuelve a barajar)
              },
              child: const Text(
                "Reintentar",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- 3. INTERFAZ GRÁFICA ---
  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5DC), // Beige
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF800000)),
        ),
      );
    }

    if (preguntas.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Error: No se encontraron preguntas.")),
      );
    }

    PreguntaModel preguntaActual = preguntas[preguntaActualIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Beige institucional
      appBar: AppBar(
        title: Text(
          tituloTrivia,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF800000), // Guinda UTM
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de progreso
            LinearProgressIndicator(
              value: (preguntaActualIndex + 1) / preguntas.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF800000),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Pregunta ${preguntaActualIndex + 1} de ${preguntas.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de la Pregunta
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    preguntaActual.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF800000),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    preguntaActual.pregunta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Botones de Opciones
            Expanded(
              child: ListView.separated(
                itemCount: preguntaActual.opciones.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => _verificarRespuesta(index),
                    child: Text(
                      preguntaActual.opciones[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
