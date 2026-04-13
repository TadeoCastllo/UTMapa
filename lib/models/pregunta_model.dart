class PreguntaModel {
  final int id;
  final String categoria;
  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrectaIndex;
  final String retroalimentacion;

  PreguntaModel({
    required this.id,
    required this.categoria,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrectaIndex,
    required this.retroalimentacion,
  });

  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      id: json['id'],
      categoria: json['categoria'],
      pregunta: json['pregunta'],
      opciones: List<String>.from(json['opciones']),
      respuestaCorrectaIndex: json['respuestaCorrectaIndex'],
      retroalimentacion: json['retroalimentacion'],
    );
  }
}