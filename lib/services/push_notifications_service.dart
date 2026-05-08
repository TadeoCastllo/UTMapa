import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Manejador de notificaciones en segundo plano (debe ser de nivel superior)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializa Firebase para asegurarte de poder usar otros servicios si es necesario
  await Firebase.initializeApp();
  debugPrint('=== Notificación en Segundo Plano (Background) ===');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}

class PushNotificationsService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? token;

  static Future<void> initializeApp() async {
    // 1. Solicitar permisos (Requerido para iOS y Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permisos de notificación: ${settings.authorizationStatus}');

    // 2. Obtener el Token de FCM
    try {
      token = await _messaging.getToken();
      debugPrint('=== FCM TOKEN ===');
      debugPrint(token);
      debugPrint('=================');
    } catch (e) {
      debugPrint('Error al obtener el FCM Token: $e');
    }

    // 3. Suscribirse a un tema general (para enviar a todos sin necesidad del Token)
    try {
      await _messaging.subscribeToTopic('todos');
      debugPrint('Suscrito exitosamente al tema: "todos"');
    } catch (e) {
      debugPrint('Error al suscribirse al tema: $e');
    }

    // 4. Configurar los manejadores de mensajes

    // A) Cuando la aplicación está en segundo plano o terminada
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // B) Cuando la aplicación está abierta y en primer plano (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('=== Notificación en Primer Plano (Foreground) ===');
      if (message.notification != null) {
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
      }
    });

    // C) Cuando se abre la aplicación al tocar una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('=== App abierta desde una notificación ===');
      debugPrint('Message ID: ${message.messageId}');
      // Aquí podrías redirigir a una pantalla específica según message.data
    });
  }
}
