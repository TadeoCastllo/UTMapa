import 'dart:math';

class BoardCell {
  String letter;
  bool isSelected;
  bool isFound;

  BoardCell({
    required this.letter,
    this.isSelected = false,
    this.isFound = false,
  });
}

class SopaLogic {
  final int gridSize = 10;

  List<List<BoardCell>> generarTableroCompleto(
    int size,
    List<String> palabras,
  ) {
    // 1. Crear tablero vacío (usamos un espacio vacío como marcador)
    List<List<BoardCell>> grid = List.generate(
      size,
      (_) => List.generate(size, (_) => BoardCell(letter: "")),
    );

    // 2. Insertar las 5 palabras seleccionadas
    for (String palabra in palabras) {
      _intentarInsertarPalabra(grid, palabra.toUpperCase());
    }

    // 3. Rellenar los huecos restantes con letras aleatorias
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c].letter == "") {
          grid[r][c].letter = _letraAleatoria();
        }
      }
    }
    return grid;
  }

  void _intentarInsertarPalabra(List<List<BoardCell>> grid, String palabra) {
    Random rand = Random();
    bool colocada = false;
    int intentos = 0;

    // Definimos las direcciones posibles: [fila, columna]
    List<List<int>> direcciones = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal abajo-derecha
    ];

    while (!colocada && intentos < 200) {
      int row = rand.nextInt(gridSize);
      int col = rand.nextInt(gridSize);
      List<int> dir = direcciones[rand.nextInt(direcciones.length)];

      int dR = dir[0];
      int dC = dir[1];

      // Verificar si la palabra cabe en el tablero
      if (row + dR * (palabra.length - 1) < gridSize &&
          col + dC * (palabra.length - 1) < gridSize &&
          row + dR * (palabra.length - 1) >= 0 &&
          col + dC * (palabra.length - 1) >= 0) {
        // VALIDACIÓN: ¿El camino está despejado o tiene la misma letra?
        bool espacioLibre = true;
        for (int i = 0; i < palabra.length; i++) {
          String letraExistente = grid[row + i * dR][col + i * dC].letter;
          if (letraExistente != "" && letraExistente != palabra[i]) {
            espacioLibre = false;
            break;
          }
        }

        // Si el espacio es apto, escribimos la palabra completa
        if (espacioLibre) {
          for (int i = 0; i < palabra.length; i++) {
            grid[row + i * dR][col + i * dC].letter = palabra[i];
          }
          colocada = true;
        }
      }
      intentos++;
    }
  }

  String _letraAleatoria() {
    const letras = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ";
    return letras[Random().nextInt(letras.length)];
  }
}