import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'device_service.dart';

// ✅ NavigatorKey global (ponlo en tu MaterialApp)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PushService {
  static final _messaging = FirebaseMessaging.instance;

  static const _storage = FlutterSecureStorage();
  static const _kLastRegisteredFcm = 'lastRegisteredFcmToken';

  // ✅ Local notifications para cuando la app está abierta
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String topicNews = 'news';
  static const String topicLostFound = 'lost_found';

  static Future<void> initAndRegister() async {
    // 0) Inicializa local notifications (con handler de tap)
    await _initLocalNotifications();

    // ✅ A) Handlers cuando el usuario TOCA una notificación (background/cerrada)
    await _setupFirebaseTapHandlers();

    // 1) Permisos (iOS sí o sí, Android 13+ también)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // iOS: permitir banners en foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2) Token actual
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerIfNeeded(token);
    }

    // 2.1) Suscribirse a topics
    await _subscribeTopics();

    // 3) Cuando cambia el token, lo registramos de nuevo
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.isNotEmpty) {
        await _registerIfNeeded(newToken);
      }
    });

    // ✅ 4) Foreground: llega push con app abierta → mostramos notificación local
    FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
      final n = m.notification;
      final title = n?.title ?? 'Nueva notificación';
      final body = n?.body ?? '';

      // Importante: guardamos data para navegar al tocarla
      await _showLocalNotification(title: title, body: body, data: m.data);
    });
  }

  // -----------------------
  // ✅ Navegación por push
  // -----------------------
  static Future<void> _setupFirebaseTapHandlers() async {
    // App en background y se abrió por tocar la notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageNavigation);

    // App cerrada y se abrió por tocar la notificación
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleRemoteMessageNavigation(initial);
  }

  static void _handleRemoteMessageNavigation(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final rawTipo = (data['tipo'] ?? '').toString().trim();
    if (rawTipo.isEmpty) return;

    // Soporta:
    // - "objeto_perdido123"
    // - "objeto_perdido:123"
    // - "objeto_perdido_123"
    // - "publicacion45", etc.
    String tipo = rawTipo;
    String? id;

    // si viene con separador (":", "_", "-"), partimos ahí
    final sepMatch = RegExp(r'^([a-zA-Z_]+)[:_\-](.+)$').firstMatch(rawTipo);
    if (sepMatch != null) {
      tipo = sepMatch.group(1) ?? rawTipo;
      id = sepMatch.group(2);
    } else {
      // si viene pegado al final en números: objeto_perdido123
      final gluedMatch = RegExp(r'^([a-zA-Z_]+)(\d+)$').firstMatch(rawTipo);
      if (gluedMatch != null) {
        tipo = gluedMatch.group(1) ?? rawTipo;
        id = gluedMatch.group(2);
      }
    }

    // Normalizamos
    tipo = tipo.toLowerCase();

    if (tipo == 'objeto_perdido') {
      // Si tienes ruta de detalle, úsala con el id.
      // Ejemplo:
      // navigatorKey.currentState?.pushNamed('/student_objetos_perdidos_detalle', arguments: {'id': id});
      navigatorKey.currentState?.pushNamed('/student_objetos_perdidos');
      return;
    }

    if (tipo == 'publicacion') {
      // Igual: si tienes detalle, usa id como argumento.
      navigatorKey.currentState?.pushNamed('/student_noticias');
      return;
    }

    // fallback (opcional)
    // navigatorKey.currentState?.pushNamed('/home');
  }

  // -----------------------
  // Topics + register/unregister
  // -----------------------
  static Future<void> _subscribeTopics() async {
    try {
      await _messaging.subscribeToTopic(topicNews);
      await _messaging.subscribeToTopic(topicLostFound);
    } catch (_) {
      // best-effort
    }
  }

  static Future<void> _unsubscribeTopics() async {
    try {
      await _messaging.unsubscribeFromTopic(topicNews);
      await _messaging.unsubscribeFromTopic(topicLostFound);
    } catch (_) {
      // best-effort
    }
  }

  static Future<void> _registerIfNeeded(String token) async {
    try {
      final last = await _storage.read(key: _kLastRegisteredFcm);
      if (last == token) return;

      await DeviceService.register(
        fcmToken: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      await _storage.write(key: _kLastRegisteredFcm, value: token);
    } catch (_) {
      // push nunca debe tumbar la app
    }
  }

  static Future<void> unregister() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await DeviceService.unregister(fcmToken: token);

      // quita topics al cerrar sesión (recomendado)
      await _unsubscribeTopics();

      await _storage.delete(key: _kLastRegisteredFcm);
    } catch (_) {
      // best-effort
    }
  }

  // -----------------------
  // Local notifications (foreground)
  // -----------------------
  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // ✅ Cuando el usuario toca la notificación local
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;

        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            _navigateFromData(decoded);
          } else if (decoded is Map) {
            _navigateFromData(decoded.map((k, v) => MapEntry('$k', v)));
          }
        } catch (_) {
          // ignore
        }
      },
    );
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'uidehub_channel',
      'Notificaciones UIDEHub',
      channelDescription: 'Noticias y objetos perdidos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    // ✅ Guardamos data como payload para navegar al tocarla
    final payload = jsonEncode(data ?? const <String, dynamic>{});

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
