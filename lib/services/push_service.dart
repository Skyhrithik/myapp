// lib/services/push_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart'; // AppConfig.baseUrl

/// We navigate from notification taps using this global key.
/// In MaterialApp, set: navigatorKey: navServiceKey
final GlobalKey<NavigatorState> navServiceKey = GlobalKey<NavigatorState>();

/// Background FCM handler (must be top-level).
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  // Keep light: Android shows system notification if your FCM has "notification" payload.
  // If you only send "data" payloads, consider initializing and showing a local notification here.
}

/// ------- Local notifications setup -------
final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'fps_default_channel',
  'FPS Notifications',
  description: 'Order updates and alerts',
  importance: Importance.high,
);

class PushService {
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;

    // 1) Ask permission (iOS; on Android 13+ you must also declare POST_NOTIFICATIONS in Manifest)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    // 2) Create local notification channel & initialize plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (resp) {
        // Handle taps on local notifications (foreground)
        final payload = resp.payload ?? '';
        _openFromPayload(payload);
      },
    );

    // Channel for Android
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // 3) Register background handler
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

    // 4) Foreground messages -> show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      final n = msg.notification;
      final title = n?.title ?? 'Fair Price Shop';
      final body = n?.body ?? 'You have a new update';
      final payload = _payloadFromData(msg.data); // keep simple

      await _local.show(
        msg.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    });

    // 5) Taps when app in background/terminated (remote)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      _openFromData(msg.data);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openFromData(initial.data),
      );
    }

    // 6) Get token & persist. (Register with backend happens after login.)
    await _refreshAndStoreToken();

    // If token rotates later:
    FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', t);
      // We only register token with backend once the user is logged in (see registerDeviceWithBackend).
    });
  }

  /// Call this after login (and also at cold start if user already logged in).
  static Future<void> registerDeviceWithBackend({
    required String authToken,
    required int userId,
    bool isAdmin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    await prefs.setString('fcm_token', token);
    await prefs.setInt('user_id', userId);

    // POST to your Django endpoint (adjust path to your API)
    final uri = Uri.parse('${AppConfig.baseUrl}/me/devices/');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: jsonEncode({
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'is_admin': isAdmin,
        }),
      );
      debugPrint('Device register: ${res.statusCode} ${res.body}');
    } catch (e) {
      debugPrint('Device register error: $e');
    }
  }

  /// Optional: call on logout
  static Future<void> unregisterDevice({required String authToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fcm_token');
    if (token == null) return;
    final uri = Uri.parse('${AppConfig.baseUrl}/me/devices/delete/');
    try {
      await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {}
    await prefs.remove('fcm_token');
  }

  /// At startup (app already has a logged-in user), try to register silently.
  static Future<void> tryRegisterIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final auth = prefs.getString('token');
    final uid = prefs.getInt('user_id');
    if (auth != null && auth.isNotEmpty && uid != null) {
      await registerDeviceWithBackend(authToken: auth, userId: uid);
    }
  }

  // ---- helpers ----
  static Future<void> _refreshAndStoreToken() async {
    final t = await FirebaseMessaging.instance.getToken();
    if (t == null || t.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', t);
    debugPrint('FCM token: $t');
  }

  static String _payloadFromData(Map<String, dynamic> data) {
    final orderId = data['order_id']?.toString() ?? '';
    return orderId.isNotEmpty ? 'order_id=$orderId' : '';
  }

  static void _openFromData(Map<String, dynamic> data) {
    final payload = _payloadFromData(data);
    _openFromPayload(payload);
  }

  static void _openFromPayload(String payload) {
    if (payload.isEmpty) {
      // e.g. open home or do nothing
      return;
    }
    // Example: always open "My Orders" page
    final ctx = navServiceKey.currentContext;
    if (ctx == null) return;
    Navigator.of(ctx).pushNamed('/orders'); // define a route or push your page
  }
}
