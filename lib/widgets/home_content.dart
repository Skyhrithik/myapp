// import 'package:flutter/material.dart';

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent> {
//   int selectedCategory = 0;

//   final List<Map<String, dynamic>> categories = [
//     {'icon': Icons.scale, 'label': 'Groceries'},
//     {'icon': Icons.no_drinks, 'label': 'DB Products'},
//     {'icon': Icons.lightbulb_outline, 'label': 'Electricals'},
//     {'icon': Icons.local_drink, 'label': 'Dairy'},
//     {'icon': Icons.kitchen, 'label': 'Utensils'},
//     {'icon': Icons.chair, 'label': 'Furniture'},
//     {'icon': Icons.tv, 'label': 'Electronics'},
//   ];

//   Widget _buildCategoryIcon(int index) {
//     final category = categories[index];
//     final isSelected = selectedCategory == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedCategory = index;
//         });
//       },
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
//             child: Icon(
//               category['icon'],
//               color: isSelected ? Colors.white : Colors.orange,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             category['label'],
//             style: TextStyle(
//               color: isSelected ? Colors.black : Colors.black87,
//               fontSize: 11,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   Widget _buildItemCard(BuildContext context) {
//     return Container(
//       width: 120,
//       margin: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withAlpha((255 * 0.3).round()),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.image, color: Colors.grey, size: 50),
//             const SizedBox(height: 8),
//             const Text(
//               'Item Name',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '\$\$XX.XX',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverToBoxAdapter(
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFFFF8C00), Color(0xFFF5F5F5)],
//                 stops: [0.0, 0.3],
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//             ),
//             padding: const EdgeInsets.only(
//               top: 60,
//               left: 20,
//               right: 20,
//               bottom: 120,
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Builder(
//                       builder: (context) => IconButton(
//                         icon: const Icon(
//                           Icons.menu,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                         onPressed: () {
//                           Scaffold.of(context).openDrawer();
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 10),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search "Item"',
//                             prefixIcon: const Icon(
//                               Icons.search,
//                               color: Colors.grey,
//                             ),
//                             suffixIcon: const Icon(
//                               Icons.mic,
//                               color: Colors.grey,
//                             ),
//                             fillColor: Colors.white,
//                             filled: true,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 10,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),
//                 SizedBox(
//                   height: 90,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     itemCount: categories.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: _buildCategoryIcon(index),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child: SizedBox(
//                     height: 180,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: 10,
//                       itemBuilder: (context, index) => AnimatedScale(
//                         scale: 1.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: _buildItemCard(context),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionTitle('Complete Your Findings'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: 6,
//                   itemBuilder: (context, index) => _buildItemCard(context),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Reorder'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: 6,
//                   itemBuilder: (context, index) => _buildItemCard(context),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Popular Products'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: 6,
//                   itemBuilder: (context, index) => _buildItemCard(context),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';

// // use your existing files
// import '../models/product.dart';
// // NOTE: your file is plural per your tree: lib/services/api_services.dart
// import 'package:myapp/services/api_services.dart';

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent> {
//   int selectedCategory = 0;

//   // ---- NEW: hold products from API ----
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;

//   final List<Map<String, dynamic>> categories = [
//     {'icon': Icons.scale, 'label': 'Groceries'},
//     {'icon': Icons.no_drinks, 'label': 'DB Products'},
//     {'icon': Icons.lightbulb_outline, 'label': 'Electricals'},
//     {'icon': Icons.local_drink, 'label': 'Dairy'},
//     {'icon': Icons.kitchen, 'label': 'Utensils'},
//     {'icon': Icons.chair, 'label': 'Furniture'},
//     {'icon': Icons.tv, 'label': 'Electronics'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     try {
//       final items = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = items;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }

//   Widget _buildCategoryIcon(int index) {
//     final category = categories[index];
//     final isSelected = selectedCategory == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedCategory = index;
//         });
//       },
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
//             child: Icon(
//               category['icon'],
//               color: isSelected ? Colors.white : Colors.orange,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             category['label'],
//             style: TextStyle(
//               color: isSelected ? Colors.black : Colors.black87,
//               fontSize: 11,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   // ---- ORIGINAL CARD kept, but filled with product data if provided ----
//   Widget _buildItemCard(BuildContext context, {Product? product}) {
//     final name = product?.name ?? 'Item Name';
//     final priceText = product != null
//         ? '₹ ${double.tryParse(product.price)?.toStringAsFixed(2) ?? product.price}'
//         : '\$\$XX.XX';

//     return Container(
//       width: 120,
//       margin: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withAlpha((255 * 0.3).round()),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // API images are null right now—keep the same icon placeholder
//             const Icon(Icons.image, color: Colors.grey, size: 50),
//             const SizedBox(height: 8),
//             Text(
//               name,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               priceText,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // helper to safely take N items even if list is short
//   List<Product> _take(int n) =>
//       _products.length <= n ? _products : _products.sublist(0, n);

//   @override
//   Widget build(BuildContext context) {
//     // show your same layout; just handle loading/error above the content
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(_error!, textAlign: TextAlign.center),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _loadProducts,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     return CustomScrollView(
//       slivers: [
//         SliverToBoxAdapter(
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFFFF8C00), Color(0xFFF5F5F5)],
//                 stops: [0.0, 0.3],
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//             ),
//             padding: const EdgeInsets.only(
//               top: 60,
//               left: 20,
//               right: 20,
//               bottom: 120,
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Builder(
//                       builder: (context) => IconButton(
//                         icon: const Icon(
//                           Icons.menu,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                         onPressed: () {
//                           Scaffold.of(context).openDrawer();
//                         },
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 10),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search "Item"',
//                             prefixIcon: const Icon(
//                               Icons.search,
//                               color: Colors.grey,
//                             ),
//                             suffixIcon: const Icon(
//                               Icons.mic,
//                               color: Colors.grey,
//                             ),
//                             fillColor: Colors.white,
//                             filled: true,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 10,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),
//                 SizedBox(
//                   height: 90,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     itemCount: categories.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: _buildCategoryIcon(index),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // ---- ORIGINAL horizontal section; now shows real products (up to 10) ----
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child: SizedBox(
//                     height: 180,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: _take(10).length,
//                       itemBuilder: (context, index) => AnimatedScale(
//                         scale: 1.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: _buildItemCard(
//                           context,
//                           product: _take(10)[index],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionTitle('Complete Your Findings'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: _take(6).length,
//                   itemBuilder: (context, index) =>
//                       _buildItemCard(context, product: _take(6)[index]),
//                 ),
//                 const SizedBox(height: 20),

//                 _buildSectionTitle('Reorder'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: _take(6).length,
//                   itemBuilder: (context, index) =>
//                       _buildItemCard(context, product: _take(6)[index]),
//                 ),
//                 const SizedBox(height: 20),

//                 _buildSectionTitle('Popular Products'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: _take(6).length,
//                   itemBuilder: (context, index) =>
//                       _buildItemCard(context, product: _take(6)[index]),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';

// import '../models/product.dart';
// // use plural to match your tree
// import 'package:myapp/services/api_services.dart';

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent> {
//   int selectedCategory = 0;

//   // ---- products from API ----
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;

//   final List<Map<String, dynamic>> categories = [
//     {'icon': Icons.scale, 'label': 'Groceries'},
//     {'icon': Icons.no_drinks, 'label': 'DB Products'},
//     {'icon': Icons.lightbulb_outline, 'label': 'Electricals'},
//     {'icon': Icons.local_drink, 'label': 'Dairy'},
//     {'icon': Icons.kitchen, 'label': 'Utensils'},
//     {'icon': Icons.chair, 'label': 'Furniture'},
//     {'icon': Icons.tv, 'label': 'Electronics'},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     try {
//       final items = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = items;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }

//   // ---------- NEW: image URL helper (handles relative paths) ----------
//   String? _imgUrl(Product p) {
//     final raw = p.imageUrl ?? p.image;
//     if (raw == null || raw.isEmpty) return null;
//     if (raw.startsWith('http')) return raw;
//     return raw.startsWith('/')
//         ? 'https://fps-dayalbagh-backend.vercel.app$raw'
//         : 'https://fps-dayalbagh-backend.vercel.app/$raw';
//   }

//   Widget _buildCategoryIcon(int index) {
//     final category = categories[index];
//     final isSelected = selectedCategory == index;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedCategory = index;
//         });
//       },
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
//             child: Icon(
//               category['icon'],
//               color: isSelected ? Colors.white : Colors.orange,
//               size: 30,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             category['label'],
//             style: TextStyle(
//               color: isSelected ? Colors.black : Colors.black87,
//               fontSize: 11,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   // ---------- SAME CARD DESIGN, now shows name + price + stock + image ----------
//   Widget _buildItemCard(BuildContext context, {Product? product}) {
//     final name = product?.name ?? 'Item Name';
//     final priceText = product != null
//         ? '₹ ${double.tryParse(product.price)?.toStringAsFixed(2) ?? product.price}'
//         : '\$\$XX.XX';
//     final stockText = product != null ? 'Stock: ${product.stock}' : '';
//     final img = product != null ? _imgUrl(product) : null;

//     return Container(
//       width: 120,
//       margin: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withAlpha((255 * 0.3).round()),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // keep same 50x50 footprint; show image if available
//             SizedBox(
//               width: 50,
//               height: 50,
//               child: img == null
//                   ? const Icon(Icons.image, color: Colors.grey, size: 50)
//                   : Image.network(
//                       img,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => const Icon(
//                         Icons.broken_image_outlined,
//                         color: Colors.grey,
//                         size: 50,
//                       ),
//                     ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               name,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               priceText,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//             if (product != null) ...[
//               const SizedBox(height: 2),
//               Text(
//                 stockText,
//                 style: const TextStyle(fontSize: 10, color: Colors.black54),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   List<Product> _take(int n) =>
//       _products.length <= n ? _products : _products.sublist(0, n);

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(_error!, textAlign: TextAlign.center),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _loadProducts,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     // ---------- your original layout unchanged ----------
//     return CustomScrollView(
//       slivers: [
//         SliverToBoxAdapter(
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFFFF8C00), Color(0xFFF5F5F5)],
//                 stops: [0.0, 0.3],
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//             ),
//             padding: const EdgeInsets.only(
//               top: 60,
//               left: 20,
//               right: 20,
//               bottom: 120,
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Builder(
//                       builder: (context) => IconButton(
//                         icon: const Icon(
//                           Icons.menu,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                         onPressed: () => Scaffold.of(context).openDrawer(),
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 10),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search "Item"',
//                             prefixIcon: const Icon(
//                               Icons.search,
//                               color: Colors.grey,
//                             ),
//                             suffixIcon: const Icon(
//                               Icons.mic,
//                               color: Colors.grey,
//                             ),
//                             fillColor: Colors.white,
//                             filled: true,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 10,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 SizedBox(
//                   height: 90,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     itemCount: categories.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: _buildCategoryIcon(index),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child: SizedBox(
//                     height: 180,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: _take(10).length,
//                       itemBuilder: (context, index) => AnimatedScale(
//                         scale: 1.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: _buildItemCard(
//                           context,
//                           product: _take(10)[index],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionTitle('Complete Your Findings'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: _take(6).length,
//                   itemBuilder: (context, index) =>
//                       _buildItemCard(context, product: _take(6)[index]),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Reorder'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: _take(6).length,
//                   itemBuilder: (context, index) =>
//                       _buildItemCard(context, product: _take(6)[index]),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Popular Products'),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemCount: _take(6).length,
//                   itemBuilder: (context, index) =>
//                       _buildItemCard(context, product: _take(6)[index]),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// version 4

import 'package:flutter/material.dart';

import '../models/product.dart';
// NOTE: matches your tree: lib/services/api_services.dart (plural)
import 'package:myapp/services/api_services.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int selectedCategory = 0;

  // products + quantities
  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  final Map<int, int> _qty = {}; // productId -> quantity

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.scale, 'label': 'Groceries'},
    {'icon': Icons.no_drinks, 'label': 'DB Products'},
    {'icon': Icons.lightbulb_outline, 'label': 'Electricals'},
    {'icon': Icons.local_drink, 'label': 'Dairy'},
    {'icon': Icons.kitchen, 'label': 'Utensils'},
    {'icon': Icons.chair, 'label': 'Furniture'},
    {'icon': Icons.tv, 'label': 'Electronics'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final items = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Build absolute URL if backend returns relative paths
  String? _imgUrl(Product p) {
    final raw = p.imageUrl ?? p.image;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return raw.startsWith('/')
        ? 'https://fps-dayalbagh-backend.vercel.app$raw'
        : 'https://fps-dayalbagh-backend.vercel.app/$raw';
  }

  // qty helpers
  int _getQty(Product p) => _qty[p.id] ?? 0;
  void _inc(Product p) {
    if (p.stock <= 0) return;
    final current = _qty[p.id] ?? 0;
    if (current >= p.stock) return;
    setState(() => _qty[p.id] = current + 1);
  }

  void _dec(Product p) {
    final current = _qty[p.id] ?? 0;
    if (current <= 0) return;
    setState(() => _qty[p.id] = current - 1);
  }

  void _addToCart(Product p) {
    final q = _getQty(p);
    // Hook to your cart provider/backend here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${q > 0 ? q : 1} × "${p.name}"')),
    );
    if (q == 0) _inc(p); // quick add 1 if none selected
  }

  Widget _buildCategoryIcon(int index) {
    final category = categories[index];
    final isSelected = selectedCategory == index;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = index),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
            child: Icon(
              category['icon'],
              color: isSelected ? Colors.white : Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            category['label'],
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black87,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Overflow-proof, bigger product card with qty row
  Widget _productCard(Product p) {
    final img = _imgUrl(p);
    final priceText =
        '₹ ${double.tryParse(p.price)?.toStringAsFixed(2) ?? p.price}';
    final q = _getQty(p);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 180, // used in horizontal list; grid will size by aspect ratio
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image expands to take leftover space, avoids overflow
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: img == null
                          ? Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 44,
                                ),
                              ),
                            )
                          : Image.network(
                              img,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                    size: 44,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: p.stock > 0 ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        p.stock > 0 ? 'In stock: ${p.stock}' : 'Out of stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Name — fixed height area (2 lines max)
            SizedBox(
              height: 36, // ~2 lines at 14sp
              child: Text(
                p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Price pill (tap = quick add)
            GestureDetector(
              onTap: () => _addToCart(p),
              child: Container(
                height: 32,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  priceText,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Quantity row — fixed height
            SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _qtyButton(
                    icon: Icons.remove,
                    onTap: q > 0 ? () => _dec(p) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      '$q',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _qtyButton(
                    icon: Icons.add,
                    onTap: (p.stock > 0 && q < p.stock) ? () => _inc(p) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // small rounded icon button for qty
  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap == null ? Colors.grey.shade300 : Colors.orange,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  // helpers
  List<Product> _take(int n) =>
      _products.length <= n ? _products : _products.sublist(0, n);

  Map<String, List<Product>> get _byCategory {
    final map = <String, List<Product>>{};
    for (final p in _products) {
      final key = (p.categoryName.isNotEmpty) ? p.categoryName : 'Other';
      (map[key] ??= <Product>[]).add(p);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // ======= Your original header/strip preserved =======
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF8C00), Color(0xFFF5F5F5)],
                stops: [0.0, 0.3],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 120,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search "Item"',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: const Icon(
                              Icons.mic,
                              color: Colors.grey,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: categories.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _buildCategoryIcon(index),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Top horizontal products — fixed container; cards flex internally
                SizedBox(
                  height: 300, // ample height; card won't overflow
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _take(10).length,
                    itemBuilder: (context, i) => _productCard(_take(10)[i]),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ======= Category sections (dynamic) =======
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in _byCategory.entries) ...[
                  _buildSectionTitle(entry.key),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // bigger cards → 2 per row
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              0.62, // tall items; card flexes inside
                        ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) =>
                        _productCard(entry.value[index]),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
