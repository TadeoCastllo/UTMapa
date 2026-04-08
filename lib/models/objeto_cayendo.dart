import 'package:flutter/material.dart';

class ObjetoCayendo {
  double x;
  double y;
  final IconData icono;
  final bool esBueno;
  final Color color;

  ObjetoCayendo({
    required this.x,
    required this.y,
    required this.icono,
    required this.esBueno,
    required this.color,
  });
}