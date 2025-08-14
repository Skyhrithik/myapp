// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../main.dart';
// import '../theme/palette.dart'; // ← palette

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nameController.text = prefs.getString('name') ?? 'Guest';
//       _phoneController.text = prefs.getString('phone') ?? 'Not set';
//       _addressController.text =
//           prefs.getString('address') ?? 'No address saved';
//     });
//   }

//   Future<void> _saveUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('name', _nameController.text);
//     await prefs.setString('phone', _phoneController.text);
//     await prefs.setString('address', _addressController.text);
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Profile updated successfully!')),
//     );
//   }

//   Future<void> _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const MyApp()),
//       (route) => false,
//     );
//   }

//   Widget _buildEditableField(
//     String label,
//     TextEditingController controller, {
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style:
//                 Theme.of(context).textTheme.titleMedium?.copyWith(color: kTextPrimary),
//           ),
//           const SizedBox(height: 5),
//           TextField(
//             controller: controller,
//             maxLines: maxLines,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: kCard, // ← palette
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBgBottom, // ← palette
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         backgroundColor: kBgTop, // ← palette
//         foregroundColor: kTextPrimary, // ← palette
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: kPrimarySoft, // ← palette
//                 child: const Icon(Icons.person, size: 50, color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 30),
//             _buildEditableField('Name', _nameController),
//             _buildEditableField('Phone Number', _phoneController),
//             _buildEditableField('Address', _addressController, maxLines: 2),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveUserData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kPrimary, // ← palette
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'Save Changes',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 15),
//             OutlinedButton.icon(
//               onPressed: _logout,
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: kPrimary, // ← palette
//                 side: const BorderSide(color: kPrimary), // ← palette
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../main.dart';
// import '../theme/palette.dart'; // ← palette

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nameController.text = prefs.getString('name') ?? 'Guest';
//       _phoneController.text = prefs.getString('phone') ?? 'Not set';
//       _addressController.text =
//           prefs.getString('address') ?? 'No address saved';
//     });
//   }

//   Future<void> _saveUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('name', _nameController.text);
//     await prefs.setString('phone', _phoneController.text);
//     await prefs.setString('address', _addressController.text);
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Profile updated successfully!')),
//     );
//   }

//   Future<void> _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const MyApp()),
//       (route) => false,
//     );
//   }

//   Widget _buildEditableField(
//     String label,
//     TextEditingController controller, {
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: Theme.of(
//               context,
//             ).textTheme.titleMedium?.copyWith(color: kTextPrimary),
//           ),
//           const SizedBox(height: 5),
//           TextField(
//             controller: controller,
//             maxLines: maxLines,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: kCard, // ← palette
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBgBottom, // ← palette
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         backgroundColor: kBgTop, // ← palette
//         foregroundColor: kTextPrimary, // ← palette
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: kPrimarySoft, // ← palette
//                 child: const Icon(Icons.person, size: 50, color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 30),
//             _buildEditableField('Name', _nameController),
//             _buildEditableField('Phone Number', _phoneController),
//             _buildEditableField('Address', _addressController, maxLines: 2),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveUserData,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kPrimary, // ← palette
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'Save Changes',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 15),
//             OutlinedButton.icon(
//               onPressed: _logout,
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: kPrimary,
//                 side: BorderSide(color: kPrimary),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../theme/palette.dart'; // ← palette

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? 'Guest';
      _phoneController.text = prefs.getString('phone') ?? 'Not set';
      _addressController.text =
          prefs.getString('address') ?? 'No address saved';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
      (route) => false,
    );
  }

  Widget _buildReadOnlyField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: kTextPrimary),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: true, // ← non-editable
            maxLines: maxLines,
            style: TextStyle(color: kTextPrimary),
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: kPrimary) : null,
              filled: true,
              fillColor: kCard, // ← palette
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBottom, // ← palette
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: kBgTop, // ← palette
        foregroundColor: kTextPrimary, // ← palette
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: kPrimarySoft, // ← palette
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            _buildReadOnlyField(
              'Name',
              _nameController,
              icon: Icons.badge_outlined,
            ),
            _buildReadOnlyField(
              'Phone Number',
              _phoneController,
              icon: Icons.phone_outlined,
            ),
            _buildReadOnlyField(
              'Address',
              _addressController,
              maxLines: 2,
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 24),

            // Full-width Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: BorderSide(color: kPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
