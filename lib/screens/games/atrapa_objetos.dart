import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:utmapa/models/objeto_cayendo.dart';

class AtrapaObjetosScreen extends StatefulWidget {
  const AtrapaObjetosScreen({super.key});

  @override
  State<AtrapaObjetosScreen> createState() => _AtrapaObjetosScreenState();
}

class _AtrapaObjetosScreenState extends State<AtrapaObjetosScreen> {
  double mochilaX = 0;
  int puntuacion = 0;
  int vidas = 3; // Iniciamos con 3 vidas
  bool enJuego = false, juegoTerminado = false;

  List<ObjetoCayendo> objetos = [];
  final Random _random = Random();

  // Eliminamos el gameTimer del reloj
  Timer? physicsTimer, spawnTimer;

  final List<IconData> iconosBuenos = [
    Icons.auto_stories, // Libro
    Icons.edit, // Lápiz/Editar
    Icons.terminal, // Terminal de comandos
    Icons.calculate, // Calculadora
    Icons.science, // Matraz de laboratorio
    Icons.computer, // Computadora
  ];

  final List<IconData> iconosMalos = [
    Icons.bug_report, // Bug de código
    Icons.coronavirus, // Virus/Enfermedad
    Icons.warning_amber, // Alerta
    Icons.cancel, // Tache/Reprobado
  ];

  @override
  void dispose() {
    physicsTimer?.cancel();
    spawnTimer?.cancel();
    super.dispose();
  }

  void _iniciarJuego() {
    setState(() {
      enJuego = true;
      juegoTerminado = false;
      puntuacion = 0;
      vidas = 3;
      objetos.clear();
      mochilaX = 0;
    });

    physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!enJuego) return;

      setState(() {
        for (var i = objetos.length - 1; i >= 0; i--) {
          // Aumentamos ligeramente la velocidad base para compensar que no hay límite de tiempo
          objetos[i].y += 0.018;

          // Detección de colisión con la mochila
          if (objetos[i].y >= 0.80 && objetos[i].y <= 0.95) {
            double diferenciaX = (objetos[i].x - mochilaX).abs();

            if (diferenciaX <= 0.25) {
              if (objetos[i].esBueno) {
                puntuacion++; // +1 punto
              } else {
                vidas--; // -1 vida por atrapar un bug
                if (vidas <= 0) _terminarJuego();
              }
              objetos.removeAt(i);
              continue;
            }
          }

          // Si el objeto sale por la parte inferior de la pantalla
          if (objetos[i].y > 1.1) {
            // ¡PENALIZACIÓN! Si dejó caer algo bueno, pierde una vida
            if (objetos[i].esBueno) {
              vidas--;
              if (vidas <= 0) _terminarJuego();
            }
            objetos.removeAt(i);
          }
        }
      });
    });

    spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!enJuego) return;
      _generarObjeto();
    });
  }

  void _generarObjeto() {
    bool esBueno = _random.nextDouble() > 0.3; // 70% probabilidad de ser bueno
    double posInicialX = (_random.nextDouble() * 1.8) - 0.9;

    IconData iconoElegido = esBueno
        ? iconosBuenos[_random.nextInt(iconosBuenos.length)]
        : iconosMalos[_random.nextInt(iconosMalos.length)];

    Color colorElegido = esBueno ? Colors.blueAccent : Colors.redAccent;

    setState(() {
      objetos.add(
        ObjetoCayendo(
          x: posInicialX,
          y: -1.1,
          esBueno: esBueno,
          icono: iconoElegido,
          color: colorElegido,
        ),
      );
    });
  }

  void _terminarJuego() {
    setState(() {
      enJuego = false;
      juegoTerminado = true;
    });
    physicsTimer?.cancel();
    spawnTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (!enJuego) return;
          setState(() {
            mochilaX += details.delta.dx * 0.007;
            mochilaX = mochilaX.clamp(-0.9, 0.9);
          });
        },
        child: Stack(
          children: [
            Container(color: const Color(0xFFF5F5DC)), // Beige fondo
            CustomPaint(size: Size.infinite, painter: PatioPainter()),

            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(child: _buildMarcadorVidas()),
            ),

            ...objetos.map(
              (obj) => Align(
                alignment: Alignment(obj.x, obj.y),
                child: Icon(obj.icono, size: 45, color: obj.color),
              ),
            ),

            Align(
              alignment: Alignment(mochilaX, 0.85),
              child: const Icon(
                Icons.backpack,
                size: 90,
                color: Color(0xFF800000), // Guinda UTM
              ),
            ),

            if (!enJuego && !juegoTerminado)
              Align(
                alignment: const Alignment(0, 0.2),
                child: _buildBotonInicio(),
              ),

            if (juegoTerminado) _buildResultadoFinal(),
          ],
        ),
      ),
    );
  }

  Widget _buildMarcadorVidas() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ), // Ajustado al quitar el reloj
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < vidas ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 30,
              );
            }),
          ),
          const VerticalDivider(
            color: Colors.white24,
            indent: 15,
            endIndent: 15,
            width: 30,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "PUNTOS",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$puntuacion",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultadoFinal() {
    // Como es supervivencia, siempre se termina perdiendo vidas, el objetivo es el puntaje.
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF800000), width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.heart_broken, size: 80, color: Colors.red),
              const SizedBox(height: 10),
              const Text(
                "GAME OVER",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF800000),
                ),
              ),
              const Divider(height: 30),
              const Text(
                "Puntuación Final:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "$puntuacion",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "SALIR",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                    ),
                    onPressed: _iniciarJuego,
                    child: const Text(
                      "REINTENTAR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonInicio() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF800000),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: _iniciarJuego,
      child: const Text(
        "EMPEZAR DESAFÍO",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PatioPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF800000).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double step = 30;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
