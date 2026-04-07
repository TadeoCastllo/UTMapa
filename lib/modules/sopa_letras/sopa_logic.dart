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
    List<List<BoardCell>> grid = List.generate(
      size,
      (_) => List.generate(size, (_) => BoardCell(letter: _letraAleatoria())),
    );

    for (String palabra in palabras) {
      _insertarPalabra(grid, palabra.toUpperCase());
    }
    return grid;
  }

  void _insertarPalabra(List<List<BoardCell>> grid, String palabra) {
    Random rand = Random();
    bool colocada = false;
    int intentos = 0;

    while (!colocada && intentos < 100) {
      int row = rand.nextInt(gridSize);
      int col = rand.nextInt(gridSize);
      bool horizontal = rand.nextBool();

      if (horizontal && col + palabra.length <= gridSize) {
        for (int i = 0; i < palabra.length; i++)
          grid[row][col + i].letter = palabra[i];
        colocada = true;
      } else if (!horizontal && row + palabra.length <= gridSize) {
        for (int i = 0; i < palabra.length; i++)
          grid[row + i][col].letter = palabra[i];
        colocada = true;
      }
      intentos++;
    }
  }

  String _letraAleatoria() {
    const letras = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ";
    return letras[Random().nextInt(letras.length)];
  }
}
