// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:logger/logger.dart';
// // import '../constants.dart';
// // import '../config/config.dart';

// // String? _csrfToken;
// // String? _cookie;
// // final Logger _logger = Logger();

// // class SignupScreen extends StatefulWidget {
// //   const SignupScreen({super.key});

// //   @override
// //   State<SignupScreen> createState() => _SignupScreenState();
// // }

// // class _SignupScreenState extends State<SignupScreen> {
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _phoneController = TextEditingController();
// //   final TextEditingController _confirmPhoneController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _confirmPasswordController =
// //       TextEditingController();
// //   final TextEditingController _addressController = TextEditingController();
// //   String? _selectedGender;
// //   bool _obscurePassword = true;
// //   bool _obscureConfirmPassword = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchCSRFToken();
// //   }

// //   bool _isLoading = false;

// //   Future<void> _fetchCSRFToken() async {
// //     try {
// //       final response = await http.get(Uri.parse('$baseUrl/csrf/'));

// //       final rawCookie = response.headers['set-cookie'];
// //       if (rawCookie != null) {
// //         _cookie = rawCookie
// //             .split(';')
// //             .firstWhere((e) => e.contains('csrftoken='));
// //         _csrfToken = _cookie?.split('=')[1];
// //         _logger.i('CSRF Token Fetched: $_csrfToken');
// //       }
// //     } catch (e) {
// //       _logger.e('CSRF fetch error: $e');
// //     }
// //   }

// //   Future<void> _register() async {
// //     final name = _nameController.text.trim();
// //     final phone = _phoneController.text.trim();
// //     final confirmPhone = _confirmPhoneController.text.trim();
// //     final password = _passwordController.text.trim();
// //     final confirmPassword = _confirmPasswordController.text.trim();
// //     final address = _addressController.text.trim();
// //     final gender = _selectedGender;

// //     if (name.isEmpty ||
// //         phone.isEmpty ||
// //         confirmPhone.isEmpty ||
// //         password.isEmpty ||
// //         confirmPassword.isEmpty ||
// //         address.isEmpty ||
// //         gender == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please fill in all fields.')),
// //       );
// //       return;
// //     }

// //     if (phone != confirmPhone) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Mobile numbers do not match.')),
// //       );
// //       return;
// //     }

// //     if (password != confirmPassword) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
// //       return;
// //     }

// //     setState(() => _isLoading = true);

// //     try {
// //       final response = await http.post(
// //         Uri.parse('${AppConfig.baseUrl}/users/register/'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Referer': 'https://fps-dayalbagh-backend.vercel.app/api/csrf/',
// //           if (_csrfToken != null) 'X-CSRFToken': _csrfToken!,
// //           if (_cookie != null) 'Cookie': _cookie!,
// //         },
// //         body: jsonEncode({
// //           "name": name,
// //           "phone": phone,
// //           "confirm_phone": confirmPhone,
// //           "password": password,
// //           "confirm_password": confirmPassword,
// //           "gender": gender,
// //           "address": address,
// //         }),
// //       );

// //       setState(() => _isLoading = false);

// //       if (!mounted) return;

// //       if (response.statusCode == 201 || response.statusCode == 200) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Registered Successfully!')),
// //         );
// //         Navigator.pop(context);
// //       } else {
// //         final body = jsonDecode(response.body);
// //         final error = body['detail'] ?? 'Registration failed';
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text(error.toString())));
// //       }
// //     } catch (err) {
// //       setState(() => _isLoading = false);
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('Error: $err')));
// //     }
// //   }

// //   Widget buildShadowedInput(
// //     TextEditingController controller,
// //     String hint, {
// //     bool obscure = false,
// //     int maxLines = 1,
// //     TextInputType keyboardType = TextInputType.text,
// //     VoidCallback? toggleVisibility,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black26,
// //               blurRadius: 6,
// //               offset: Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: TextField(
// //           controller: controller,
// //           obscureText: obscure,
// //           maxLines: maxLines,
// //           keyboardType: keyboardType,
// //           style: const TextStyle(fontSize: 16),
// //           decoration: InputDecoration(
// //             hintText: hint,
// //             hintStyle: const TextStyle(fontFamily: 'Serif'),
// //             contentPadding: const EdgeInsets.symmetric(
// //               horizontal: 20,
// //               vertical: 16,
// //             ),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(30),
// //               borderSide: BorderSide.none,
// //             ),
// //             suffixIcon: toggleVisibility != null
// //                 ? IconButton(
// //                     icon: Icon(
// //                       obscure ? Icons.visibility_off : Icons.visibility,
// //                     ),
// //                     onPressed: toggleVisibility,
// //                   )
// //                 : null,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildGenderDropdown() {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           boxShadow: const [
// //             BoxShadow(
// //               color: Colors.black26,
// //               blurRadius: 6,
// //               offset: Offset(0, 4),
// //             ),
// //           ],
// //           borderRadius: BorderRadius.circular(30),
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(30),
// //           child: Container(
// //             color: Colors.white,
// //             padding: const EdgeInsets.symmetric(horizontal: 20),
// //             child: DropdownButtonFormField<String>(
// //               decoration: const InputDecoration(
// //                 border: InputBorder.none,
// //                 contentPadding: EdgeInsets.symmetric(vertical: 16),
// //                 hintText: 'Select Gender',
// //                 hintStyle: TextStyle(fontFamily: 'Serif'),
// //               ),
// //               value: _selectedGender,
// //               items: ['Male', 'Female', 'Others']
// //                   .map(
// //                     (gender) =>
// //                         DropdownMenuItem(value: gender, child: Text(gender)),
// //                   )
// //                   .toList(),
// //               onChanged: (value) => setState(() => _selectedGender = value),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [Color(0xFFFF7F00), Color(0xFFFFA64D)],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(
// //                         Icons.arrow_back_ios,
// //                         color: Colors.black,
// //                       ),
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               if (_isLoading)
// //                 Expanded(
// //                   child: Container(
// //                     color: Colors.black.withAlpha((0.3 * 255).toInt()),
// //                     child: const Center(child: CircularProgressIndicator()),
// //                   ),
// //                 ),
// //               if (!_isLoading)
// //                 Expanded(
// //                   child: SingleChildScrollView(
// //                     padding: const EdgeInsets.symmetric(horizontal: 30),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         const Text(
// //                           'FPS DAVALBACH',
// //                           style: TextStyle(
// //                             fontSize: 28,
// //                             fontWeight: FontWeight.bold,
// //                             fontFamily: 'Serif',
// //                           ),
// //                         ),
// //                         const SizedBox(height: 10),
// //                         const Text(
// //                           'Sign Up',
// //                           style: TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.w700,
// //                             fontFamily: 'Serif',
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         const Text(
// //                           'Create your account',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.w500,
// //                             fontFamily: 'Serif',
// //                           ),
// //                         ),
// //                         const SizedBox(height: 24),
// //                         buildShadowedInput(_nameController, 'Enter Your Name'),
// //                         buildGenderDropdown(),
// //                         buildShadowedInput(
// //                           _phoneController,
// //                           'Enter Mobile number',
// //                           keyboardType: TextInputType.phone,
// //                         ),
// //                         buildShadowedInput(
// //                           _confirmPhoneController,
// //                           'Confirm Mobile number',
// //                           keyboardType: TextInputType.phone,
// //                         ),
// //                         buildShadowedInput(
// //                           _passwordController,
// //                           'Create Password',
// //                           obscure: _obscurePassword,
// //                           toggleVisibility: () => setState(
// //                             () => _obscurePassword = !_obscurePassword,
// //                           ),
// //                         ),
// //                         buildShadowedInput(
// //                           _confirmPasswordController,
// //                           'Confirm Password',
// //                           obscure: _obscureConfirmPassword,
// //                           toggleVisibility: () => setState(
// //                             () => _obscureConfirmPassword =
// //                                 !_obscureConfirmPassword,
// //                           ),
// //                         ),
// //                         buildShadowedInput(
// //                           _addressController,
// //                           'Enter Your Address',
// //                           maxLines: 3,
// //                         ),
// //                         const SizedBox(height: 20),
// //                         Container(
// //                           decoration: BoxDecoration(
// //                             boxShadow: const [
// //                               BoxShadow(
// //                                 color: Colors.black26,
// //                                 blurRadius: 8,
// //                                 offset: Offset(0, 4),
// //                               ),
// //                             ],
// //                             borderRadius: BorderRadius.circular(30),
// //                           ),
// //                           child: ElevatedButton(
// //                             onPressed: _register,
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: Colors.grey[800],
// //                               padding: const EdgeInsets.symmetric(
// //                                 horizontal: 60,
// //                                 vertical: 16,
// //                               ),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(30),
// //                               ),
// //                             ),
// //                             child: const Text(
// //                               'Register',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontFamily: 'Serif',
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 30),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:logger/logger.dart';
// // import '../constants.dart';
// // import '../config/config.dart';
// // import '../theme/palette.dart'; // ← palette import

// // String? _csrfToken;
// // String? _cookie;
// // final Logger _logger = Logger();

// // class SignupScreen extends StatefulWidget {
// //   const SignupScreen({super.key});

// //   @override
// //   State<SignupScreen> createState() => _SignupScreenState();
// // }

// // class _SignupScreenState extends State<SignupScreen> {
// //   final TextEditingController _nameController = TextEditingController();
// //   final TextEditingController _phoneController = TextEditingController();
// //   final TextEditingController _confirmPhoneController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _confirmPasswordController =
// //       TextEditingController();
// //   final TextEditingController _addressController = TextEditingController();
// //   String? _selectedGender;
// //   bool _obscurePassword = true;
// //   bool _obscureConfirmPassword = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchCSRFToken();
// //   }

// //   bool _isLoading = false;

// //   Future<void> _fetchCSRFToken() async {
// //     try {
// //       final response = await http.get(Uri.parse('$baseUrl/csrf/'));

// //       final rawCookie = response.headers['set-cookie'];
// //       if (rawCookie != null) {
// //         _cookie = rawCookie
// //             .split(';')
// //             .firstWhere((e) => e.contains('csrftoken='));
// //         _csrfToken = _cookie?.split('=')[1];
// //         _logger.i('CSRF Token Fetched: $_csrfToken');
// //       }
// //     } catch (e) {
// //       _logger.e('CSRF fetch error: $e');
// //     }
// //   }

// //   Future<void> _register() async {
// //     final name = _nameController.text.trim();
// //     final phone = _phoneController.text.trim();
// //     final confirmPhone = _confirmPhoneController.text.trim();
// //     final password = _passwordController.text.trim();
// //     final confirmPassword = _confirmPasswordController.text.trim();
// //     final address = _addressController.text.trim();
// //     final gender = _selectedGender;

// //     if (name.isEmpty ||
// //         phone.isEmpty ||
// //         confirmPhone.isEmpty ||
// //         password.isEmpty ||
// //         confirmPassword.isEmpty ||
// //         address.isEmpty ||
// //         gender == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please fill in all fields.')),
// //       );
// //       return;
// //     }

// //     if (phone != confirmPhone) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Mobile numbers do not match.')),
// //       );
// //       return;
// //     }

// //     if (password != confirmPassword) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
// //       return;
// //     }

// //     setState(() => _isLoading = true);

// //     try {
// //       final response = await http.post(
// //         Uri.parse('${AppConfig.baseUrl}/users/register/'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Referer': 'https://fps-dayalbagh-backend.vercel.app/api/csrf/',
// //           if (_csrfToken != null) 'X-CSRFToken': _csrfToken!,
// //           if (_cookie != null) 'Cookie': _cookie!,
// //         },
// //         body: jsonEncode({
// //           "name": name,
// //           "phone": phone,
// //           "confirm_phone": confirmPhone,
// //           "password": password,
// //           "confirm_password": confirmPassword,
// //           "gender": gender,
// //           "address": address,
// //         }),
// //       );

// //       setState(() => _isLoading = false);

// //       if (!mounted) return;

// //       if (response.statusCode == 201 || response.statusCode == 200) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Registered Successfully!')),
// //         );
// //         Navigator.pop(context);
// //       } else {
// //         final body = jsonDecode(response.body);
// //         final error = body['detail'] ?? 'Registration failed';
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text(error.toString())));
// //       }
// //     } catch (err) {
// //       setState(() => _isLoading = false);
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('Error: $err')));
// //     }
// //   }

// //   Widget buildShadowedInput(
// //     TextEditingController controller,
// //     String hint, {
// //     bool obscure = false,
// //     int maxLines = 1,
// //     TextInputType keyboardType = TextInputType.text,
// //     VoidCallback? toggleVisibility,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black26,
// //               blurRadius: 6,
// //               offset: Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: TextField(
// //           controller: controller,
// //           obscureText: obscure,
// //           maxLines: maxLines,
// //           keyboardType: keyboardType,
// //           style: const TextStyle(fontSize: 16, color: kTextPrimary),
// //           decoration: InputDecoration(
// //             hintText: hint,
// //             hintStyle: TextStyle(
// //               fontFamily: 'Serif',
// //               color: kTextPrimary.withOpacity(0.6),
// //             ),
// //             contentPadding: const EdgeInsets.symmetric(
// //               horizontal: 20,
// //               vertical: 16,
// //             ),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(30),
// //               borderSide: BorderSide.none,
// //             ),
// //             suffixIcon: toggleVisibility != null
// //                 ? IconButton(
// //                     icon: Icon(
// //                       obscure ? Icons.visibility_off : Icons.visibility,
// //                       color: kPrimary, // ← palette color
// //                     ),
// //                     onPressed: toggleVisibility,
// //                   )
// //                 : null,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildGenderDropdown() {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Container(
// //         decoration: const BoxDecoration(
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black26,
// //               blurRadius: 6,
// //               offset: Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(30),
// //           child: Container(
// //             color: Colors.white,
// //             padding: const EdgeInsets.symmetric(horizontal: 20),
// //             child: DropdownButtonFormField<String>(
// //               decoration: InputDecoration(
// //                 border: InputBorder.none,
// //                 contentPadding: const EdgeInsets.symmetric(vertical: 16),
// //                 hintText: 'Select Gender',
// //                 hintStyle: TextStyle(
// //                   fontFamily: 'Serif',
// //                   color: kTextPrimary.withOpacity(0.6),
// //                 ),
// //               ),
// //               value: _selectedGender,
// //               iconEnabledColor: kPrimary,
// //               dropdownColor: Colors.white,
// //               items: ['Male', 'Female', 'Others']
// //                   .map(
// //                     (gender) => DropdownMenuItem(
// //                       value: gender,
// //                       child: Text(
// //                         gender,
// //                         style: const TextStyle(color: kTextPrimary),
// //                       ),
// //                     ),
// //                   )
// //                   .toList(),
// //               onChanged: (value) => setState(() => _selectedGender = value),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           // ← palette gradient
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [kBgTop, kBgBottom],
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: Column(
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                 child: Row(
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(
// //                         Icons.arrow_back_ios,
// //                         color: kTextPrimary,
// //                       ),
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               if (_isLoading)
// //                 Expanded(
// //                   child: Container(
// //                     color: Colors.black.withAlpha((0.3 * 255).toInt()),
// //                     child: const Center(
// //                       child: CircularProgressIndicator(
// //                         valueColor: AlwaysStoppedAnimation<Color>(
// //                           kPrimary,
// //                         ), // ← palette
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               if (!_isLoading)
// //                 Expanded(
// //                   child: SingleChildScrollView(
// //                     padding: const EdgeInsets.symmetric(horizontal: 30),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         const Text(
// //                           'FPS DAVALBACH',
// //                           style: TextStyle(
// //                             fontSize: 28,
// //                             fontWeight: FontWeight.bold,
// //                             fontFamily: 'Serif',
// //                             color: kTextPrimary, // ← palette
// //                           ),
// //                         ),
// //                         const SizedBox(height: 10),
// //                         const Text(
// //                           'Sign Up',
// //                           style: TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.w700,
// //                             fontFamily: 'Serif',
// //                             color: kTextPrimary, // ← palette
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           'Create your account',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.w500,
// //                             fontFamily: 'Serif',
// //                             color: kTextPrimary.withOpacity(0.8), // ← palette
// //                           ),
// //                         ),
// //                         const SizedBox(height: 24),
// //                         buildShadowedInput(_nameController, 'Enter Your Name'),
// //                         buildGenderDropdown(),
// //                         buildShadowedInput(
// //                           _phoneController,
// //                           'Enter Mobile number',
// //                           keyboardType: TextInputType.phone,
// //                         ),
// //                         buildShadowedInput(
// //                           _confirmPhoneController,
// //                           'Confirm Mobile number',
// //                           keyboardType: TextInputType.phone,
// //                         ),
// //                         buildShadowedInput(
// //                           _passwordController,
// //                           'Create Password',
// //                           obscure: _obscurePassword,
// //                           toggleVisibility: () => setState(
// //                             () => _obscurePassword = !_obscurePassword,
// //                           ),
// //                         ),
// //                         buildShadowedInput(
// //                           _confirmPasswordController,
// //                           'Confirm Password',
// //                           obscure: _obscureConfirmPassword,
// //                           toggleVisibility: () => setState(
// //                             () => _obscureConfirmPassword =
// //                                 !_obscureConfirmPassword,
// //                           ),
// //                         ),
// //                         buildShadowedInput(
// //                           _addressController,
// //                           'Enter Your Address',
// //                           maxLines: 3,
// //                         ),
// //                         const SizedBox(height: 20),
// //                         Container(
// //                           decoration: const BoxDecoration(
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Colors.black26,
// //                                 blurRadius: 8,
// //                                 offset: Offset(0, 4),
// //                               ),
// //                             ],
// //                           ),
// //                           child: ElevatedButton(
// //                             onPressed: _register,
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: kPrimary, // ← palette
// //                               padding: const EdgeInsets.symmetric(
// //                                 horizontal: 60,
// //                                 vertical: 16,
// //                               ),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(30),
// //                               ),
// //                             ),
// //                             child: const Text(
// //                               'Register',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontFamily: 'Serif',
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 30),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:logger/logger.dart';
// import '../constants.dart';
// import '../config/config.dart';
// import '../theme/palette.dart'; // ← palette import

// String? _csrfToken;
// String? _cookie;
// final Logger _logger = Logger();

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _confirmPhoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   String? _selectedGender;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCSRFToken();
//   }

//   bool _isLoading = false;

//   Future<void> _fetchCSRFToken() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/csrf/'));

//       final rawCookie = response.headers['set-cookie'];
//       if (rawCookie != null) {
//         _cookie = rawCookie
//             .split(';')
//             .firstWhere((e) => e.contains('csrftoken='));
//         _csrfToken = _cookie?.split('=')[1];
//         _logger.i('CSRF Token Fetched: $_csrfToken');
//       }
//     } catch (e) {
//       _logger.e('CSRF fetch error: $e');
//     }
//   }

//   Future<void> _register() async {
//     final name = _nameController.text.trim();
//     final phone = _phoneController.text.trim();
//     final confirmPhone = _confirmPhoneController.text.trim();
//     final password = _passwordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();
//     final address = _addressController.text.trim();
//     final gender = _selectedGender;

//     if (name.isEmpty ||
//         phone.isEmpty ||
//         confirmPhone.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty ||
//         address.isEmpty ||
//         gender == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields.')),
//       );
//       return;
//     }

//     if (phone != confirmPhone) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Mobile numbers do not match.')),
//       );
//       return;
//     }

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/users/register/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Referer': 'https://fps-dayalbagh-backend.vercel.app/api/csrf/',
//           if (_csrfToken != null) 'X-CSRFToken': _csrfToken!,
//           if (_cookie != null) 'Cookie': _cookie!,
//         },
//         body: jsonEncode({
//           "name": name,
//           "phone": phone,
//           "confirm_phone": confirmPhone,
//           "password": password,
//           "confirm_password": confirmPassword,
//           "gender": gender,
//           "address": address,
//         }),
//       );

//       setState(() => _isLoading = false);

//       if (!mounted) return;

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Registered Successfully!')),
//         );
//         Navigator.pop(context);
//       } else {
//         final body = jsonDecode(response.body);
//         final error = body['detail'] ?? 'Registration failed';
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(error.toString())));
//       }
//     } catch (err) {
//       setState(() => _isLoading = false);
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $err')));
//     }
//   }

//   Widget buildShadowedInput(
//     TextEditingController controller,
//     String hint, {
//     bool obscure = false,
//     int maxLines = 1,
//     TextInputType keyboardType = TextInputType.text,
//     VoidCallback? toggleVisibility,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Container(
//         decoration: const BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: TextField(
//           controller: controller,
//           obscureText: obscure,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           style: TextStyle(fontSize: 16, color: kTextPrimary),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               fontFamily: 'Serif',
//               color: kTextPrimary.withOpacity(0.6),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(30),
//               borderSide: BorderSide.none,
//             ),
//             suffixIcon: toggleVisibility != null
//                 ? IconButton(
//                     icon: Icon(
//                       obscure ? Icons.visibility_off : Icons.visibility,
//                       color: kPrimary, // ← palette color
//                     ),
//                     onPressed: toggleVisibility,
//                   )
//                 : null,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildGenderDropdown() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Container(
//         decoration: const BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 16),
//                 hintText: 'Select Gender',
//                 hintStyle: TextStyle(
//                   fontFamily: 'Serif',
//                   color: kTextPrimary.withOpacity(0.6),
//                 ),
//               ),
//               value: _selectedGender,
//               iconEnabledColor: kPrimary,
//               dropdownColor: Colors.white,
//               items: ['Male', 'Female', 'Others']
//                   .map(
//                     (gender) => DropdownMenuItem(
//                       value: gender,
//                       child: Text(
//                         gender,
//                         style: TextStyle(color: kTextPrimary),
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) => setState(() => _selectedGender = value),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           // ← palette gradient
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [kBgTop, kBgBottom],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.arrow_back_ios, color: kTextPrimary),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               if (_isLoading)
//                 Expanded(
//                   child: Container(
//                     color: Colors.black.withAlpha((0.3 * 255).toInt()),
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
//                       ),
//                     ),
//                   ),
//                 ),
//               if (!_isLoading)
//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 30),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           'FPS DAVALBACH',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Serif',
//                             color: kTextPrimary, // ← palette
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           'Sign Up',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w700,
//                             fontFamily: 'Serif',
//                             color: kTextPrimary, // ← palette
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Create your account',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             fontFamily: 'Serif',
//                             color: kTextPrimary.withOpacity(0.8), // ← palette
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         buildShadowedInput(_nameController, 'Enter Your Name'),
//                         buildGenderDropdown(),
//                         buildShadowedInput(
//                           _phoneController,
//                           'Enter Mobile number',
//                           keyboardType: TextInputType.phone,
//                         ),
//                         buildShadowedInput(
//                           _confirmPhoneController,
//                           'Confirm Mobile number',
//                           keyboardType: TextInputType.phone,
//                         ),
//                         buildShadowedInput(
//                           _passwordController,
//                           'Create Password',
//                           obscure: _obscurePassword,
//                           toggleVisibility: () => setState(
//                             () => _obscurePassword = !_obscurePassword,
//                           ),
//                         ),
//                         buildShadowedInput(
//                           _confirmPasswordController,
//                           'Confirm Password',
//                           obscure: _obscureConfirmPassword,
//                           toggleVisibility: () => setState(
//                             () => _obscureConfirmPassword =
//                                 !_obscureConfirmPassword,
//                           ),
//                         ),
//                         buildShadowedInput(
//                           _addressController,
//                           'Enter Your Address',
//                           maxLines: 3,
//                         ),
//                         const SizedBox(height: 20),
//                         Container(
//                           decoration: const BoxDecoration(
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black26,
//                                 blurRadius: 8,
//                                 offset: Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             onPressed: _register,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: kPrimary, // ← palette
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 60,
//                                 vertical: 16,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                             child: const Text(
//                               'Register',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontFamily: 'Serif',
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../constants.dart';
import '../config/config.dart';
import '../theme/palette.dart'; // ← palette import

String? _csrfToken;
String? _cookie;
final Logger _logger = Logger();

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchCSRFToken();
  }

  bool _isLoading = false;

  Future<void> _fetchCSRFToken() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/csrf/'));
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        _cookie = rawCookie
            .split(';')
            .firstWhere((e) => e.contains('csrftoken='));
        _csrfToken = _cookie?.split('=')[1];
        _logger.i('CSRF Token Fetched: $_csrfToken');
      }
    } catch (e) {
      _logger.e('CSRF fetch error: $e');
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final confirmPhone = _confirmPhoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final address = _addressController.text.trim();
    final gender = _selectedGender;

    if (name.isEmpty ||
        phone.isEmpty ||
        confirmPhone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        address.isEmpty ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (phone != confirmPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile numbers do not match.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/users/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://fps-dayalbagh-backend.vercel.app/api/csrf/',
          if (_csrfToken != null) 'X-CSRFToken': _csrfToken!,
          if (_cookie != null) 'Cookie': _cookie!,
        },
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "confirm_phone": confirmPhone,
          "password": password,
          "confirm_password": confirmPassword,
          "gender": gender,
          "address": address,
        }),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered Successfully!')),
        );
        Navigator.pop(context);
      } else {
        final body = jsonDecode(response.body);
        final error = body['detail'] ?? 'Registration failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } catch (err) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $err')));
    }
  }

  // ---- UI helpers (visual-only changes) ----

  Widget buildShadowedInput(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16, color: kTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Serif',
              color: kTextPrimary.withOpacity(0.55),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            filled: true,
            fillColor: kCard,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: kBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: kPrimary, width: 1.6),
            ),
            suffixIcon: toggleVisibility != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: kPrimary,
                    ),
                    onPressed: toggleVisibility,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            color: kCard,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                hintText: 'Select Gender',
                hintStyle: TextStyle(
                  fontFamily: 'Serif',
                  color: kTextPrimary.withOpacity(0.55),
                ),
              ),
              style: TextStyle(color: kTextPrimary),
              value: _selectedGender,
              iconEnabledColor: kPrimary,
              dropdownColor: kCard,
              items: ['Male', 'Female', 'Others']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
          ),
        ),
      ),
    );
  }

  // ---- build ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBgTop, kBgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: kTextPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Loader overlay
              if (_isLoading)
                Expanded(
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                      ),
                    ),
                  ),
                ),

              // Form
              if (!_isLoading)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Brand / Title
                              Text(
                                'FPS DAVALBACH',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Serif',
                                  color: kTextPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimarySoft,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: kBorder),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Create your account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Serif',
                                  color: kTextPrimary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Fields
                              buildShadowedInput(
                                _nameController,
                                'Enter Your Name',
                              ),
                              buildGenderDropdown(),
                              buildShadowedInput(
                                _phoneController,
                                'Enter Mobile number',
                                keyboardType: TextInputType.phone,
                              ),
                              buildShadowedInput(
                                _confirmPhoneController,
                                'Confirm Mobile number',
                                keyboardType: TextInputType.phone,
                              ),
                              buildShadowedInput(
                                _passwordController,
                                'Create Password',
                                obscure: _obscurePassword,
                                toggleVisibility: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              buildShadowedInput(
                                _confirmPasswordController,
                                'Confirm Password',
                                obscure: _obscureConfirmPassword,
                                toggleVisibility: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                              ),
                              buildShadowedInput(
                                _addressController,
                                'Enter Your Address',
                                maxLines: 3,
                              ),

                              const SizedBox(height: 10),

                              // Register button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor: kPrimary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ).copyWith(
                                        overlayColor: MaterialStatePropertyAll(
                                          Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Serif',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Subtle helper line
                              Text(
                                'By continuing you agree to our Terms & Privacy.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kTextPrimary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
