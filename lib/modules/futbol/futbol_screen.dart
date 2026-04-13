import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Importación necesaria
import 'package:utmapa/core/score_manager.dart';
import '../../core/constants.dart';

class FutbolScreen extends StatefulWidget {
  const FutbolScreen({super.key});

  @override
  State<FutbolScreen> createState() => _FutbolScreenState();
}

class _FutbolScreenState extends State<FutbolScreen> {
  double porteroX = 0, balonY = 0.7, balonX = 0;
  int puntosUTM = 0, puntosIA = 0, tiempoRestante = 60;
  bool disparando = false, juegoTerminado = false;
  double velPortero = 0.05;

  // Timers y Subscripciones
  Timer? gameTimer, porteroTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _iniciarPartido();
    _iniciarSensores(); // Activamos los sensores al iniciar
  }

  void _iniciarSensores() {
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      if (!mounted || disparando || juegoTerminado) return;

      setState(() {
        // Ajuste de rango estricto: -0.6 a 0.6 para no rebasar los postes
        // Reduje un poco la sensibilidad (* -0.12) para que sea más fácil de controlar
        balonX = (event.x * -0.12).clamp(-0.6, 0.6);
      });
    });
  }

  void _iniciarPartido() {
    porteroTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!mounted || disparando || juegoTerminado) {
        return;
      }
      setState(() {
        porteroX += velPortero;
        if (porteroX >= 0.7 || porteroX <= -0.7) {
          velPortero *= -1;
        }
      });
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (tiempoRestante > 0) {
        setState(() {
          tiempoRestante--;
        });
      } else {
        setState(() {
          juegoTerminado = true;
        });
        ScoreManager.checkAndSaveScore(
          'highscore_futbol',
          puntosUTM,
          context: context,
        );
        t.cancel();
      }
    });
  }

  void _patear() {
    if (disparando || juegoTerminado) {
      return;
    }
    setState(() => disparando = true);

    Timer.periodic(const Duration(milliseconds: 25), (t) {
      setState(() {
        balonY -= 0.08; // El balón avanza hacia la portería

        // 1. ZONA DE IMPACTO (Línea del portero)
        if (balonY <= -0.62) {
          double diferencia = (balonX - porteroX).abs();

          if (diferencia <= 0.28) {
            // --- ES ATAJADA ---
            balonY = -0.62; // SE DETIENE EN SECO en el portero
            t.cancel();
            _procesarResultado(false);
          }
          // 2. LÍMITE DE LA RED (GOL)
          // Reducimos el límite de -0.95 a -0.78 para que no se pase
          else if (balonY <= -0.62) {
            // --- ES GOL ---
            balonY = -0.62; // SE DETIENE EN SECO dentro de la red
            t.cancel();
            _procesarResultado(true);
          }
        }
      });
    });
  }

  void _procesarResultado(bool esGol) {
    setState(() {
      if (esGol) {
        puntosUTM++;
      } else {
        puntosIA++;
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          balonY = 0.7;
          disparando = false;
          // Al reiniciar la posición Y, los sensores vuelven a tomar control de balonX
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.green[800]),
          CustomPaint(size: Size.infinite, painter: CanchaPainter()),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(child: _buildMarcadorElegante()),
          ),
          Align(alignment: const Alignment(0, -0.65), child: _buildPorteria()),
          AnimatedAlign(
            alignment: Alignment(porteroX, -0.62),
            duration: const Duration(milliseconds: 30),
            child: Icon(
              Icons.accessibility_new,
              size: 80,
              color:
                  (disparando &&
                      (balonX - porteroX).abs() <= 0.28 &&
                      balonY <= -0.6)
                  ? Colors.yellow
                  : Colors.red,
            ),
          ),
          Align(
            alignment: Alignment(balonX, balonY),
            child: const Icon(
              Icons.sports_soccer,
              size: 45,
              color: Colors.white,
            ),
          ),
          if (!juegoTerminado)
            Align(
              alignment: const Alignment(0, 0.88),
              child: _buildBotonDisparo(),
            ),
          if (juegoTerminado) _buildResultadoChampion(),
        ],
      ),
    );
  }

  Widget _buildMarcadorElegante() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoEquipo(
              "UTM",
              const Color(UTMConstants.colorGuinda),
              puntosUTM,
            ),
            const VerticalDivider(
              color: Colors.white10,
              indent: 15,
              endIndent: 15,
              width: 20,
            ),
            _buildInfoEquipo(
              "IA",
              Colors.blueGrey[700]!,
              puntosIA,
              reverse: true,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${tiempoRestante}s",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoEquipo(
    String nombre,
    Color color,
    int score, {
    bool reverse = false,
  }) {
    List<Widget> items = [
      Text(
        nombre,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(width: 10),
      Container(
        width: 45,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          "$score",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: reverse ? items.reversed.toList() : items,
    );
  }

  Widget _buildResultadoChampion() {
    String mensaje = puntosUTM > puntosIA
        ? "GANASTE"
        : (puntosUTM < puntosIA ? "DERROTA" : "EMPATE");
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(UTMConstants.colorBeige),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(UTMConstants.colorGuinda),
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
              const Text(
                "CHAMPION",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Color(UTMConstants.colorGuinda),
                ),
              ),
              const Divider(height: 30),
              Text(
                mensaje,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: puntosUTM >= puntosIA
                      ? Colors.green[800]
                      : Colors.red[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "UTM $puntosUTM  -  $puntosIA IA",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("SALIR"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(UTMConstants.colorGuinda),
                    ),
                    onPressed: () {
                      setState(() {
                        puntosUTM = 0;
                        puntosIA = 0;
                        tiempoRestante = 60;
                        juegoTerminado = false;
                        balonY = 0.7;
                      });
                      _iniciarPartido();
                    },
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

  Widget _buildPorteria() {
    return Container(
      width: 280,
      height: 140,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.8),
            width: 6,
          ),
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.8),
            width: 6,
          ),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 6),
        ),
      ),
    );
  }

  Widget _buildBotonDisparo() {
    return GestureDetector(
      onTap: _patear,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(UTMConstants.colorGuinda),
          borderRadius: BorderRadius.circular(40),
        ),
        child: const Text(
          "PATEAR PENAL",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    porteroTimer?.cancel();
    gameTimer?.cancel();
    _accelerometerSubscription
        ?.cancel(); // IMPORTANTE: Cancelar la subscripción
    super.dispose();
  }
}

class CanchaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (int i = 0; i < 10; i++) {
      var stripePaint = Paint()
        ..color = i % 2 == 0
            ? const Color(0xFF1B5E20)
            : const Color(0xFF2E7D32);
      canvas.drawRect(
        Rect.fromLTWH(0, size.height * (i / 10), size.width, size.height / 10),
        stripePaint,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.05,
        size.width * 0.9,
        size.height * 0.9,
      ),
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 70, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
