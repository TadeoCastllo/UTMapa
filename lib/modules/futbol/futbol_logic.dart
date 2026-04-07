class FutbolLogic {
  int goles = 0;
  final int golesParaGanar = 3;

  bool esAtajada(double balonX, double porteroX) {
    return (balonX - porteroX).abs() < 0.3; // Rango de colisión
  }
}
