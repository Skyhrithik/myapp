// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MenuDrawer extends StatefulWidget {
//   final Function(int)? onNavigate;

//   const MenuDrawer({super.key, this.onNavigate});

//   @override
//   State<MenuDrawer> createState() => _MenuDrawerState();
// }

// class _MenuDrawerState extends State<MenuDrawer> {
//   String name = '';
//   String phone = '';
//   String? profilePath;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       name = prefs.getString('name') ?? 'Guest';
//       phone = prefs.getString('phone') ?? '';
//       profilePath = prefs.getString('profilePhoto'); // Optional
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             decoration: const BoxDecoration(color: Colors.deepOrangeAccent),
//             accountName: Text(name),
//             accountEmail: Text('+91 $phone'),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               backgroundImage:
//                   profilePath != null && profilePath!.isNotEmpty
//                       ? FileImage(File(profilePath!)) as ImageProvider
//                       : const AssetImage('assets/profile_placeholder.png'),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.person_outline),
//             title: const Text('My Profile'),
//             onTap: () {
//               Navigator.pop(context);
//               widget.onNavigate?.call(3); // Navigate to profile tab
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.list_alt),
//             title: const Text('My Orders'),
//             onTap: () {
//               Navigator.pop(context);
//               // You can define separate logic or screen for orders
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.favorite_border),
//             title: const Text('Favorites'),
//             onTap: () {
//               Navigator.pop(context);
//               widget.onNavigate?.call(1); // Navigate to favorites tab
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.shopping_cart_outlined),
//             title: const Text('Cart'),
//             onTap: () {
//               Navigator.pop(context);
//               widget.onNavigate?.call(2); // Navigate to cart tab
//             },
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () {
//               Navigator.pop(context);
//               // Navigate to settings page
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Logout'),
//             onTap: () {
//               Navigator.pop(context);
//               // Implement logout logic
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../theme/palette.dart'; // ← palette import

// class MenuDrawer extends StatefulWidget {
//   final Function(int)? onNavigate;

//   const MenuDrawer({super.key, this.onNavigate});

//   @override
//   State<MenuDrawer> createState() => _MenuDrawerState();
// }

// class _MenuDrawerState extends State<MenuDrawer> {
//   String name = '';
//   String phone = '';
//   String? profilePath;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       name = prefs.getString('name') ?? 'Guest';
//       phone = prefs.getString('phone') ?? '';
//       profilePath = prefs.getString('profilePhoto'); // Optional
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: kBgBottom, // ← palette
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           UserAccountsDrawerHeader(
//             decoration: const BoxDecoration(color: kPrimary), // ← palette
//             accountName: Text(name),
//             accountEmail: Text('+91 $phone'),
//             currentAccountPicture: const CircleAvatar(
//               backgroundColor: kCard, // ← palette
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.person_outline,
//               color: kPrimary,
//             ), // ← palette
//             title: const Text(
//               'My Profile',
//               style: TextStyle(color: kTextPrimary),
//             ), // ← palette
//             onTap: () {
//               Navigator.pop(context);
//               widget.onNavigate?.call(3); // Navigate to profile tab
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.list_alt, color: kPrimary), // ← palette
//             title: const Text(
//               'My Orders',
//               style: TextStyle(color: kTextPrimary),
//             ), // ← palette
//             onTap: () {
//               Navigator.pop(context);
//               // You can define separate logic or screen for orders
//             },
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.favorite_border,
//               color: kPrimary,
//             ), // ← palette
//             title: const Text(
//               'Favorites',
//               style: TextStyle(color: kTextPrimary),
//             ), // ← palette
//             onTap: () {
//               Navigator.pop(context);
//               widget.onNavigate?.call(1); // Navigate to favorites tab
//             },
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.shopping_cart_outlined,
//               color: kPrimary,
//             ), // ← palette
//             title: const Text(
//               'Cart',
//               style: TextStyle(color: kTextPrimary),
//             ), // ← palette
//             onTap: () {
//               Navigator.pop(context);
//               widget.onNavigate?.call(2); // Navigate to cart tab
//             },
//           ),
//           const Divider(color: kBorder), // ← palette
//           ListTile(
//             leading: const Icon(Icons.settings, color: kPrimary), // ← palette
//             title: const Text(
//               'Settings',
//               style: TextStyle(color: kTextPrimary),
//             ), // ← palette
//             onTap: () {
//               Navigator.pop(context);
//               // Navigate to settings page
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout, color: kPrimary), // ← palette
//             title: const Text(
//               'Logout',
//               style: TextStyle(color: kTextPrimary),
//             ), // ← palette
//             onTap: () {
//               Navigator.pop(context);
//               // Implement logout logic
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/palette.dart'; // ← palette import

class MenuDrawer extends StatefulWidget {
  final Function(int)? onNavigate;

  const MenuDrawer({super.key, this.onNavigate});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String name = '';
  String phone = '';
  String? profilePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Guest';
      phone = prefs.getString('phone') ?? '';
      profilePath = prefs.getString('profilePhoto'); // Optional
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kBgBottom, // ← palette
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: kPrimary), // ← palette
            accountName: const Text(
              '',
              // keep default style; name shown in Text below to control color
            ),
            accountEmail: const Text(''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: kCard, // ← palette
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          // Override the name/email with palette-colored text under the header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              name,
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '+91 $phone',
              style: TextStyle(color: kTextPrimary.withOpacity(0.7)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: kPrimary), // ← palette
            title: Text(
              'My Profile',
              style: TextStyle(color: kTextPrimary),
            ), // ← palette
            onTap: () {
              Navigator.pop(context);
              widget.onNavigate?.call(3); // Navigate to profile tab
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt, color: kPrimary), // ← palette
            title: Text(
              'My Orders',
              style: TextStyle(color: kTextPrimary),
            ), // ← palette
            onTap: () {
              Navigator.pop(context);
              // You can define separate logic or screen for orders
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border, color: kPrimary), // ← palette
            title: Text(
              'Favorites',
              style: TextStyle(color: kTextPrimary),
            ), // ← palette
            onTap: () {
              Navigator.pop(context);
              widget.onNavigate?.call(1); // Navigate to favorites tab
            },
          ),
          ListTile(
            leading: Icon(
              Icons.shopping_cart_outlined,
              color: kPrimary,
            ), // ← palette
            title: Text(
              'Cart',
              style: TextStyle(color: kTextPrimary),
            ), // ← palette
            onTap: () {
              Navigator.pop(context);
              widget.onNavigate?.call(2); // Navigate to cart tab
            },
          ),
          Divider(color: kBorder), // ← palette
          ListTile(
            leading: Icon(Icons.settings, color: kPrimary), // ← palette
            title: Text(
              'Settings',
              style: TextStyle(color: kTextPrimary),
            ), // ← palette
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: kPrimary), // ← palette
            title: Text(
              'Logout',
              style: TextStyle(color: kTextPrimary),
            ), // ← palette
            onTap: () {
              Navigator.pop(context);
              // Implement logout logic
            },
          ),
        ],
      ),
    );
  }
}
