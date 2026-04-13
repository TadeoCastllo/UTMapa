import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
class ScoreManager {
  // Llaves únicas
  static const String _keyMochila = 'highscore_mochila';
  static const String _keyTrivia = 'highscore_trivia';
  static const String _keyFutbol = 'highscore_futbol';
  static const String _keySopaTime = 'best_time_sopa'; // En segundos

  // --- GETTERS ---
  static Future<int> getScore(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  // --- LÓGICA DE GUARDADO (Puntos: Mayor es mejor) ---
  static Future<bool> checkAndSaveScore(String key, int newScore, {BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    int currentRecord = prefs.getInt(key) ?? 0;
    if (newScore > currentRecord) {
      await prefs.setInt(key, newScore);
      if (context != null && context.mounted) {
        Confetti.launch(context, options: const ConfettiOptions(particleCount: 150, spread: 70, y: 0.6));
      }
      return true;
    }
    return false;
  }

  // --- LÓGICA PARA SOPA DE LETRAS (Tiempo: Menor es mejor) ---
  static Future<bool> checkAndSaveTime(int newTimeSeconds, {BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    int bestTime = prefs.getInt(_keySopaTime) ?? 999999; // Un tiempo muy alto si no hay record
    
    if (newTimeSeconds < bestTime) {
      await prefs.setInt(_keySopaTime, newTimeSeconds);
      if (context != null && context.mounted) {
        Confetti.launch(context, options: const ConfettiOptions(particleCount: 150, spread: 70, y: 0.6));
      }
      return true;
    }
    return false;
  }

  // Helper para mostrar el tiempo en formato MM:SS
  static String formatTime(int seconds) {
    if (seconds == 999999 || seconds == 0) return "--:--";
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }
}