// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'home_screen.dart';
// import 'signup_screen.dart';
// import '../constants.dart'; // Make sure this contains your baseUrl

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _login() async {
//     final phone = _phoneController.text.trim();
//     final password = _passwordController.text.trim();

//     if (phone.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please enter all fields")));
//       return;
//     }

//     setState(() => _isLoading = true);

//     final url = Uri.parse('$baseUrl/users/login/');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({"phone": phone, "password": password}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', data['token']);
//         await prefs.setString('phone', phone);

//         if (!mounted) return;

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['error'] ?? 'Login failed')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Login error: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildLoginForm() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           'Fair Price Shop',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Serif',
//           ),
//         ),
//         const SizedBox(height: 20),
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: const InputDecoration(
//             hintText: '+91 Enter Mobile number',
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(30)),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           ),
//         ),
//         const SizedBox(height: 20),
//         TextField(
//           controller: _passwordController,
//           obscureText: true,
//           decoration: const InputDecoration(
//             hintText: 'Enter Password',
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(30)),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           ),
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _login,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//             backgroundColor: Colors.grey[700],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             elevation: 5,
//           ),
//           child: _isLoading
//               ? const CircularProgressIndicator(color: Colors.white)
//               : const Text('Log In', style: TextStyle(color: Colors.white)),
//         ),
//         const SizedBox(height: 10),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const SignupScreen()),
//             );
//           },
//           child: const Text(
//             "Register",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.black,
//               decoration: TextDecoration.underline,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           "By continuing, you agree to our Terms of services & Privacy policy",
//           style: TextStyle(fontSize: 10, color: Colors.black54),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return isLandscape
//                 ? Row(
//                     children: [
//                       Expanded(
//                         child: Image.asset(
//                           'assets/homepage.png',
//                           height: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           color: const Color(0xFFFFA64D),
//                           padding: const EdgeInsets.all(20),
//                           child: Center(
//                             child: SingleChildScrollView(
//                               child: _buildLoginForm(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 : Column(
//                     children: [
//                       SizedBox(
//                         height: size.height * 0.45,
//                         width: double.infinity,
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.only(
//                             bottomLeft: Radius.circular(25),
//                             bottomRight: Radius.circular(25),
//                           ),
//                           child: Image.asset(
//                             'assets/homepage.png',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           color: const Color(0xFFFFA64D),
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 20,
//                           ),
//                           child: SingleChildScrollView(
//                             child: _buildLoginForm(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//           },
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'home_screen.dart';
// import 'signup_screen.dart';
// import '../constants.dart'; // baseUrl
// import '../theme/palette.dart'; // ← use your palette colors

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _login() async {
//     final phone = _phoneController.text.trim();
//     final password = _passwordController.text.trim();

//     if (phone.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please enter all fields")));
//       return;
//     }

//     setState(() => _isLoading = true);

//     final url = Uri.parse('$baseUrl/users/login/');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({"phone": phone, "password": password}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', data['token']);
//         await prefs.setString('phone', phone);

//         if (!mounted) return;

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomePage()),
//         );
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['error'] ?? 'Login failed')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Login error: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ---------- UI helpers (colors + cosmetics only) ----------

//   InputDecoration _inputDeco({required String hint, IconData? prefix}) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(
//         fontFamily: 'Serif',
//         color: kTextPrimary.withOpacity(0.55),
//       ),
//       prefixIcon: prefix != null ? Icon(prefix, color: kPrimary) : null,
//       filled: true,
//       fillColor: kCard,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(28),
//         borderSide: BorderSide(color: kBorder),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(28),
//         borderSide: BorderSide(color: kBorder),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(28),
//         borderSide: BorderSide(color: kPrimary, width: 1.6),
//       ),
//     );
//   }

//   Widget _buildLoginForm() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Title
//         Text(
//           'Fair Price Shop',
//           style: TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.w800,
//             fontFamily: 'Serif',
//             color: kTextPrimary,
//             letterSpacing: 0.2,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: kPrimarySoft,
//             borderRadius: BorderRadius.circular(999),
//             border: Border.all(color: kBorder),
//           ),
//           child: Text(
//             'Welcome back',
//             style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700),
//           ),
//         ),

//         const SizedBox(height: 20),

//         // Phone
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           style: TextStyle(color: kTextPrimary),
//           decoration: _inputDeco(
//             hint: '+91 Enter Mobile number',
//             prefix: Icons.phone_android_outlined,
//           ),
//         ),

//         const SizedBox(height: 14),

//         // Password
//         TextField(
//           controller: _passwordController,
//           obscureText: true,
//           style: TextStyle(color: kTextPrimary),
//           decoration: _inputDeco(
//             hint: 'Enter Password',
//             prefix: Icons.lock_outline,
//           ),
//         ),

//         const SizedBox(height: 18),

//         // Login button
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: _isLoading ? null : _login,
//             style:
//                 ElevatedButton.styleFrom(
//                   backgroundColor: kPrimary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ).copyWith(
//                   overlayColor: MaterialStatePropertyAll(
//                     Colors.white.withOpacity(0.08),
//                   ),
//                 ),
//             child: _isLoading
//                 ? const SizedBox(
//                     height: 18,
//                     width: 18,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Text(
//                     'Log In',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//           ),
//         ),

//         const SizedBox(height: 10),

//         // Register link
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const SignupScreen()),
//             );
//           },
//           child: Text(
//             "Register",
//             style: TextStyle(
//               fontSize: 14,
//               color: kPrimary,
//               decoration: TextDecoration.underline,
//               decorationColor: kPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),

//         const SizedBox(height: 10),

//         // Terms
//         Text(
//           "By continuing, you agree to our Terms of services & Privacy policy",
//           style: TextStyle(fontSize: 11, color: kTextPrimary.withOpacity(0.6)),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     // Shared “card” that wraps the form (no logic change, just looks)
//     Widget formCard() {
//       return Center(
//         child: SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 520),
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.92),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: kBorder),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 18,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: _buildLoginForm(),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       // Full-screen palette gradient
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [kBgTop, kBgBottom],
//           ),
//         ),
//         child: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return isLandscape
//                   ? Row(
//                       children: [
//                         // Left image
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.only(
//                               topRight: Radius.circular(24),
//                               bottomRight: Radius.circular(24),
//                             ),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 Image.asset(
//                                   'assets/homepage.png',
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                 ),
//                                 // Subtle overlay for readability
//                                 Container(
//                                   color: Colors.black.withOpacity(0.15),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // Right form panel
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: formCard(),
//                           ),
//                         ),
//                       ],
//                     )
//                   : Column(
//                       children: [
//                         // Header image
//                         SizedBox(
//                           height: size.height * 0.42,
//                           width: double.infinity,
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.only(
//                               bottomLeft: Radius.circular(24),
//                               bottomRight: Radius.circular(24),
//                             ),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 Image.asset(
//                                   'assets/homepage.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                                 Container(
//                                   color: Colors.black.withOpacity(0.15),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // Form area
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 16,
//                             ),
//                             child: formCard(),
//                           ),
//                         ),
//                       ],
//                     );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';
import 'signup_screen.dart';
import '../constants.dart'; // baseUrl
import '../theme/palette.dart'; // ← use your palette colors

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter all fields")));
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('$baseUrl/users/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      // Try decode regardless, server often sends error JSON too
      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {
        // ignore decode errors; we'll fall back to status code handling
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        // Save token
        final token = (data['token'] ?? '').toString();
        await prefs.setString('token', token);

        // Save user fields if present
        if (data['user'] is Map<String, dynamic>) {
          final user = data['user'] as Map<String, dynamic>;

          // id
          final dynamic rawId = user['id'];
          final int userId = rawId is int
              ? rawId
              : int.tryParse('${rawId ?? 0}') ?? 0;
          await prefs.setInt('user_id', userId);

          // name/phone/address/gender
          await prefs.setString('name', (user['name'] ?? '').toString());
          await prefs.setString('phone', (user['phone'] ?? phone).toString());
          await prefs.setString('address', (user['address'] ?? '').toString());
          await prefs.setString('gender', (user['gender'] ?? '').toString());

          // flags/timestamps
          final isActive = (user['is_active'] ?? true) == true;
          await prefs.setBool('is_active', isActive);
          await prefs.setString(
            'last_login',
            (user['last_login'] ?? '').toString(),
          );

          // keep full JSON for future fields
          await prefs.setString('user_json', jsonEncode(user));
        } else {
          // At least keep the phone we logged in with
          await prefs.setString('phone', phone);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        if (!mounted) return;
        final msg = (data['error'] ?? data['detail'] ?? 'Login failed')
            .toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- UI helpers (colors + cosmetics only) ----------

  InputDecoration _inputDeco({required String hint, IconData? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Serif',
        color: kTextPrimary.withOpacity(0.55),
      ),
      prefixIcon: prefix != null ? Icon(prefix, color: kPrimary) : null,
      filled: true,
      fillColor: kCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: kPrimary, width: 1.6),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          'Fair Price Shop',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            fontFamily: 'Serif',
            color: kTextPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kPrimarySoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: kBorder),
          ),
          child: Text(
            'Welcome back',
            style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700),
          ),
        ),

        const SizedBox(height: 20),

        // Phone
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: kTextPrimary),
          decoration: _inputDeco(
            hint: '+91 Enter Mobile number',
            prefix: Icons.phone_android_outlined,
          ),
        ),

        const SizedBox(height: 14),

        // Password
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: TextStyle(color: kTextPrimary),
          decoration: _inputDeco(
            hint: 'Enter Password',
            prefix: Icons.lock_outline,
          ),
        ),

        const SizedBox(height: 18),

        // Login button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ).copyWith(
                  overlayColor: MaterialStatePropertyAll(
                    Colors.white.withOpacity(0.08),
                  ),
                ),
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Log In',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),

        const SizedBox(height: 10),

        // Register link
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
          child: Text(
            "Register",
            style: TextStyle(
              fontSize: 14,
              color: kPrimary,
              decoration: TextDecoration.underline,
              decorationColor: kPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 10),

        // Terms
        Text(
          "By continuing, you agree to our Terms of services & Privacy policy",
          style: TextStyle(fontSize: 11, color: kTextPrimary.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Shared “card” that wraps the form (no logic change, just looks)
    Widget formCard() {
      return Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildLoginForm(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      // Full-screen palette gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBgTop, kBgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return isLandscape
                  ? Row(
                      children: [
                        // Left image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/homepage.png',
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                // Subtle overlay for readability
                                Container(
                                  color: Colors.black.withOpacity(0.15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right form panel
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: formCard(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Header image
                        SizedBox(
                          height: size.height * 0.42,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/homepage.png',
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Form area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: formCard(),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
