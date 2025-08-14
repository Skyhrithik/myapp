// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// import 'providers/provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';

// import 'theme/palette.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await PaletteManager.initRandom();
//   runApp(
//     ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<bool> _isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     return token != null && token.trim().isNotEmpty;
//   }

//   static Future<void> logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('phone');

//     if (context.mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fair Price Shop',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: kPrimary,
//         scaffoldBackgroundColor: kBgBottom,
//         cardColor: kCard,
//         fontFamily: 'Serif',

//         appBarTheme: AppBarTheme(
//           backgroundColor: kBgTop,
//           foregroundColor: kTextPrimary,
//           elevation: 0,
//           iconTheme: IconThemeData(color: kTextPrimary),
//           titleTextStyle: TextStyle(
//             color: kTextPrimary,
//             fontFamily: 'Serif',
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),

//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: Colors.white,
//           selectedItemColor: kPrimary,
//           unselectedItemColor: kTextPrimary.withOpacity(0.6),
//           selectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           unselectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           showUnselectedLabels: true,
//           type: BottomNavigationBarType.fixed,
//         ),

//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           backgroundColor: kPrimary,
//           foregroundColor: Colors.white,
//         ),

//         progressIndicatorTheme: ProgressIndicatorThemeData(color: kPrimary),

//         snackBarTheme: SnackBarThemeData(
//           backgroundColor: kPrimary,
//           contentTextStyle: const TextStyle(color: Colors.white),
//           actionTextColor: Colors.white,
//           behavior: SnackBarBehavior.floating,
//         ),

//         dividerTheme: DividerThemeData(color: kBorder),

//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//       home: FutureBuilder<bool>(
//         future: _isLoggedIn(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           final loggedIn = snap.data == true;
//           return loggedIn ? const HomePage() : const LoginScreen();
//         },
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'providers/provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/my_orders_page.dart'; // for notification tap navigation
// import 'theme/palette.dart';

// // If you generated firebase_options.dart (recommended), import it:
// // import 'firebase_options.dart';

// // ========= Navigation key so we can navigate from notification callbacks ====
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// // ========================== Local Notifications =============================
// const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
//   'fcm_default_channel', // id
//   'General Notifications', // title
//   description: 'Default channel for order updates and alerts',
//   importance: Importance.high,
// );

// final FlutterLocalNotificationsPlugin _localNotifs =
//     FlutterLocalNotificationsPlugin();

// // =================== Background message handler (top-level) =================
// @pragma('vm:entry-point') // Needed for background isolate
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Make sure Firebase is initialized in background isolate
//   try {
//     await Firebase.initializeApp(
//       // options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (_) {}
//   // Usually you don't show a local notif here, because FCM will display the
//   // system notification if the message has a "notification" payload.
//   // If you only send "data" messages, consider showing a local notif here.
// }

// // ================================ PushService ===============================
// class PushService {
//   static Future<void> init() async {
//     // 1) Firebase
//     await Firebase.initializeApp(
//       // options: DefaultFirebaseOptions.currentPlatform,
//     );

//     // 2) Ask permission (Android 13+ / iOS)
//     await FirebaseMessaging.instance.requestPermission();

//     // 3) Create Android channel + init local notifications
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iOSInit = DarwinInitializationSettings();
//     await _localNotifs.initialize(
//       const InitializationSettings(android: androidInit, iOS: iOSInit),
//       onDidReceiveNotificationResponse: (resp) {
//         // Handles taps when app is foreground
//         _handleOpenFromLocalNotification(resp.payload);
//       },
//     );
//     await _localNotifs
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(_androidChannel);

//     // 4) Register background handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // 5) Foreground messages → show a local notification
//     FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
//       final notif = m.notification;
//       final title = notif?.title ?? 'Fair Price Shop';
//       final body = notif?.body ?? 'You have a new update';
//       final payload = _payloadFromMessage(m);

//       final details = NotificationDetails(
//         android: AndroidNotificationDetails(
//           _androidChannel.id,
//           _androidChannel.name,
//           channelDescription: _androidChannel.description,
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/ic_launcher',
//         ),
//         iOS: const DarwinNotificationDetails(),
//       );

//       await _localNotifs.show(
//         DateTime.now().millisecondsSinceEpoch ~/ 1000,
//         title,
//         body,
//         details,
//         payload: payload,
//       );
//     });

//     // 6) User tapped notification while app in background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
//       _handleOpenFromRemoteMessage(m);
//     });

//     // 7) App launched from terminated by tapping a notification
//     final initial = await FirebaseMessaging.instance.getInitialMessage();
//     if (initial != null) {
//       // Delay a frame so navigatorKey is ready
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _handleOpenFromRemoteMessage(initial);
//       });
//     }

//     // 8) Get FCM token + persist + send to backend
//     await _refreshAndPersistFcmToken();
//     // If token changes later:
//     FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
//       await _persistFcmToken(t);
//       unawaited(_sendTokenToBackend(t)); // fire and forget
//     });
//   }

//   static String _payloadFromMessage(RemoteMessage m) {
//     // Keep it simple (you can encode JSON if you need more info)
//     final orderId = m.data['order_id']?.toString() ?? '';
//     return orderId.isEmpty ? '' : 'order_id=$orderId';
//   }

//   static void _handleOpenFromLocalNotification(String? payload) {
//     if (payload == null || payload.isEmpty) return;
//     final parts = Uri.splitQueryString(payload);
//     final orderId = parts['order_id'];
//     _navigateToOrders(orderId: orderId);
//   }

//   static void _handleOpenFromRemoteMessage(RemoteMessage m) {
//     final orderId = m.data['order_id']?.toString();
//     _navigateToOrders(orderId: orderId);
//   }

//   static void _navigateToOrders({String? orderId}) {
//     final ctx = navigatorKey.currentContext;
//     if (ctx == null) return;
//     // Open Orders page directly. (You could also push HomePage and switch tab.)
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (_) => const MyOrdersPage()),
//     );
//     // If you want to scroll/open a specific order, pass orderId via args and
//     // implement handling inside MyOrdersPage.
//   }

//   static Future<void> _refreshAndPersistFcmToken() async {
//     final token = await FirebaseMessaging.instance.getToken();
//     if (token == null || token.isEmpty) return;
//     await _persistFcmToken(token);
//     unawaited(_sendTokenToBackend(token));
//   }

//   static Future<void> _persistFcmToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('fcm_token', token);
//   }

//   /// Post your FCM token to Django (tie to the logged-in user).
//   /// Adjust the URL/path to match your backend (e.g. /me/devices/ or /me/fcm-token/).
//   static Future<void> _sendTokenToBackend(String token) async {
//     // Example—use your own HTTP client & AppConfig
//     // import 'package:http/http.dart' as http;
//     // import 'config/config.dart';
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final auth = prefs.getString('token');
//       if (auth == null || auth.isEmpty) return;

//       // final url = Uri.parse('${AppConfig.baseUrl}/me/fcm-token/');
//       // await http.post(
//       //   url,
//       //   headers: {
//       //     'Content-Type': 'application/json',
//       //     'Authorization': 'Token $auth',
//       //   },
//       //   body: jsonEncode({'token': token, 'platform': 'android'}),
//       // );
//     } catch (_) {
//       // Swallow errors silently to avoid blocking app startup
//     }
//   }
// }

// // ================================ main() ====================================
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Keep your palette logic
//   await PaletteManager.initRandom();

//   // Initialize push (Firebase + FCM + local notifs)
//   await PushService.init();

//   runApp(
//     ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   /// Checks if a non-empty token exists in SharedPreferences.
//   Future<bool> _isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     return token != null && token.trim().isNotEmpty;
//   }

//   /// Static helper for logging out from anywhere in the app.
//   static Future<void> logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('phone');
//     // Keep FCM token; you can also DELETE it server-side if desired.

//     if (context.mounted) {
//       navigatorKey.currentState?.pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Fair Price Shop',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: kPrimary,
//         scaffoldBackgroundColor: kBgBottom,
//         cardColor: kCard,
//         fontFamily: 'Serif',
//         appBarTheme: AppBarTheme(
//           backgroundColor: kBgTop,
//           foregroundColor: kTextPrimary,
//           elevation: 0,
//           iconTheme: IconThemeData(color: kTextPrimary),
//           titleTextStyle: TextStyle(
//             color: kTextPrimary,
//             fontFamily: 'Serif',
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: Colors.white,
//           selectedItemColor: kPrimary,
//           unselectedItemColor: kTextPrimary.withOpacity(0.6),
//           selectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           unselectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           showUnselectedLabels: true,
//           type: BottomNavigationBarType.fixed,
//         ),
//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           backgroundColor: kPrimary,
//           foregroundColor: Colors.white,
//         ),
//         progressIndicatorTheme: ProgressIndicatorThemeData(color: kPrimary),
//         snackBarTheme: SnackBarThemeData(
//           backgroundColor: kPrimary,
//           contentTextStyle: const TextStyle(color: Colors.white),
//           actionTextColor: Colors.white,
//           behavior: SnackBarBehavior.floating,
//         ),
//         dividerTheme: DividerThemeData(color: kBorder),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//       home: FutureBuilder<bool>(
//         future: _isLoggedIn(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           final loggedIn = snap.data == true;
//           return loggedIn ? const HomePage() : const LoginScreen();
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'providers/provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';
// import 'theme/palette.dart';

// import 'services/push_service.dart'; // <-- add
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize push (Firebase + FCM + local notifs)
//   await PushService.init();

//   runApp(
//     ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<bool> _isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     return token != null && token.trim().isNotEmpty;
//   }

//   static Future<void> logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('phone');
//     await prefs.remove('user_id');
//     if (context.mounted) {
//       PushService.unregisterDevice(authToken: ''); // optional if you keep token
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navServiceKey, // <-- enables navigation from notifications
//       title: 'Fair Price Shop',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: kPrimary,
//         scaffoldBackgroundColor: kBgBottom,
//         cardColor: kCard,
//         fontFamily: 'Serif',
//         appBarTheme: AppBarTheme(
//           backgroundColor: kBgTop,
//           foregroundColor: kTextPrimary,
//           elevation: 0,
//           iconTheme: IconThemeData(color: kTextPrimary),
//           titleTextStyle: TextStyle(
//             color: kTextPrimary,
//             fontFamily: 'Serif',
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: Colors.white,
//           selectedItemColor: kPrimary,
//           unselectedItemColor: kTextPrimary.withOpacity(0.6),
//           selectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           unselectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           showUnselectedLabels: true,
//           type: BottomNavigationBarType.fixed,
//         ),
//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           backgroundColor: kPrimary,
//           foregroundColor: Colors.white,
//         ),
//         progressIndicatorTheme: ProgressIndicatorThemeData(color: kPrimary),
//         snackBarTheme: SnackBarThemeData(
//           backgroundColor: kPrimary,
//           contentTextStyle: const TextStyle(color: Colors.white),
//           actionTextColor: Colors.white,
//           behavior: SnackBarBehavior.floating,
//         ),
//         dividerTheme: DividerThemeData(color: kBorder),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//       home: FutureBuilder<bool>(
//         future: _isLoggedIn(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           final loggedIn = snap.data == true;
//           return loggedIn ? const HomePage() : const LoginScreen();
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'providers/provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';
// import 'theme/palette.dart';

// import 'services/push_service.dart'; // <-- notifications
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 1) Firebase first
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // 2) Initialize your runtime palette (this fixes LateInitializationError)
//   await PaletteManager.initRandom();

//   // 3) Init push (FCM + local notifications)
//   await PushService.init();

//   // 4) Start app
//   runApp(
//     ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<bool> _isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     return token != null && token.trim().isNotEmpty;
//   }

//   static Future<void> logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('phone');
//     await prefs.remove('user_id');
//     if (context.mounted) {
//       PushService.unregisterDevice(authToken: ''); // optional
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navServiceKey, // from PushService
//       title: 'Fair Price Shop',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: kPrimary,
//         scaffoldBackgroundColor: kBgBottom,
//         cardColor: kCard,
//         fontFamily: 'Serif',
//         appBarTheme: AppBarTheme(
//           backgroundColor: kBgTop,
//           foregroundColor: kTextPrimary,
//           elevation: 0,
//           iconTheme: IconThemeData(color: kTextPrimary),
//           titleTextStyle: TextStyle(
//             color: kTextPrimary,
//             fontFamily: 'Serif',
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: Colors.white,
//           selectedItemColor: kPrimary,
//           unselectedItemColor: kTextPrimary.withOpacity(0.6),
//           selectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           unselectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
//           showUnselectedLabels: true,
//           type: BottomNavigationBarType.fixed,
//         ),
//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           backgroundColor: kPrimary,
//           foregroundColor: Colors.white,
//         ),
//         progressIndicatorTheme: ProgressIndicatorThemeData(color: kPrimary),
//         snackBarTheme: SnackBarThemeData(
//           backgroundColor: kPrimary,
//           contentTextStyle: const TextStyle(color: Colors.white),
//           actionTextColor: Colors.white,
//           behavior: SnackBarBehavior.floating,
//         ),
//         dividerTheme: DividerThemeData(color: kBorder),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 16,
//           ),
//         ),
//       ),
//       home: FutureBuilder<bool>(
//         future: _isLoggedIn(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           final loggedIn = snap.data == true;
//           return loggedIn ? const HomePage() : const LoginScreen();
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/palette.dart'; // <- keep palette

// Push + Firebase
import 'services/push_service.dart'; // exposes navServiceKey + init()
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generated by FlutterFire

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Initialize your runtime palette (do not remove)
  await PaletteManager.initRandom();

  // 3) Init push (FCM + local notifications)
  await PushService.init();

  // 4) Start app
  runApp(
    ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('phone');
    await prefs.remove('user_id');

    if (context.mounted) {
      // Optional: PushService.unregisterDevice(authToken: '');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navServiceKey, // <- from PushService for notif navigation
      title: 'Fair Price Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimary, // <- palette color
        scaffoldBackgroundColor: kBgBottom, // <- palette color
        cardColor: kCard, // <- palette color
        fontFamily: 'Serif',

        appBarTheme: AppBarTheme(
          backgroundColor: kBgTop, // <- palette color
          foregroundColor: kTextPrimary, // <- palette color
          elevation: 0,
          iconTheme: IconThemeData(color: kTextPrimary),
          titleTextStyle: TextStyle(
            color: kTextPrimary,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kPrimary,
          unselectedItemColor: kTextPrimary.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Serif'),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
        ),

        progressIndicatorTheme: ProgressIndicatorThemeData(color: kPrimary),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: kPrimary,
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),

        dividerTheme: DividerThemeData(color: kBorder),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final loggedIn = snap.data == true;
          return loggedIn ? const HomePage() : const LoginScreen();
        },
      ),
    );
  }
}
