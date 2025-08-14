// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// import 'providers/provider.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';

// import 'theme/palette.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
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
//       title: 'Fair Price Shop', // Or use 'fps'
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: kPrimary, // ← was Colors.orange
//         scaffoldBackgroundColor: kBgBottom, // ← new: page bg from palette
//         cardColor: kCard, // ← new: card bg from palette
//         fontFamily: 'Serif',
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'providers/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

import 'theme/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pick (and persist) a random soft palette once.
  await PaletteManager.initRandom();
  runApp(
    ChangeNotifierProvider(create: (_) => CartProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Checks if a non-empty token exists in SharedPreferences.
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.trim().isNotEmpty;
  }

  /// Static helper for logging out from anywhere in the app.
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('phone');

    if (context.mounted) {
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
      title: 'Fair Price Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Seed the scheme from the runtime primary color.
        colorSchemeSeed: kPrimary,
        scaffoldBackgroundColor: kBgBottom,
        cardColor: kCard,
        fontFamily: 'Serif',

        appBarTheme: AppBarTheme(
          backgroundColor: kBgTop,
          foregroundColor: kTextPrimary,
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
