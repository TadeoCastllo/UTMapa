import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'sopa_logic.dart';

class SopaLetrasScreen extends StatefulWidget {
  const SopaLetrasScreen({super.key});

  @override
  State<SopaLetrasScreen> createState() => _SopaLetrasScreenState();
}

class _SopaLetrasScreenState extends State<SopaLetrasScreen> {
  final SopaLogic logic = SopaLogic();
  late List<List<BoardCell>> board;
  List<BoardCell> currentSelection = [];
  List<String> foundWords = [];
  List<String> palabrasJuego = [];
  int? startR, startC;
  int timeLeft = 120;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _initNewGame();
  }

  void _initNewGame() {
    setState(() {
      // Seleccionar 5 palabras aleatorias del banco
      final random = Random();
      List<String> copia = List.from(UTMConstants.bancoPalabras)
        ..shuffle(random);
      palabrasJuego = copia.take(5).toList();

      board = logic.generarTableroCompleto(10, palabrasJuego);
      foundWords.clear();
      timeLeft = 120;
      currentSelection.clear();
    });
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        if (mounted) setState(() => timeLeft--);
      } else {
        _endGame(false);
      }
    });
  }

  void _onCellTap(int r, int c) {
    setState(() {
      BoardCell cell = board[r][c];
      if (!cell.isFound) {
        cell.isSelected = !cell.isSelected;
        if (cell.isSelected) {
          currentSelection.add(cell);
        } else {
          currentSelection.remove(cell);
        }
        _validateWord();
      }
    });
  }

  void _onPanStart(int r, int c) {
    startR = r;
    startC = c;
    _clearTempSelection();
  }

  void _updateLineSelection(int endR, int endC) {
    if (startR == null || startC == null) return;
    int dR = endR - startR!;
    int dC = endC - startC!;

    if (dR == 0 || dC == 0) {
      setState(() {
        _clearTempSelection();
        int sR = dR == 0 ? 0 : dR.sign;
        int sC = dC == 0 ? 0 : dC.sign;
        int steps = dR.abs() > dC.abs() ? dR.abs() : dC.abs();

        for (int i = 0; i <= steps; i++) {
          int currR = startR! + (i * sR);
          int currC = startC! + (i * sC);
          if (currR >= 0 && currR < 10 && currC >= 0 && currC < 10) {
            board[currR][currC].isSelected = true;
            currentSelection.add(board[currR][currC]);
          }
        }
      });
    }
  }

  void _validateWord() {
    String sel = currentSelection.map((e) => e.letter).join();
    String rev = sel.split('').reversed.join();

    if (palabrasJuego.contains(sel) || palabrasJuego.contains(rev)) {
      setState(() {
        for (var cell in currentSelection) {
          cell.isFound = true;
          cell.isSelected = false;
        }
        String word = palabrasJuego.contains(sel) ? sel : rev;
        if (!foundWords.contains(word)) foundWords.add(word);
        currentSelection.clear();
      });
    }
    if (foundWords.length == palabrasJuego.length) _endGame(true);
  }

  void _clearTempSelection() {
    for (var r in board) {
      for (var c in r) {
        if (!c.isFound) c.isSelected = false;
      }
    }
    currentSelection.clear();
  }

  void _endGame(bool win) {
    timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(win ? "¡Victoria!" : "Tiempo agotado"),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: const Text("SALIR"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initNewGame();
            },
            child: const Text("REINTENTAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(UTMConstants.colorBeige),
      appBar: AppBar(
        title: Text("Sopa de Letras ($timeLeft s)"),
        backgroundColor: const Color(UTMConstants.colorGuinda),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          // Tablero
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: MediaQuery.of(context).size.width,
            // --- CAMBIO AQUÍ: Centramos el grid ---
            child: Center(child: _buildGrid()),
          ),
          const SizedBox(height: 15),
          const Text(
            "PALABRAS A BUSCAR",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(UTMConstants.colorGuinda),
            ),
          ),
          const SizedBox(height: 10),
          // Lista de palabras centrada
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCenteredWordList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize = constraints.maxWidth / 10;
        return GestureDetector(
          onPanStart: (d) {
            int r = (d.localPosition.dy / cellSize).floor();
            int c = (d.localPosition.dx / cellSize).floor();
            if (r >= 0 && r < 10 && c >= 0 && c < 10) _onPanStart(r, c);
          },
          onPanUpdate: (d) {
            int r = (d.localPosition.dy / cellSize).floor();
            int c = (d.localPosition.dx / cellSize).floor();
            if (r >= 0 && r < 10 && c >= 0 && c < 10) {
              _updateLineSelection(r, c);
            }
          },
          onPanEnd: (_) {
            _validateWord();
            setState(() => _clearTempSelection());
          },
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              int r = index ~/ 10;
              int c = index % 10;
              BoardCell cell = board[r][c];
              return GestureDetector(
                onTap: () => _onCellTap(r, c),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: cell.isFound
                        ? Colors.green.withValues(alpha: 0.4)
                        : (cell.isSelected ? Colors.yellow : Colors.white),
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      cell.letter,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCenteredWordList() {
    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 15,
        runSpacing: 10,
        children: palabrasJuego.map((w) {
          bool f = foundWords.contains(w);
          return Text(
            w,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              decoration: f ? TextDecoration.lineThrough : null,
              color: f ? Colors.grey[600] : Colors.black87,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
