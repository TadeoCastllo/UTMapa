import '../../models/poi_model.dart';

List<POIModel> mockPois = [
  POIModel(
    id: 'poi_001',
    name: 'Biblioteca Central',
    description:
        'Espacio dedicado al estudio, consulta de acervo bibliográfico y desarrollo académico. Aquí podrás encontrar literatura de todas las ingenierías.',
    imageUrls: [
      'assets/images/biblioteca_1.jpg',
      'assets/images/biblioteca_2.jpg',
      // Solo asegúrense de tener estas imágenes en su carpeta de assets
    ],
    // Coordenadas de prueba (sustitúyelas por las reales de la UTM en Google Maps)
    latitude: 17.8055,
    longitude: -97.7733,
    schedule: 'Lunes a Viernes: 8:00 hrs - 20:00 hrs',
    gameRoute: '/sopa-letras', // Así saben qué juego abrir desde aquí
  ),
  POIModel(
    id: 'poi_002',
    name: 'Edificio de Ingenierías',
    description: 'Edificio de Ingenierías',
    imageUrls: [
      'assets/images/biblioteca_1.jpg',
      'assets/images/biblioteca_2.jpg',
    ],
    latitude: 20.6667,
    longitude: -103.3333,
    schedule: 'Lunes a Viernes: 8:00 hrs - 20:00 hrs',
    gameRoute: '/sopa-letras',
  ),
];
