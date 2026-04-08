class POIModel {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls; // Lista porque pide galería de imágenes
  final double latitude;
  final double longitude;
  final String schedule; // Horario del lugar
  final String gameRoute; // La ruta para lanzar el juego desde este lugar

  // Constructor
  POIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.schedule,
    required this.gameRoute,
  });

  // (Opcional pero recomendado) Factory para crear un POI desde un JSON en el futuro
  factory POIModel.fromJson(Map<String, dynamic> json) {
    return POIModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrls: List<String>.from(json['imageUrls']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      schedule: json['schedule'],
      gameRoute: json['gameRoute'],
    );
  }
}