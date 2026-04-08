import 'package:flutter/material.dart';
import '../core/constants.dart';

class DetailsScreen extends StatelessWidget {
  final String nombre;
  final String zona;
  final String descripcion;
  final String horario;
  final String redWifi;
  final Widget juegoDestino;
  final IconData iconoPrincipal;

  const DetailsScreen({
    super.key,
    required this.nombre,
    required this.zona,
    required this.descripcion,
    required this.horario,
    required this.redWifi,
    required this.juegoDestino,
    required this.iconoPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(UTMConstants.colorBeige),
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
                nombre,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(UTMConstants.colorGuinda),
                ),
              ),
              Text(
                "📍 $zona",
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
              const SizedBox(height: 25),

              // Contenedor de Imagen con Icono Representativo
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(
                    UTMConstants.colorGuinda,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(
                      UTMConstants.colorGuinda,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  iconoPrincipal,
                  size: 100,
                  color: const Color(UTMConstants.colorGuinda),
                ),
              ),

              const SizedBox(height: 25),

              // Fichas de Información
              Row(
                children: [
                  _infoCard(Icons.access_time_filled, "HORARIO", horario),
                  const SizedBox(width: 15),
                  _infoCard(
                    redWifi == "No disponible" ? Icons.wifi_off : Icons.wifi,
                    "CONECTIVIDAD",
                    redWifi,
                  ),
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
                descripcion,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Botón de Lanzamiento de Juego Estilo Card
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
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        UTMConstants.colorGuinda,
                      ).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Reto Disponible",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Completa el desafío para ganar puntos",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => juegoDestino),
                      ),
                      child: const Text(
                        "INICIAR JUEGO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.1,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
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
