// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import 'package:fps/services/api_services.dart';
// import 'package:provider/provider.dart';
// import '../providers/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // products + quantities
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;

//   // product qty store (fast updates with ValueNotifier)
//   final Map<int, int> _qty = {}; // productId -> quantity
//   final Map<int, ValueNotifier<int>> _qtyVN = {}; // productId -> notifier
//   ValueNotifier<int> _vnFor(Product p) =>
//       _qtyVN.putIfAbsent(p.id, () => ValueNotifier(_qty[p.id] ?? 0));

//   // dynamic categories from backend data
//   late List<_CategoryInfo> _categories = [];

//   // search
//   final TextEditingController _searchCtrl = TextEditingController();
//   Timer? _searchDebounce;
//   String _q = '';

//   @override
//   void initState() {
//     super.initState();
//     _bootstrap();
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _bootstrap() async {
//     await _tryLoadFromCache(); // instant paint if cache exists
//     await _loadProducts(); // refresh from server
//   }

//   Future<void> _tryLoadFromCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString('products_cache');
//       if (raw == null || raw.isEmpty) return;
//       final List data = jsonDecode(raw) as List;
//       final cached = data
//           .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//       if (!mounted) return;
//       setState(() {
//         _products = cached;
//         _loading = false; // show cache immediately
//         _buildDynamicCategories();
//       });
//     } catch (_) {
//       // ignore cache errors
//     }
//   }

//   // Minimal serializer for Product -> Map (since Product has no toJson()).
//   Map<String, dynamic> _productToCache(Product p) => {
//     'id': p.id,
//     'name': p.name,
//     'stock': p.stock,
//     'price': p.price,
//     'category': p.category,
//     'category_name': p.categoryName,
//     'image': p.image,
//     'image_url': p.imageUrl,
//   };

//   Future<void> _saveCache(List<Product> items) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = jsonEncode(items.map(_productToCache).toList());
//       await prefs.setString('products_cache', raw);
//     } catch (_) {
//       /* ignore */
//     }
//   }

//   Future<void> _loadProducts() async {
//     try {
//       final items = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = items;
//         _loading = false;
//         _error = null;
//         _buildDynamicCategories();
//       });
//       // refresh cache (don’t await)
//       unawaited(_saveCache(items));
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _loading = _products.isEmpty; // keep showing cache if we have it
//       });
//     }
//   }

//   // ===== helpers =====

//   // Only show items with stock > 5
//   List<Product> get _visibleProducts =>
//       _products.where((p) => p.stock > 5).toList();

//   // absolute URL if backend returns relative paths
//   String? _imgUrl(Product p) {
//     final raw = p.imageUrl ?? p.image;
//     if (raw == null || raw.isEmpty) return null;
//     if (raw.startsWith('http')) return raw;
//     return raw.startsWith('/')
//         ? 'https://fps-dayalbagh-backend.vercel.app$raw'
//         : 'https://fps-dayalbagh-backend.vercel.app/$raw';
//   }

//   // price helpers
//   double _priceDouble(Product p) => double.tryParse('${p.price}') ?? 0.0;
//   String _priceText(Product p) => '₹ ${_priceDouble(p).toStringAsFixed(2)}';

//   bool _isDayalbagh(Product p) =>
//       p.categoryName.toUpperCase().contains('DAYALBAGH');
//   int _maxPerItem(Product p) => _isDayalbagh(p) ? 2 : 999999;

//   // CART helpers (fast: update notifier, not whole grid)
//   void _setQty(Product p, int newVal) {
//     _qty[p.id] = newVal;
//     _vnFor(p).value = newVal; // only qty row rebuilds
//   }

//   void _cartAdd(Product p, int qty) {
//     final id = p.id.toString(); // provider expects String id
//     final title = p.name;
//     final price = _priceDouble(p);
//     context.read<CartProvider>().add(
//       id: id,
//       title: title,
//       price: price,
//       qty: qty,
//     );
//   }

//   void _inc(Product p) {
//     if (p.stock <= 0) return;
//     final max = _maxPerItem(p);
//     final current = _qty[p.id] ?? 0;
//     if (current >= p.stock) return;
//     if (current >= max) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _setQty(p, current + 1);
//     _cartAdd(p, 1);
//   }

//   void _dec(Product p) {
//     final current = _qty[p.id] ?? 0;
//     if (current <= 0) return;
//     _setQty(p, current - 1);
//     context.read<CartProvider>().removeOne(p.id.toString());
//   }

//   void _addToCart(Product p) {
//     final current = _qty[p.id] ?? 0;
//     final requested = current > 0 ? current : 1;
//     final max = _maxPerItem(p);
//     final canAdd = (max - current).clamp(0, requested);
//     if (canAdd <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _cartAdd(p, canAdd);
//     _setQty(p, current + canAdd);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Added $canAdd × "${p.name}"')));
//   }

//   // dynamic categories from VISIBLE products
//   void _buildDynamicCategories() {
//     final Map<int, _CategoryInfo> m = {};
//     for (final p in _visibleProducts) {
//       final id = p.category;
//       final name = (p.categoryName.isNotEmpty) ? p.categoryName : 'Other';
//       m.putIfAbsent(
//         id,
//         () => _CategoryInfo(id: id, name: name, icon: _iconForCategory(name)),
//       );
//     }
//     final list = m.values.toList()..sort((a, b) => a.name.compareTo(b.name));
//     _categories = list;
//   }

//   IconData _iconForCategory(String name) {
//     final n = name.toLowerCase();
//     if (n.contains('grocery') || n.contains('grocer')) return Icons.scale;
//     if (n.contains('dairy')) return Icons.local_drink;
//     if (n.contains('electrical')) return Icons.lightbulb_outline;
//     if (n.contains('electronic')) return Icons.tv;
//     if (n.contains('furniture')) return Icons.chair;
//     if (n.contains('utensil') || n.contains('kitchen')) return Icons.kitchen;
//     if (n.contains('home')) return Icons.home_outlined;
//     if (n.contains('personal') || n.contains('care')) return Icons.spa_outlined;
//     if (n.contains('beverage') || n.contains('drink'))
//       return Icons.local_cafe_outlined;
//     return Icons.inventory_2_outlined;
//   }

//   // search control (debounced) — searches visible products only
//   void _onSearchChanged(String v) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   List<Product> get _searchResults {
//     if (_q.isEmpty) return const [];
//     final base = _visibleProducts;
//     return base.where((p) {
//       final name = p.name.toLowerCase();
//       final cat = p.categoryName.toLowerCase();
//       return name.contains(_q) || cat.contains(_q);
//     }).toList();
//   }

//   // ===== UI parts =====

//   Widget _buildCategoryChip(_CategoryInfo c) {
//     return Padding(
//       // +2.0 px horizontal padding to avoid overlay crowding
//       padding: const EdgeInsets.symmetric(horizontal: 2.0),
//       child: GestureDetector(
//         onTap: () {
//           final products = _visibleProducts
//               .where((p) => p.category == c.id)
//               .toList();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => _CategoryProductsPage(
//                 categoryId: c.id,
//                 categoryName: c.name,
//                 products: products,
//                 imgUrlBuilder: _imgUrl,
//                 onAddToCart: _addToCart,
//                 onInc: _inc,
//                 onDec: _dec,
//                 getQtyVN: _vnFor,
//                 maxPerItem: _maxPerItem,
//               ),
//             ),
//           );
//         },
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.deepPurple,
//               child: Icon(c.icon, color: Colors.white, size: 28),
//             ),
//             const SizedBox(height: 6),
//             // Long names: smaller font, tight height, ellipsis
//             ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 96),
//               child: Text(
//                 c.name,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: false,
//                 style: const TextStyle(
//                   fontSize: 10, // a bit smaller to avoid overflow
//                   height: 1.1,
//                   letterSpacing: 0.2,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
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

//   // product card (no stock badge). Only the qty row rebuilds via ValueListenableBuilder.
//   Widget _productCard(Product p) {
//     final img = _imgUrl(p);
//     final priceText = _priceText(p);
//     final vn = _vnFor(p);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.all(8),
//       clipBehavior: Clip.antiAlias,
//       child: Container(
//         width: 180,
//         padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Image
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: img == null
//                     ? Container(
//                         color: Colors.grey.shade200,
//                         child: const Center(
//                           child: Icon(
//                             Icons.image,
//                             color: Colors.grey,
//                             size: 44,
//                           ),
//                         ),
//                       )
//                     : Image.network(
//                         img,
//                         fit: BoxFit.cover,
//                         cacheWidth: 400,
//                         filterQuality: FilterQuality.low,
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return Container(
//                             color: Colors.grey.shade200,
//                             child: const Center(
//                               child: SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         errorBuilder: (_, __, ___) => Container(
//                           color: Colors.grey.shade200,
//                           child: const Center(
//                             child: Icon(
//                               Icons.broken_image_outlined,
//                               color: Colors.grey,
//                               size: 44,
//                             ),
//                           ),
//                         ),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Name
//             SizedBox(
//               height: 36,
//               child: Text(
//                 p.name,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Price pill (tap = add to cart)
//             GestureDetector(
//               onTap: () => _addToCart(p),
//               child: Container(
//                 height: 32,
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.orange.shade200),
//                 ),
//                 child: Text(
//                   priceText,
//                   style: const TextStyle(
//                     color: Colors.orange,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Quantity row (fast updates)
//             ValueListenableBuilder<int>(
//               valueListenable: vn,
//               builder: (_, q, __) {
//                 final canInc =
//                     (p.stock > 0) && (q < p.stock) && (q < _maxPerItem(p));
//                 return SizedBox(
//                   height: 36,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _qtyButton(
//                         icon: Icons.remove,
//                         onTap: q > 0 ? () => _dec(p) : null,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.black12),
//                         ),
//                         child: Text(
//                           '$q',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       _qtyButton(
//                         icon: Icons.add,
//                         onTap: canInc ? () => _inc(p) : null,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // small rounded icon button for qty
//   Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? Colors.grey.shade300 : Colors.orange,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: const Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Icon(
//             Icons.add,
//             size: 18,
//             color: Colors.white,
//           ), // will be overridden by IconTheme
//         ),
//       ),
//     );
//   }

//   // === BUILD ===
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_loading) return const Center(child: CircularProgressIndicator());

//     final results = _searchResults;
//     final showingSearch = _q.isNotEmpty;

//     return RefreshIndicator(
//       onRefresh: _loadProducts,
//       child: CustomScrollView(
//         slivers: [
//           // HERO HEADER
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Color(0xFFFF8C00), Color(0xFFF5F5F5)],
//                   stops: [0.0, 0.3],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               padding: const EdgeInsets.only(
//                 top: 60,
//                 left: 20,
//                 right: 20,
//                 bottom: 24,
//               ),
//               child: Column(
//                 children: [
//                   // Menu + Search
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Builder(
//                         builder: (context) => IconButton(
//                           icon: const Icon(
//                             Icons.menu,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: () => Scaffold.of(context).openDrawer(),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 10),
//                           child: TextField(
//                             controller: _searchCtrl,
//                             onChanged: _onSearchChanged,
//                             decoration: InputDecoration(
//                               hintText: 'Search products',
//                               prefixIcon: const Icon(
//                                 Icons.search,
//                                 color: Colors.grey,
//                               ),
//                               suffixIcon: (_q.isNotEmpty)
//                                   ? IconButton(
//                                       icon: const Icon(
//                                         Icons.clear,
//                                         color: Colors.grey,
//                                       ),
//                                       onPressed: () {
//                                         _searchCtrl.clear();
//                                         _onSearchChanged('');
//                                       },
//                                     )
//                                   : const Icon(Icons.mic, color: Colors.grey),
//                               fillColor: Colors.white,
//                               filled: true,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 22),

//                   // Dynamic categories (horizontal) — increased height to avoid 2px overflow on long names
//                   SizedBox(
//                     height: 106, // was 96
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       itemBuilder: (_, i) => _buildCategoryChip(_categories[i]),
//                       separatorBuilder: (_, __) =>
//                           const SizedBox(width: 18), // +2px spacing
//                       itemCount: _categories.length,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Search results grid (only when typing)
//           if (showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Results (${results.length})'),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 0.62,
//                           ),
//                       itemCount: results.length,
//                       itemBuilder: (_, i) => _productCard(results[i]),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),

//           // ALL PRODUCTS grid (lazy-built) when not searching
//           if (!showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.62,
//                 ),
//                 delegate: SliverChildBuilderDelegate((context, index) {
//                   final p = _visibleProducts[index];
//                   return _productCard(p);
//                 }, childCount: _visibleProducts.length),
//               ),
//             ),

//           // Optional error banner (non-blocking if cache shown)
//           if (_error != null && _products.isNotEmpty)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: MaterialBanner(
//                   content: Text('Couldn\'t refresh: $_error'),
//                   actions: [
//                     TextButton(
//                       onPressed: _loadProducts,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ===== Category page (opens when a category chip is tapped) =====

// class _CategoryProductsPage extends StatelessWidget {
//   final int categoryId;
//   final String categoryName;
//   final List<Product> products; // already filtered to stock > 5
//   final String? Function(Product) imgUrlBuilder;
//   final void Function(Product) onAddToCart;
//   final void Function(Product) onInc;
//   final void Function(Product) onDec;
//   final ValueNotifier<int> Function(Product) getQtyVN;
//   final int Function(Product) maxPerItem;

//   const _CategoryProductsPage({
//     required this.categoryId,
//     required this.categoryName,
//     required this.products,
//     required this.imgUrlBuilder,
//     required this.onAddToCart,
//     required this.onInc,
//     required this.onDec,
//     required this.getQtyVN,
//     required this.maxPerItem,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(categoryName)),
//       body: Column(
//         children: [
//           _CategorySearch(title: categoryName),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(12),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 0.62,
//               ),
//               itemCount: products.length,
//               itemBuilder: (_, i) {
//                 final p = products[i];
//                 final img = imgUrlBuilder(p);
//                 final priceText =
//                     '₹ ${double.tryParse('${p.price}')?.toStringAsFixed(2) ?? '${p.price}'}';
//                 final vn = getQtyVN(p);

//                 return Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: img == null
//                                 ? Container(
//                                     color: Colors.grey.shade200,
//                                     child: const Center(
//                                       child: Icon(
//                                         Icons.image,
//                                         color: Colors.grey,
//                                         size: 44,
//                                       ),
//                                     ),
//                                   )
//                                 : Image.network(
//                                     img,
//                                     fit: BoxFit.cover,
//                                     cacheWidth: 400,
//                                     filterQuality: FilterQuality.low,
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Container(
//                                         color: Colors.grey.shade200,
//                                         child: const Center(
//                                           child: SizedBox(
//                                             height: 22,
//                                             width: 22,
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 36,
//                           child: Text(
//                             p.name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => onAddToCart(p),
//                           child: Container(
//                             height: 32,
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.orange.shade200),
//                             ),
//                             child: Text(
//                               priceText,
//                               style: const TextStyle(
//                                 color: Colors.orange,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ValueListenableBuilder<int>(
//                           valueListenable: vn,
//                           builder: (_, q, __) {
//                             final canInc =
//                                 (p.stock > 0) &&
//                                 (q < p.stock) &&
//                                 (q < maxPerItem(p));
//                             return SizedBox(
//                               height: 36,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _qtyBtn(
//                                     icon: Icons.remove,
//                                     onTap: q > 0 ? () => onDec(p) : null,
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade100,
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(color: Colors.black12),
//                                     ),
//                                     child: Text(
//                                       '$q',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                   _qtyBtn(
//                                     icon: Icons.add,
//                                     onTap: canInc ? () => onInc(p) : null,
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? Colors.grey.shade300 : Colors.orange,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// // small search on category page
// class _CategorySearch extends StatefulWidget {
//   final String title;
//   const _CategorySearch({required this.title});

//   @override
//   State<_CategorySearch> createState() => _CategorySearchState();
// }

// class _CategorySearchState extends State<_CategorySearch> {
//   String _q = '';
//   final _ctrl = TextEditingController();
//   Timer? _deb;

//   @override
//   void dispose() {
//     _deb?.cancel();
//     _ctrl.dispose();
//     super.dispose();
//   }

//   void _onChanged(String v) {
//     _deb?.cancel();
//     _deb = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       child: TextField(
//         controller: _ctrl,
//         onChanged: _onChanged,
//         decoration: InputDecoration(
//           hintText: 'Search "${widget.title}"',
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: (_q.isNotEmpty)
//               ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     _ctrl.clear();
//                     _onChanged('');
//                   },
//                 )
//               : null,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//           isDense: true,
//         ),
//       ),
//     );
//   }
// }

// // ===== internal types =====
// class _CategoryInfo {
//   final int id;
//   final String name;
//   final IconData icon;
//   _CategoryInfo({required this.id, required this.name, required this.icon});
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import 'package:fps/services/api_services.dart';
// import 'package:provider/provider.dart';
// import '../providers/provider.dart'; // <-- CartProvider
// import 'package:shared_preferences/shared_preferences.dart';
// import '../theme/palette.dart'; // <-- warm palette

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // products + quantities
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;

//   // product qty store (fast updates with ValueNotifier)
//   final Map<int, int> _qty = {}; // productId -> quantity
//   final Map<int, ValueNotifier<int>> _qtyVN = {}; // productId -> notifier
//   ValueNotifier<int> _vnFor(Product p) =>
//       _qtyVN.putIfAbsent(p.id, () => ValueNotifier(_qty[p.id] ?? 0));

//   // dynamic categories from backend data
//   late List<_CategoryInfo> _categories = [];

//   // search
//   final TextEditingController _searchCtrl = TextEditingController();
//   Timer? _searchDebounce;
//   String _q = '';

//   @override
//   void initState() {
//     super.initState();
//     _bootstrap();
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _bootstrap() async {
//     await _tryLoadFromCache(); // instant paint if cache exists
//     await _loadProducts(); // refresh from server
//   }

//   Future<void> _tryLoadFromCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString('products_cache');
//       if (raw == null || raw.isEmpty) return;
//       final List data = jsonDecode(raw) as List;
//       final cached = data
//           .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//       if (!mounted) return;
//       setState(() {
//         _products = cached;
//         _loading = false; // show cache immediately
//         _buildDynamicCategories();
//       });
//     } catch (_) {
//       // ignore cache errors
//     }
//   }

//   // Minimal serializer for Product -> Map (since Product has no toJson()).
//   Map<String, dynamic> _productToCache(Product p) => {
//     'id': p.id,
//     'name': p.name,
//     'stock': p.stock,
//     'price': p.price,
//     'category': p.category,
//     'category_name': p.categoryName,
//     'image': p.image,
//     'image_url': p.imageUrl,
//   };

//   Future<void> _saveCache(List<Product> items) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = jsonEncode(items.map(_productToCache).toList());
//       await prefs.setString('products_cache', raw);
//     } catch (_) {
//       /* ignore */
//     }
//   }

//   Future<void> _loadProducts() async {
//     try {
//       final items = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = items;
//         _loading = false;
//         _error = null;
//         _buildDynamicCategories();
//       });
//       // refresh cache (don’t await)
//       unawaited(_saveCache(items));
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _loading = _products.isEmpty; // keep showing cache if we have it
//       });
//     }
//   }

//   // ===== helpers =====

//   // Only show items with stock > 5
//   List<Product> get _visibleProducts =>
//       _products.where((p) => p.stock > 5).toList();

//   // absolute URL if backend returns relative paths
//   String? _imgUrl(Product p) {
//     final raw = p.imageUrl ?? p.image;
//     if (raw == null || raw.isEmpty) return null;
//     if (raw.startsWith('http')) return raw;
//     return raw.startsWith('/')
//         ? 'https://fps-dayalbagh-backend.vercel.app$raw'
//         : 'https://fps-dayalbagh-backend.vercel.app/$raw';
//   }

//   // price helpers
//   double _priceDouble(Product p) => double.tryParse('${p.price}') ?? 0.0;
//   String _priceText(Product p) => '₹ ${_priceDouble(p).toStringAsFixed(2)}';

//   bool _isDayalbagh(Product p) =>
//       p.categoryName.toUpperCase().contains('DAYALBAGH');
//   int _maxPerItem(Product p) => _isDayalbagh(p) ? 2 : 999999;

//   // CART helpers (fast: update notifier, not whole grid)
//   void _setQty(Product p, int newVal) {
//     _qty[p.id] = newVal;
//     _vnFor(p).value = newVal; // only qty row rebuilds
//   }

//   void _cartAdd(Product p, int qty) {
//     final id = p.id.toString(); // provider expects String id
//     final title = p.name;
//     final price = _priceDouble(p);
//     context.read<CartProvider>().add(
//       id: id,
//       title: title,
//       price: price,
//       qty: qty,
//     );
//   }

//   void _inc(Product p) {
//     if (p.stock <= 0) return;
//     final max = _maxPerItem(p);
//     final current = _qty[p.id] ?? 0;
//     if (current >= p.stock) return;
//     if (current >= max) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _setQty(p, current + 1);
//     _cartAdd(p, 1);
//   }

//   void _dec(Product p) {
//     final current = _qty[p.id] ?? 0;
//     if (current <= 0) return;
//     _setQty(p, current - 1);
//     context.read<CartProvider>().removeOne(p.id.toString());
//   }

//   void _addToCart(Product p) {
//     final current = _qty[p.id] ?? 0;
//     final requested = current > 0 ? current : 1;
//     final max = _maxPerItem(p);
//     final canAdd = (max - current).clamp(0, requested);
//     if (canAdd <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _cartAdd(p, canAdd);
//     _setQty(p, current + canAdd);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Added $canAdd × "${p.name}"')));
//   }

//   // dynamic categories from VISIBLE products
//   void _buildDynamicCategories() {
//     final Map<int, _CategoryInfo> m = {};
//     for (final p in _visibleProducts) {
//       final id = p.category;
//       final name = (p.categoryName.isNotEmpty) ? p.categoryName : 'Other';
//       m.putIfAbsent(
//         id,
//         () => _CategoryInfo(id: id, name: name, icon: _iconForCategory(name)),
//       );
//     }
//     final list = m.values.toList()..sort((a, b) => a.name.compareTo(b.name));
//     _categories = list;
//   }

//   IconData _iconForCategory(String name) {
//     final n = name.toLowerCase();
//     if (n.contains('grocery') || n.contains('grocer')) return Icons.scale;
//     if (n.contains('dairy')) return Icons.local_drink;
//     if (n.contains('electrical')) return Icons.lightbulb_outline;
//     if (n.contains('electronic')) return Icons.tv;
//     if (n.contains('furniture')) return Icons.chair;
//     if (n.contains('utensil') || n.contains('kitchen')) return Icons.kitchen;
//     if (n.contains('home')) return Icons.home_outlined;
//     if (n.contains('personal') || n.contains('care')) return Icons.spa_outlined;
//     if (n.contains('beverage') || n.contains('drink'))
//       return Icons.local_cafe_outlined;
//     return Icons.inventory_2_outlined;
//   }

//   // search control (debounced) — searches visible products only
//   void _onSearchChanged(String v) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   List<Product> get _searchResults {
//     if (_q.isEmpty) return const [];
//     final base = _visibleProducts;
//     return base.where((p) {
//       final name = p.name.toLowerCase();
//       final cat = p.categoryName.toLowerCase();
//       return name.contains(_q) || cat.contains(_q);
//     }).toList();
//   }

//   // ===== UI parts =====

//   Widget _buildCategoryChip(_CategoryInfo c) {
//     return Padding(
//       // +2.0 px horizontal padding to avoid overlay crowding
//       padding: const EdgeInsets.symmetric(horizontal: 2.0),
//       child: GestureDetector(
//         onTap: () {
//           final products = _visibleProducts
//               .where((p) => p.category == c.id)
//               .toList();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => _CategoryProductsPage(
//                 categoryId: c.id,
//                 categoryName: c.name,
//                 products: products,
//                 imgUrlBuilder: _imgUrl,
//                 onAddToCart: _addToCart,
//                 onInc: _inc,
//                 onDec: _dec,
//                 getQtyVN: _vnFor,
//                 maxPerItem: _maxPerItem,
//               ),
//             ),
//           );
//         },
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: kPrimary, // was deepPurple
//               child: Icon(c.icon, color: Colors.white, size: 28),
//             ),
//             const SizedBox(height: 6),
//             // Long names: smaller font, tight height, ellipsis
//             ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 96),
//               child: Text(
//                 c.name,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: false,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   height: 1.1,
//                   letterSpacing: 0.2,
//                   color: kTextPrimary, // warm text color
//                 ),
//               ),
//             ),
//           ],
//         ),
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
//           color: kTextPrimary,
//         ),
//       ),
//     );
//   }

//   // product card (no stock badge). Only the qty row rebuilds via ValueListenableBuilder.
//   Widget _productCard(Product p) {
//     final img = _imgUrl(p);
//     final priceText = _priceText(p);
//     final vn = _vnFor(p);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.all(8),
//       clipBehavior: Clip.antiAlias,
//       child: Container(
//         width: 180,
//         padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Image
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: img == null
//                     ? Container(
//                         color: Colors.grey.shade200,
//                         child: const Center(
//                           child: Icon(
//                             Icons.image,
//                             color: Colors.grey,
//                             size: 44,
//                           ),
//                         ),
//                       )
//                     : Image.network(
//                         img,
//                         fit: BoxFit.cover,
//                         cacheWidth: 400,
//                         filterQuality: FilterQuality.low,
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return Container(
//                             color: Colors.grey.shade200,
//                             child: const Center(
//                               child: SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         errorBuilder: (_, __, ___) => Container(
//                           color: Colors.grey.shade200,
//                           child: const Center(
//                             child: Icon(
//                               Icons.broken_image_outlined,
//                               color: Colors.grey,
//                               size: 44,
//                             ),
//                           ),
//                         ),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Name
//             SizedBox(
//               height: 36,
//               child: Text(
//                 p.name,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: kTextPrimary,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Price pill (tap = add to cart)
//             GestureDetector(
//               onTap: () => _addToCart(p),
//               child: Container(
//                 height: 32,
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: kPrimarySoft, // soft peach
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: kPrimary.withOpacity(0.35)),
//                 ),
//                 child: Text(
//                   priceText,
//                   style: const TextStyle(
//                     color: kPrimary, // plum text
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Quantity row (fast updates)
//             ValueListenableBuilder<int>(
//               valueListenable: vn,
//               builder: (_, q, __) {
//                 final canInc =
//                     (p.stock > 0) && (q < p.stock) && (q < _maxPerItem(p));
//                 return SizedBox(
//                   height: 36,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _qtyButton(
//                         icon: Icons.remove,
//                         onTap: q > 0 ? () => _dec(p) : null,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: kBorder),
//                         ),
//                         child: Text(
//                           '$q',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: kTextPrimary,
//                           ),
//                         ),
//                       ),
//                       _qtyButton(
//                         icon: Icons.add,
//                         onTap: canInc ? () => _inc(p) : null,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // small rounded icon button for qty (uses palette + passed icon)
//   Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? Colors.grey.shade300 : kPrimary,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   // === BUILD ===
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_loading) return const Center(child: CircularProgressIndicator());

//     final results = _searchResults;
//     final showingSearch = _q.isNotEmpty;

//     return RefreshIndicator(
//       onRefresh: _loadProducts,
//       child: CustomScrollView(
//         slivers: [
//           // HERO HEADER
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [kBgTop, kBgBottom], // was orange → warm peach
//                   stops: [0.0, 0.3],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               padding: const EdgeInsets.only(
//                 top: 60,
//                 left: 20,
//                 right: 20,
//                 bottom: 24,
//               ),
//               child: Column(
//                 children: [
//                   // Menu + Search
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Builder(
//                         builder: (context) => IconButton(
//                           icon: const Icon(
//                             Icons.menu,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: () => Scaffold.of(context).openDrawer(),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 10),
//                           child: TextField(
//                             controller: _searchCtrl,
//                             onChanged: _onSearchChanged,
//                             decoration: InputDecoration(
//                               hintText: 'Search products',
//                               prefixIcon: const Icon(
//                                 Icons.search,
//                                 color: Colors.grey,
//                               ),
//                               suffixIcon: (_q.isNotEmpty)
//                                   ? IconButton(
//                                       icon: const Icon(
//                                         Icons.clear,
//                                         color: Colors.grey,
//                                       ),
//                                       onPressed: () {
//                                         _searchCtrl.clear();
//                                         _onSearchChanged('');
//                                       },
//                                     )
//                                   : const Icon(Icons.mic, color: Colors.grey),
//                               fillColor: Colors.white,
//                               filled: true,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 22),

//                   // Dynamic categories (horizontal) — increased height to avoid 2px overflow on long names
//                   SizedBox(
//                     height: 106, // was 96
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       itemBuilder: (_, i) => _buildCategoryChip(_categories[i]),
//                       separatorBuilder: (_, __) =>
//                           const SizedBox(width: 18), // +2px spacing
//                       itemCount: _categories.length,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Search results grid (only when typing)
//           if (showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Results (${results.length})'),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 0.62,
//                           ),
//                       itemCount: results.length,
//                       itemBuilder: (_, i) => _productCard(results[i]),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),

//           // ALL PRODUCTS grid (lazy-built) when not searching
//           if (!showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.62,
//                 ),
//                 delegate: SliverChildBuilderDelegate((context, index) {
//                   final p = _visibleProducts[index];
//                   return _productCard(p);
//                 }, childCount: _visibleProducts.length),
//               ),
//             ),

//           // Optional error banner (non-blocking if cache shown)
//           if (_error != null && _products.isNotEmpty)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: MaterialBanner(
//                   content: Text(
//                     'Couldn\'t refresh: $_error',
//                     style: const TextStyle(color: kTextPrimary),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: _loadProducts,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ===== Category page (opens when a category chip is tapped) =====

// class _CategoryProductsPage extends StatelessWidget {
//   final int categoryId;
//   final String categoryName;
//   final List<Product> products; // already filtered to stock > 5
//   final String? Function(Product) imgUrlBuilder;
//   final void Function(Product) onAddToCart;
//   final void Function(Product) onInc;
//   final void Function(Product) onDec;
//   final ValueNotifier<int> Function(Product) getQtyVN;
//   final int Function(Product) maxPerItem;

//   const _CategoryProductsPage({
//     required this.categoryId,
//     required this.categoryName,
//     required this.products,
//     required this.imgUrlBuilder,
//     required this.onAddToCart,
//     required this.onInc,
//     required this.onDec,
//     required this.getQtyVN,
//     required this.maxPerItem,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(categoryName)),
//       body: Column(
//         children: [
//           _CategorySearch(title: categoryName),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(12),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 0.62,
//               ),
//               itemCount: products.length,
//               itemBuilder: (_, i) {
//                 final p = products[i];
//                 final img = imgUrlBuilder(p);
//                 final priceText =
//                     '₹ ${double.tryParse('${p.price}')?.toStringAsFixed(2) ?? '${p.price}'}';
//                 final vn = getQtyVN(p);

//                 return Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: img == null
//                                 ? Container(
//                                     color: Colors.grey.shade200,
//                                     child: const Center(
//                                       child: Icon(
//                                         Icons.image,
//                                         color: Colors.grey,
//                                         size: 44,
//                                       ),
//                                     ),
//                                   )
//                                 : Image.network(
//                                     img,
//                                     fit: BoxFit.cover,
//                                     cacheWidth: 400,
//                                     filterQuality: FilterQuality.low,
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Container(
//                                         color: Colors.grey.shade200,
//                                         child: const Center(
//                                           child: SizedBox(
//                                             height: 22,
//                                             width: 22,
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 36,
//                           child: Text(
//                             p.name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: kTextPrimary,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => onAddToCart(p),
//                           child: Container(
//                             height: 32,
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             decoration: BoxDecoration(
//                               color: kPrimarySoft,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: kPrimary.withOpacity(0.35),
//                               ),
//                             ),
//                             child: Text(
//                               priceText,
//                               style: const TextStyle(
//                                 color: kPrimary,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ValueListenableBuilder<int>(
//                           valueListenable: vn,
//                           builder: (_, q, __) {
//                             final canInc =
//                                 (p.stock > 0) &&
//                                 (q < p.stock) &&
//                                 (q < maxPerItem(p));
//                             return SizedBox(
//                               height: 36,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _qtyBtn(
//                                     icon: Icons.remove,
//                                     onTap: q > 0 ? () => onDec(p) : null,
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade100,
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(color: kBorder),
//                                     ),
//                                     child: Text(
//                                       '$q',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14,
//                                         color: kTextPrimary,
//                                       ),
//                                     ),
//                                   ),
//                                   _qtyBtn(
//                                     icon: Icons.add,
//                                     onTap: canInc ? () => onInc(p) : null,
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? Colors.grey.shade300 : kPrimary,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// // small search on category page
// class _CategorySearch extends StatefulWidget {
//   final String title;
//   const _CategorySearch({required this.title});

//   @override
//   State<_CategorySearch> createState() => _CategorySearchState();
// }

// class _CategorySearchState extends State<_CategorySearch> {
//   String _q = '';
//   final _ctrl = TextEditingController();
//   Timer? _deb;

//   @override
//   void dispose() {
//     _deb?.cancel();
//     _ctrl.dispose();
//     super.dispose();
//   }

//   void _onChanged(String v) {
//     _deb?.cancel();
//     _deb = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       child: TextField(
//         controller: _ctrl,
//         onChanged: _onChanged,
//         decoration: InputDecoration(
//           hintText: 'Search "${widget.title}"',
//           prefixIcon: const Icon(Icons.search, color: kTextPrimary),
//           suffixIcon: (_q.isNotEmpty)
//               ? IconButton(
//                   icon: const Icon(Icons.clear, color: kTextPrimary),
//                   onPressed: () {
//                     _ctrl.clear();
//                     _onChanged('');
//                   },
//                 )
//               : null,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//           isDense: true,
//         ),
//       ),
//     );
//   }
// }

// // ===== internal types =====
// class _CategoryInfo {
//   final int id;
//   final String name;
//   final IconData icon;
//   _CategoryInfo({required this.id, required this.name, required this.icon});
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import 'package:fps/services/api_services.dart';
// import 'package:provider/provider.dart';
// import '../providers/provider.dart'; // <-- CartProvider
// import 'package:shared_preferences/shared_preferences.dart';
// import '../theme/palette.dart'; // <-- blue palette

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // products + quantities
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;

//   // product qty store (fast updates with ValueNotifier)
//   final Map<int, int> _qty = {}; // productId -> quantity
//   final Map<int, ValueNotifier<int>> _qtyVN = {}; // productId -> notifier
//   ValueNotifier<int> _vnFor(Product p) =>
//       _qtyVN.putIfAbsent(p.id, () => ValueNotifier(_qty[p.id] ?? 0));

//   // dynamic categories from backend data
//   late List<_CategoryInfo> _categories = [];

//   // search
//   final TextEditingController _searchCtrl = TextEditingController();
//   Timer? _searchDebounce;
//   String _q = '';

//   @override
//   void initState() {
//     super.initState();
//     _bootstrap();
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _bootstrap() async {
//     await _tryLoadFromCache(); // instant paint if cache exists
//     await _loadProducts(); // refresh from server
//   }

//   Future<void> _tryLoadFromCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString('products_cache');
//       if (raw == null || raw.isEmpty) return;
//       final List data = jsonDecode(raw) as List;
//       final cached = data
//           .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//       if (!mounted) return;
//       setState(() {
//         _products = cached;
//         _loading = false; // show cache immediately
//         _buildDynamicCategories();
//       });
//     } catch (_) {
//       // ignore cache errors
//     }
//   }

//   // Minimal serializer for Product -> Map (since Product has no toJson()).
//   Map<String, dynamic> _productToCache(Product p) => {
//     'id': p.id,
//     'name': p.name,
//     'stock': p.stock,
//     'price': p.price,
//     'category': p.category,
//     'category_name': p.categoryName,
//     'image': p.image,
//     'image_url': p.imageUrl,
//   };

//   Future<void> _saveCache(List<Product> items) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = jsonEncode(items.map(_productToCache).toList());
//       await prefs.setString('products_cache', raw);
//     } catch (_) {
//       /* ignore */
//     }
//   }

//   Future<void> _loadProducts() async {
//     try {
//       final items = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = items;
//         _loading = false;
//         _error = null;
//         _buildDynamicCategories();
//       });
//       // refresh cache (don’t await)
//       unawaited(_saveCache(items));
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _loading = _products.isEmpty; // keep showing cache if we have it
//       });
//     }
//   }

//   // ===== helpers =====

//   // Only show items with stock > 5
//   List<Product> get _visibleProducts =>
//       _products.where((p) => p.stock > 5).toList();

//   // absolute URL if backend returns relative paths
//   String? _imgUrl(Product p) {
//     final raw = p.imageUrl ?? p.image;
//     if (raw == null || raw.isEmpty) return null;
//     if (raw.startsWith('http')) return raw;
//     return raw.startsWith('/')
//         ? 'https://fps-dayalbagh-backend.vercel.app$raw'
//         : 'https://fps-dayalbagh-backend.vercel.app/$raw';
//   }

//   // price helpers
//   double _priceDouble(Product p) => double.tryParse('${p.price}') ?? 0.0;
//   String _priceText(Product p) => '₹ ${_priceDouble(p).toStringAsFixed(2)}';

//   bool _isDayalbagh(Product p) =>
//       p.categoryName.toUpperCase().contains('DAYALBAGH');
//   int _maxPerItem(Product p) => _isDayalbagh(p) ? 2 : 999999;

//   // CART helpers (fast: update notifier, not whole grid)
//   void _setQty(Product p, int newVal) {
//     _qty[p.id] = newVal;
//     _vnFor(p).value = newVal; // only qty row rebuilds
//   }

//   void _cartAdd(Product p, int qty) {
//     final id = p.id.toString(); // provider expects String id
//     final title = p.name;
//     final price = _priceDouble(p);
//     context.read<CartProvider>().add(
//       id: id,
//       title: title,
//       price: price,
//       qty: qty,
//     );
//   }

//   void _inc(Product p) {
//     if (p.stock <= 0) return;
//     final max = _maxPerItem(p);
//     final current = _qty[p.id] ?? 0;
//     if (current >= p.stock) return;
//     if (current >= max) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _setQty(p, current + 1);
//     _cartAdd(p, 1);
//   }

//   void _dec(Product p) {
//     final current = _qty[p.id] ?? 0;
//     if (current <= 0) return;
//     _setQty(p, current - 1);
//     context.read<CartProvider>().removeOne(p.id.toString());
//   }

//   void _addToCart(Product p) {
//     final current = _qty[p.id] ?? 0;
//     final requested = current > 0 ? current : 1;
//     final max = _maxPerItem(p);
//     final canAdd = (max - current).clamp(0, requested);
//     if (canAdd <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _cartAdd(p, canAdd);
//     _setQty(p, current + canAdd);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Added $canAdd × "${p.name}"')));
//   }

//   // dynamic categories from VISIBLE products
//   void _buildDynamicCategories() {
//     final Map<int, _CategoryInfo> m = {};
//     for (final p in _visibleProducts) {
//       final id = p.category;
//       final name = (p.categoryName.isNotEmpty) ? p.categoryName : 'Other';
//       m.putIfAbsent(
//         id,
//         () => _CategoryInfo(id: id, name: name, icon: _iconForCategory(name)),
//       );
//     }
//     final list = m.values.toList()..sort((a, b) => a.name.compareTo(b.name));
//     _categories = list;
//   }

//   IconData _iconForCategory(String name) {
//     final n = name.toLowerCase();
//     if (n.contains('grocery') || n.contains('grocer')) return Icons.scale;
//     if (n.contains('dairy')) return Icons.local_drink;
//     if (n.contains('electrical')) return Icons.lightbulb_outline;
//     if (n.contains('electronic')) return Icons.tv;
//     if (n.contains('furniture')) return Icons.chair;
//     if (n.contains('utensil') || n.contains('kitchen')) return Icons.kitchen;
//     if (n.contains('home')) return Icons.home_outlined;
//     if (n.contains('personal') || n.contains('care')) return Icons.spa_outlined;
//     if (n.contains('beverage') || n.contains('drink')) {
//       return Icons.local_cafe_outlined;
//     }
//     return Icons.inventory_2_outlined;
//   }

//   // search control (debounced) — searches visible products only
//   void _onSearchChanged(String v) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   List<Product> get _searchResults {
//     if (_q.isEmpty) return const [];
//     final base = _visibleProducts;
//     return base.where((p) {
//       final name = p.name.toLowerCase();
//       final cat = p.categoryName.toLowerCase();
//       return name.contains(_q) || cat.contains(_q);
//     }).toList();
//   }

//   // ===== UI parts =====

//   Widget _buildCategoryChip(_CategoryInfo c) {
//     return Padding(
//       // +2.0 px horizontal padding to avoid overlay crowding
//       padding: const EdgeInsets.symmetric(horizontal: 2.0),
//       child: GestureDetector(
//         onTap: () {
//           final products = _visibleProducts
//               .where((p) => p.category == c.id)
//               .toList();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => _CategoryProductsPage(
//                 categoryId: c.id,
//                 categoryName: c.name,
//                 products: products,
//                 imgUrlBuilder: _imgUrl,
//                 onAddToCart: _addToCart,
//                 onInc: _inc,
//                 onDec: _dec,
//                 getQtyVN: _vnFor,
//                 maxPerItem: _maxPerItem,
//               ),
//             ),
//           );
//         },
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: kPrimary, // palette
//               child: Icon(c.icon, color: Colors.white, size: 28),
//             ),
//             const SizedBox(height: 6),
//             // Long names: smaller font, tight height, ellipsis
//             ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 96),
//               child: const Text(
//                 '', // placeholder replaced below using RichText to avoid non-const style
//               ),
//             ),
//             // Use RichText to keep non-const style cleanly
//             ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 96),
//               child: Text(
//                 c.name,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: false,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   height: 1.1,
//                   letterSpacing: 0.2,
//                   color: kTextPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
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
//           color: kTextPrimary,
//         ),
//       ),
//     );
//   }

//   // product card (no stock badge). Only the qty row rebuilds via ValueListenableBuilder.
//   Widget _productCard(Product p) {
//     final img = _imgUrl(p);
//     final priceText = _priceText(p);
//     final vn = _vnFor(p);

//     return Card(
//       color: kCard, // palette card bg
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.all(8),
//       clipBehavior: Clip.antiAlias,
//       child: Container(
//         width: 180,
//         padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Image
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: img == null
//                     ? Container(
//                         color: kCard,
//                         child: const Center(
//                           child: Icon(
//                             Icons.image,
//                             color: kTextPrimary,
//                             size: 44,
//                           ),
//                         ),
//                       )
//                     : Image.network(
//                         img,
//                         fit: BoxFit.cover,
//                         cacheWidth: 400,
//                         filterQuality: FilterQuality.low,
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return Container(
//                             color: kCard,
//                             child: const Center(
//                               child: SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         errorBuilder: (_, __, ___) => Container(
//                           color: kCard,
//                           child: const Center(
//                             child: Icon(
//                               Icons.broken_image_outlined,
//                               color: kTextPrimary,
//                               size: 44,
//                             ),
//                           ),
//                         ),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Name
//             SizedBox(
//               height: 36,
//               child: Text(
//                 p.name,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: kTextPrimary,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Price pill (tap = add to cart)
//             GestureDetector(
//               onTap: () => _addToCart(p),
//               child: Container(
//                 height: 32,
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: kPrimarySoft,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: kPrimary.withOpacity(0.35)),
//                 ),
//                 child: Text(
//                   priceText,
//                   style: const TextStyle(
//                     color: kPrimary,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Quantity row (fast updates)
//             ValueListenableBuilder<int>(
//               valueListenable: vn,
//               builder: (_, q, __) {
//                 final canInc =
//                     (p.stock > 0) && (q < p.stock) && (q < _maxPerItem(p));
//                 return SizedBox(
//                   height: 36,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _qtyButton(
//                         icon: Icons.remove,
//                         onTap: q > 0 ? () => _dec(p) : null,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: kBgBottom,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: kBorder),
//                         ),
//                         child: const Text(
//                           '0', // replaced below by non-const Text
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: kTextPrimary,
//                           ),
//                         ),
//                       ),
//                       _qtyButton(
//                         icon: Icons.add,
//                         onTap: canInc ? () => _inc(p) : null,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // small rounded icon button for qty (uses palette + passed icon)
//   Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? kBorder : kPrimary,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   // === BUILD ===
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_loading) return const Center(child: CircularProgressIndicator());

//     final results = _searchResults;
//     final showingSearch = _q.isNotEmpty;

//     return RefreshIndicator(
//       onRefresh: _loadProducts,
//       child: CustomScrollView(
//         slivers: [
//           // HERO HEADER
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [kBgTop, kBgBottom],
//                   stops: [0.0, 0.3],
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               padding: const EdgeInsets.only(
//                 top: 60,
//                 left: 20,
//                 right: 20,
//                 bottom: 24,
//               ),
//               child: Column(
//                 children: [
//                   // Menu + Search
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Builder(
//                         builder: (context) => IconButton(
//                           icon: const Icon(
//                             Icons.menu,
//                             color: kTextPrimary,
//                             size: 28,
//                           ),
//                           onPressed: () => Scaffold.of(context).openDrawer(),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 10),
//                           child: TextField(
//                             controller: _searchCtrl,
//                             onChanged: _onSearchChanged,
//                             decoration: InputDecoration(
//                               hintText: 'Search products',
//                               hintStyle: TextStyle(
//                                 color: kTextPrimary.withOpacity(0.55),
//                               ),
//                               prefixIcon: const Icon(
//                                 Icons.search,
//                                 color: kTextPrimary,
//                               ),
//                               suffixIcon: (_q.isNotEmpty)
//                                   ? IconButton(
//                                       icon: Icon(
//                                         Icons.clear,
//                                         color: kTextPrimary.withOpacity(0.6),
//                                       ),
//                                       onPressed: () {
//                                         _searchCtrl.clear();
//                                         _onSearchChanged('');
//                                       },
//                                     )
//                                   : const Icon(Icons.mic, color: kTextPrimary),
//                               fillColor: Colors.white, // keeps contrast
//                               filled: true,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 22),

//                   // Dynamic categories (horizontal)
//                   SizedBox(
//                     height: 106,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       itemBuilder: (_, i) => _buildCategoryChip(_categories[i]),
//                       separatorBuilder: (_, __) => const SizedBox(width: 18),
//                       itemCount: _categories.length,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Search results grid (only when typing)
//           if (showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Results (${results.length})'),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 0.62,
//                           ),
//                       itemCount: results.length,
//                       itemBuilder: (_, i) => _productCard(results[i]),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),

//           // ALL PRODUCTS grid (lazy-built) when not searching
//           if (!showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.62,
//                 ),
//                 delegate: SliverChildBuilderDelegate((context, index) {
//                   final p = _visibleProducts[index];
//                   return _productCard(p);
//                 }, childCount: _visibleProducts.length),
//               ),
//             ),

//           // Optional error banner (non-blocking if cache shown)
//           if (_error != null && _products.isNotEmpty)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: MaterialBanner(
//                   backgroundColor: kCard,
//                   content: Text(
//                     'Couldn\'t refresh: $_error',
//                     style: const TextStyle(color: kTextPrimary),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: _loadProducts,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ===== Category page (opens when a category chip is tapped) =====

// class _CategoryProductsPage extends StatelessWidget {
//   final int categoryId;
//   final String categoryName;
//   final List<Product> products; // already filtered to stock > 5
//   final String? Function(Product) imgUrlBuilder;
//   final void Function(Product) onAddToCart;
//   final void Function(Product) onInc;
//   final void Function(Product) onDec;
//   final ValueNotifier<int> Function(Product) getQtyVN;
//   final int Function(Product) maxPerItem;

//   const _CategoryProductsPage({
//     required this.categoryId,
//     required this.categoryName,
//     required this.products,
//     required this.imgUrlBuilder,
//     required this.onAddToCart,
//     required this.onInc,
//     required this.onDec,
//     required this.getQtyVN,
//     required this.maxPerItem,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(categoryName)),
//       body: Column(
//         children: [
//           _CategorySearch(title: categoryName),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(12),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 0.62,
//               ),
//               itemCount: products.length,
//               itemBuilder: (_, i) {
//                 final p = products[i];
//                 final img = imgUrlBuilder(p);
//                 final priceText =
//                     '₹ ${double.tryParse('${p.price}')?.toStringAsFixed(2) ?? '${p.price}'}';
//                 final vn = getQtyVN(p);

//                 return Card(
//                   color: kCard, // palette card bg
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: img == null
//                                 ? Container(
//                                     color: kCard,
//                                     child: const Center(
//                                       child: Icon(
//                                         Icons.image,
//                                         color: kTextPrimary,
//                                         size: 44,
//                                       ),
//                                     ),
//                                   )
//                                 : Image.network(
//                                     img,
//                                     fit: BoxFit.cover,
//                                     cacheWidth: 400,
//                                     filterQuality: FilterQuality.low,
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Container(
//                                         color: kCard,
//                                         child: const Center(
//                                           child: SizedBox(
//                                             height: 22,
//                                             width: 22,
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 36,
//                           child: Text(
//                             p.name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: kTextPrimary,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => onAddToCart(p),
//                           child: Container(
//                             height: 32,
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             decoration: BoxDecoration(
//                               color: kPrimarySoft,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: kPrimary.withOpacity(0.35),
//                               ),
//                             ),
//                             child: Text(
//                               priceText,
//                               style: const TextStyle(
//                                 color: kPrimary,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ValueListenableBuilder<int>(
//                           valueListenable: vn,
//                           builder: (_, q, __) {
//                             final canInc =
//                                 (p.stock > 0) &&
//                                 (q < p.stock) &&
//                                 (q < maxPerItem(p));
//                             return SizedBox(
//                               height: 36,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _qtyBtn(
//                                     icon: Icons.remove,
//                                     onTap: q > 0 ? () => onDec(p) : null,
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: kBgBottom,
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(color: kBorder),
//                                     ),
//                                     child: Text(
//                                       '$q',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14,
//                                         color: kTextPrimary,
//                                       ),
//                                     ),
//                                   ),
//                                   _qtyBtn(
//                                     icon: Icons.add,
//                                     onTap: canInc ? () => onInc(p) : null,
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? kBorder : kPrimary,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// // small search on category page
// class _CategorySearch extends StatefulWidget {
//   final String title;
//   const _CategorySearch({required this.title});

//   @override
//   State<_CategorySearch> createState() => _CategorySearchState();
// }

// class _CategorySearchState extends State<_CategorySearch> {
//   String _q = '';
//   final _ctrl = TextEditingController();
//   Timer? _deb;

//   @override
//   void dispose() {
//     _deb?.cancel();
//     _ctrl.dispose();
//     super.dispose();
//   }

//   void _onChanged(String v) {
//     _deb?.cancel();
//     _deb = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       child: TextField(
//         controller: _ctrl,
//         onChanged: _onChanged,
//         decoration: InputDecoration(
//           hintText: 'Search "${widget.title}"',
//           hintStyle: TextStyle(color: kTextPrimary.withOpacity(0.55)),
//           prefixIcon: const Icon(Icons.search, color: kTextPrimary),
//           suffixIcon: (_q.isNotEmpty)
//               ? IconButton(
//                   icon: Icon(Icons.clear, color: kTextPrimary.withOpacity(0.6)),
//                   onPressed: () {
//                     _ctrl.clear();
//                     _onChanged('');
//                   },
//                 )
//               : null,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//           isDense: true,
//         ),
//       ),
//     );
//   }
// }

// // ===== internal types =====
// class _CategoryInfo {
//   final int id;
//   final String name;
//   final IconData icon;
//   _CategoryInfo({required this.id, required this.name, required this.icon});
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import 'package:fps/services/api_services.dart';
// import 'package:provider/provider.dart';
// import '../providers/provider.dart'; // <-- CartProvider
// import 'package:shared_preferences/shared_preferences.dart';
// import '../theme/palette.dart'; // <-- runtime palette

// class HomeContent extends StatefulWidget {
//   const HomeContent({super.key});

//   @override
//   State<HomeContent> createState() => _HomeContentState();
// }

// class _HomeContentState extends State<HomeContent>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   // products + quantities
//   List<Product> _products = [];
//   bool _loading = true;
//   String? _error;

//   // product qty store (fast updates with ValueNotifier)
//   final Map<int, int> _qty = {}; // productId -> quantity
//   final Map<int, ValueNotifier<int>> _qtyVN = {}; // productId -> notifier
//   ValueNotifier<int> _vnFor(Product p) =>
//       _qtyVN.putIfAbsent(p.id, () => ValueNotifier(_qty[p.id] ?? 0));

//   // dynamic categories from backend data
//   late List<_CategoryInfo> _categories = [];

//   // search
//   final TextEditingController _searchCtrl = TextEditingController();
//   Timer? _searchDebounce;
//   String _q = '';

//   @override
//   void initState() {
//     super.initState();
//     _bootstrap();
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _bootstrap() async {
//     await _tryLoadFromCache(); // instant paint if cache exists
//     await _loadProducts(); // refresh from server
//   }

//   Future<void> _tryLoadFromCache() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString('products_cache');
//       if (raw == null || raw.isEmpty) return;
//       final List data = jsonDecode(raw) as List;
//       final cached = data
//           .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//       if (!mounted) return;
//       setState(() {
//         _products = cached;
//         _loading = false; // show cache immediately
//         _buildDynamicCategories();
//       });
//     } catch (_) {
//       // ignore cache errors
//     }
//   }

//   // Minimal serializer for Product -> Map (since Product has no toJson()).
//   Map<String, dynamic> _productToCache(Product p) => {
//     'id': p.id,
//     'name': p.name,
//     'stock': p.stock,
//     'price': p.price,
//     'category': p.category,
//     'category_name': p.categoryName,
//     'image': p.image,
//     'image_url': p.imageUrl,
//   };

//   Future<void> _saveCache(List<Product> items) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = jsonEncode(items.map(_productToCache).toList());
//       await prefs.setString('products_cache', raw);
//     } catch (_) {
//       /* ignore */
//     }
//   }

//   Future<void> _loadProducts() async {
//     try {
//       final items = await ApiService.getProducts();
//       if (!mounted) return;
//       setState(() {
//         _products = items;
//         _loading = false;
//         _error = null;
//         _buildDynamicCategories();
//       });
//       // refresh cache (don’t await)
//       // ignore: unawaited_futures
//       _saveCache(items);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _error = e.toString();
//         _loading = _products.isEmpty; // keep showing cache if we have it
//       });
//     }
//   }

//   // ===== helpers =====

//   // Only show items with stock > 5
//   List<Product> get _visibleProducts =>
//       _products.where((p) => p.stock > 5).toList();

//   // absolute URL if backend returns relative paths
//   String? _imgUrl(Product p) {
//     final raw = p.imageUrl ?? p.image;
//     if (raw == null || raw.isEmpty) return null;
//     if (raw.startsWith('http')) return raw;
//     return raw.startsWith('/')
//         ? 'https://fps-dayalbagh-backend.vercel.app$raw'
//         : 'https://fps-dayalbagh-backend.vercel.app/$raw';
//   }

//   // price helpers
//   double _priceDouble(Product p) => double.tryParse('${p.price}') ?? 0.0;
//   String _priceText(Product p) => '₹ ${_priceDouble(p).toStringAsFixed(2)}';

//   bool _isDayalbagh(Product p) =>
//       p.categoryName.toUpperCase().contains('DAYALBAGH');
//   int _maxPerItem(Product p) => _isDayalbagh(p) ? 2 : 999999;

//   // CART helpers (fast: update notifier, not whole grid)
//   void _setQty(Product p, int newVal) {
//     _qty[p.id] = newVal;
//     _vnFor(p).value = newVal; // only qty row rebuilds
//   }

//   void _cartAdd(Product p, int qty) {
//     final id = p.id; // provider expects String id
//     final title = p.name;
//     final price = _priceDouble(p);
//     context.read<CartProvider>().add(
//       id: id,
//       title: title,
//       price: price,
//       qty: qty,
//     );
//   }

//   void _inc(Product p) {
//     if (p.stock <= 0) return;
//     final max = _maxPerItem(p);
//     final current = _qty[p.id] ?? 0;
//     if (current >= p.stock) return;
//     if (current >= max) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _setQty(p, current + 1);
//     _cartAdd(p, 1);
//   }

//   void _dec(Product p) {
//     final current = _qty[p.id] ?? 0;
//     if (current <= 0) return;
//     _setQty(p, current - 1);
//     context.read<CartProvider>().removeOne(p.id);
//   }

//   void _addToCart(Product p) {
//     final current = _qty[p.id] ?? 0;
//     final requested = current > 0 ? current : 1;
//     final max = _maxPerItem(p);
//     final canAdd = (max - current).clamp(0, requested);
//     if (canAdd <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
//       );
//       return;
//     }
//     _cartAdd(p, canAdd);
//     _setQty(p, current + canAdd);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Added $canAdd × "${p.name}"')));
//   }

//   // dynamic categories from VISIBLE products
//   void _buildDynamicCategories() {
//     final Map<int, _CategoryInfo> m = {};
//     for (final p in _visibleProducts) {
//       final id = p.category;
//       final name = (p.categoryName.isNotEmpty) ? p.categoryName : 'Other';
//       m.putIfAbsent(
//         id,
//         () => _CategoryInfo(id: id, name: name, icon: _iconForCategory(name)),
//       );
//     }
//     final list = m.values.toList()..sort((a, b) => a.name.compareTo(b.name));
//     _categories = list;
//   }

//   IconData _iconForCategory(String name) {
//     final n = name.toLowerCase();
//     if (n.contains('grocery') || n.contains('grocer')) return Icons.scale;
//     if (n.contains('dairy')) return Icons.local_drink;
//     if (n.contains('electrical')) return Icons.lightbulb_outline;
//     if (n.contains('electronic')) return Icons.tv;
//     if (n.contains('furniture')) return Icons.chair;
//     if (n.contains('utensil') || n.contains('kitchen')) return Icons.kitchen;
//     if (n.contains('home')) return Icons.home_outlined;
//     if (n.contains('personal') || n.contains('care')) return Icons.spa_outlined;
//     if (n.contains('beverage') || n.contains('drink')) {
//       return Icons.local_cafe_outlined;
//     }
//     return Icons.inventory_2_outlined;
//   }

//   // search control (debounced) — searches visible products only
//   void _onSearchChanged(String v) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   List<Product> get _searchResults {
//     if (_q.isEmpty) return const [];
//     final base = _visibleProducts;
//     return base.where((p) {
//       final name = p.name.toLowerCase();
//       final cat = p.categoryName.toLowerCase();
//       return name.contains(_q) || cat.contains(_q);
//     }).toList();
//   }

//   // ===== UI parts =====

//   Widget _buildCategoryChip(_CategoryInfo c) {
//     return Padding(
//       // +2.0 px horizontal padding to avoid overlay crowding
//       padding: const EdgeInsets.symmetric(horizontal: 2.0),
//       child: GestureDetector(
//         onTap: () {
//           final products = _visibleProducts
//               .where((p) => p.category == c.id)
//               .toList();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => _CategoryProductsPage(
//                 categoryId: c.id,
//                 categoryName: c.name,
//                 products: products,
//                 imgUrlBuilder: _imgUrl,
//                 onAddToCart: _addToCart,
//                 onInc: _inc,
//                 onDec: _dec,
//                 getQtyVN: _vnFor,
//                 maxPerItem: _maxPerItem,
//               ),
//             ),
//           );
//         },
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: kPrimary, // palette
//               child: Icon(c.icon, color: Colors.white, size: 28),
//             ),
//             const SizedBox(height: 6),
//             // Long names: smaller font, tight height, ellipsis
//             ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 96),
//               child: Text(
//                 c.name,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: false,
//                 style: TextStyle(
//                   fontSize: 10,
//                   height: 1.1,
//                   letterSpacing: 0.2,
//                   color: kTextPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: kTextPrimary,
//         ),
//       ),
//     );
//   }

//   // product card (no stock badge). Only the qty row rebuilds via ValueListenableBuilder.
//   Widget _productCard(Product p) {
//     final img = _imgUrl(p);
//     final priceText = _priceText(p);
//     final vn = _vnFor(p);

//     return Card(
//       color: kCard, // palette card bg
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.all(8),
//       clipBehavior: Clip.antiAlias,
//       child: Container(
//         width: 180,
//         padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Image
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: img == null
//                     ? Container(
//                         color: kCard,
//                         child: Center(
//                           child: Icon(
//                             Icons.image,
//                             color: kTextPrimary,
//                             size: 44,
//                           ),
//                         ),
//                       )
//                     : Image.network(
//                         img,
//                         fit: BoxFit.cover,
//                         cacheWidth: 400,
//                         filterQuality: FilterQuality.low,
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return Container(
//                             color: kCard,
//                             child: const Center(
//                               child: SizedBox(
//                                 height: 22,
//                                 width: 22,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         errorBuilder: (_, __, ___) => Container(
//                           color: kCard,
//                           child: Center(
//                             child: Icon(
//                               Icons.broken_image_outlined,
//                               color: kTextPrimary,
//                               size: 44,
//                             ),
//                           ),
//                         ),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Name
//             SizedBox(
//               height: 36,
//               child: Text(
//                 p.name,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   color: kTextPrimary,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Price pill (tap = add to cart)
//             GestureDetector(
//               onTap: () => _addToCart(p),
//               child: Container(
//                 height: 32,
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: kPrimarySoft,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: kPrimary.withOpacity(0.35)),
//                 ),
//                 child: Text(
//                   priceText,
//                   style: TextStyle(
//                     color: kPrimary,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // Quantity row (fast updates)
//             ValueListenableBuilder<int>(
//               valueListenable: vn,
//               builder: (_, q, __) {
//                 final canInc =
//                     (p.stock > 0) && (q < p.stock) && (q < _maxPerItem(p));
//                 return SizedBox(
//                   height: 36,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _qtyButton(
//                         icon: Icons.remove,
//                         onTap: q > 0 ? () => _dec(p) : null,
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: kBgBottom,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: kBorder),
//                         ),
//                         child: Text(
//                           '$q',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                             color: kTextPrimary,
//                           ),
//                         ),
//                       ),
//                       _qtyButton(
//                         icon: Icons.add,
//                         onTap: canInc ? () => _inc(p) : null,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // small rounded icon button for qty (uses palette + passed icon)
//   Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? kBorder : kPrimary,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   // === BUILD ===
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     if (_loading) return const Center(child: CircularProgressIndicator());

//     final results = _searchResults;
//     final showingSearch = _q.isNotEmpty;

//     return RefreshIndicator(
//       onRefresh: _loadProducts,
//       child: CustomScrollView(
//         slivers: [
//           // HERO HEADER
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [kBgTop, kBgBottom],
//                   stops: const [0.0, 0.3],
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               padding: const EdgeInsets.only(
//                 top: 60,
//                 left: 20,
//                 right: 20,
//                 bottom: 24,
//               ),
//               child: Column(
//                 children: [
//                   // Menu + Search
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Builder(
//                         builder: (context) => IconButton(
//                           icon: Icon(Icons.menu, color: kTextPrimary, size: 28),
//                           onPressed: () => Scaffold.of(context).openDrawer(),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 10),
//                           child: TextField(
//                             controller: _searchCtrl,
//                             onChanged: _onSearchChanged,
//                             decoration: InputDecoration(
//                               hintText: 'Search products',
//                               hintStyle: TextStyle(
//                                 color: kTextPrimary.withOpacity(0.55),
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.search,
//                                 color: kTextPrimary,
//                               ),
//                               suffixIcon: (_q.isNotEmpty)
//                                   ? IconButton(
//                                       icon: Icon(
//                                         Icons.clear,
//                                         color: kTextPrimary.withOpacity(0.6),
//                                       ),
//                                       onPressed: () {
//                                         _searchCtrl.clear();
//                                         _onSearchChanged('');
//                                       },
//                                     )
//                                   : Icon(Icons.mic, color: kTextPrimary),
//                               fillColor: Colors.white, // keeps contrast
//                               filled: true,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 22),

//                   // Dynamic categories (horizontal)
//                   SizedBox(
//                     height: 106,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       itemBuilder: (_, i) => _buildCategoryChip(_categories[i]),
//                       separatorBuilder: (_, __) => const SizedBox(width: 18),
//                       itemCount: _categories.length,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Search results grid (only when typing)
//           if (showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Results (${results.length})'),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 0.62,
//                           ),
//                       itemCount: results.length,
//                       itemBuilder: (_, i) => _productCard(results[i]),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),

//           // ALL PRODUCTS grid (lazy-built) when not searching
//           if (!showingSearch)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.62,
//                 ),
//                 delegate: SliverChildBuilderDelegate((context, index) {
//                   final p = _visibleProducts[index];
//                   return _productCard(p);
//                 }, childCount: _visibleProducts.length),
//               ),
//             ),

//           // Optional error banner (non-blocking if cache shown)
//           if (_error != null && _products.isNotEmpty)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: MaterialBanner(
//                   backgroundColor: kCard,
//                   content: Text(
//                     'Couldn\'t refresh: $_error',
//                     style: TextStyle(color: kTextPrimary),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: _loadProducts,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ===== Category page (opens when a category chip is tapped) =====

// class _CategoryProductsPage extends StatelessWidget {
//   final int categoryId;
//   final String categoryName;
//   final List<Product> products; // already filtered to stock > 5
//   final String? Function(Product) imgUrlBuilder;
//   final void Function(Product) onAddToCart;
//   final void Function(Product) onInc;
//   final void Function(Product) onDec;
//   final ValueNotifier<int> Function(Product) getQtyVN;
//   final int Function(Product) maxPerItem;

//   const _CategoryProductsPage({
//     required this.categoryId,
//     required this.categoryName,
//     required this.products,
//     required this.imgUrlBuilder,
//     required this.onAddToCart,
//     required this.onInc,
//     required this.onDec,
//     required this.getQtyVN,
//     required this.maxPerItem,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(categoryName)),
//       body: Column(
//         children: [
//           _CategorySearch(title: categoryName),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(12),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 childAspectRatio: 0.62,
//               ),
//               itemCount: products.length,
//               itemBuilder: (_, i) {
//                 final p = products[i];
//                 final img = imgUrlBuilder(p);
//                 final priceText =
//                     '₹ ${double.tryParse('${p.price}')?.toStringAsFixed(2) ?? '${p.price}'}';
//                 final vn = getQtyVN(p);

//                 return Card(
//                   color: kCard, // palette card bg
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: img == null
//                                 ? Container(
//                                     color: kCard,
//                                     child: Center(
//                                       child: Icon(
//                                         Icons.image,
//                                         color: kTextPrimary,
//                                         size: 44,
//                                       ),
//                                     ),
//                                   )
//                                 : Image.network(
//                                     img,
//                                     fit: BoxFit.cover,
//                                     cacheWidth: 400,
//                                     filterQuality: FilterQuality.low,
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Container(
//                                         color: kCard,
//                                         child: const Center(
//                                           child: SizedBox(
//                                             height: 22,
//                                             width: 22,
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           height: 36,
//                           child: Text(
//                             p.name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: kTextPrimary,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         GestureDetector(
//                           onTap: () => onAddToCart(p),
//                           child: Container(
//                             height: 32,
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             decoration: BoxDecoration(
//                               color: kPrimarySoft,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: kPrimary.withOpacity(0.35),
//                               ),
//                             ),
//                             child: Text(
//                               priceText,
//                               style: TextStyle(
//                                 color: kPrimary,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ValueListenableBuilder<int>(
//                           valueListenable: vn,
//                           builder: (_, q, __) {
//                             final canInc =
//                                 (p.stock > 0) &&
//                                 (q < p.stock) &&
//                                 (q < maxPerItem(p));
//                             return SizedBox(
//                               height: 36,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _qtyBtn(
//                                     icon: Icons.remove,
//                                     onTap: q > 0 ? () => onDec(p) : null,
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: kBgBottom,
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(color: kBorder),
//                                     ),
//                                     child: Text(
//                                       '$q',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14,
//                                         color: kTextPrimary,
//                                       ),
//                                     ),
//                                   ),
//                                   _qtyBtn(
//                                     icon: Icons.add,
//                                     onTap: canInc ? () => onInc(p) : null,
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
//     return Material(
//       color: onTap == null ? kBorder : kPrimary,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icon, size: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// // small search on category page
// class _CategorySearch extends StatefulWidget {
//   final String title;
//   const _CategorySearch({required this.title});

//   @override
//   State<_CategorySearch> createState() => _CategorySearchState();
// }

// class _CategorySearchState extends State<_CategorySearch> {
//   String _q = '';
//   final _ctrl = TextEditingController();
//   Timer? _deb;

//   @override
//   void dispose() {
//     _deb?.cancel();
//     _ctrl.dispose();
//     super.dispose();
//   }

//   void _onChanged(String v) {
//     _deb?.cancel();
//     _deb = Timer(const Duration(milliseconds: 250), () {
//       if (!mounted) return;
//       setState(() => _q = v.trim().toLowerCase());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       child: TextField(
//         controller: _ctrl,
//         onChanged: _onChanged,
//         decoration: InputDecoration(
//           hintText: 'Search "${widget.title}"',
//           hintStyle: TextStyle(color: kTextPrimary.withOpacity(0.55)),
//           prefixIcon: Icon(Icons.search, color: kTextPrimary),
//           suffixIcon: (_q.isNotEmpty)
//               ? IconButton(
//                   icon: Icon(Icons.clear, color: kTextPrimary.withOpacity(0.6)),
//                   onPressed: () {
//                     _ctrl.clear();
//                     _onChanged('');
//                   },
//                 )
//               : null,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
//           isDense: true,
//         ),
//       ),
//     );
//   }
// }

// // ===== internal types =====
// class _CategoryInfo {
//   final int id;
//   final String name;
//   final IconData icon;
//   _CategoryInfo({required this.id, required this.name, required this.icon});
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:fps/services/api_services.dart';
import 'package:provider/provider.dart';
import '../providers/provider.dart'; // CartProvider
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/palette.dart'; // runtime palette

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // products + quantities
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  // product qty store (fast updates with ValueNotifier)
  final Map<int, int> _qty = {}; // productId -> quantity
  final Map<int, ValueNotifier<int>> _qtyVN = {}; // productId -> notifier
  ValueNotifier<int> _vnFor(Product p) =>
      _qtyVN.putIfAbsent(p.id, () => ValueNotifier(_qty[p.id] ?? 0));

  // dynamic categories from backend data
  late List<_CategoryInfo> _categories = [];

  // search
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _tryLoadFromCache(); // instant paint if cache exists
    await _loadProducts(); // refresh from server
  }

  Future<void> _tryLoadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('products_cache');
      if (raw == null || raw.isEmpty) return;
      final List data = jsonDecode(raw) as List;
      final cached = data
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (!mounted) return;
      setState(() {
        _products = cached;
        _loading = false; // show cache immediately
        _buildDynamicCategories();
      });
    } catch (_) {
      // ignore cache errors
    }
  }

  // Minimal serializer for Product -> Map (since Product has no toJson()).
  Map<String, dynamic> _productToCache(Product p) => {
    'id': p.id,
    'name': p.name,
    'stock': p.stock,
    'price': p.price,
    'category': p.category,
    'category_name': p.categoryName,
    'image': p.image,
    'image_url': p.imageUrl,
  };

  Future<void> _saveCache(List<Product> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map(_productToCache).toList());
      await prefs.setString('products_cache', raw);
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> _loadProducts() async {
    try {
      final items = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = items;
        _loading = false;
        _error = null;
        _buildDynamicCategories();
      });
      // refresh cache (don’t await)
      // ignore: unawaited_futures
      _saveCache(items);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = _products.isEmpty; // keep showing cache if we have it
      });
    }
  }

  // ===== helpers =====

  // Only show items with stock > 5
  List<Product> get _visibleProducts =>
      _products.where((p) => p.stock > 5).toList();

  // absolute URL if backend returns relative paths
  String? _imgUrl(Product p) {
    final raw = p.imageUrl ?? p.image;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return raw.startsWith('/')
        ? 'https://fps-dayalbagh-backend.vercel.app$raw'
        : 'https://fps-dayalbagh-backend.vercel.app/$raw';
  }

  // color alpha helper (avoid withOpacity deprecation warnings)
  Color _alpha(Color c, double o) => c.withAlpha((o * 255).round());

  // price helpers
  double _priceDouble(Product p) => p.price is num
      ? (p.price as num).toDouble()
      : double.tryParse('${p.price}') ?? 0.0;
  String _priceText(Product p) => '₹ ${_priceDouble(p).toStringAsFixed(2)}';

  bool _isDayalbagh(Product p) =>
      p.categoryName.toUpperCase().contains('DAYALBAGH');
  int _maxPerItem(Product p) => _isDayalbagh(p) ? 2 : 999999;

  // CART helpers (fast: update notifier, not whole grid)
  void _setQty(Product p, int newVal) {
    _qty[p.id] = newVal;
    _vnFor(p).value = newVal; // only qty row rebuilds
  }

  void _cartAdd(Product p, int qty) {
    final idKey = p.id.toString(); // keep provider key consistent (String)
    final title = p.name;
    final price = _priceDouble(p);
    context.read<CartProvider>().add(
      id: idKey,
      title: title,
      price: price,
      qty: qty,
    );
  }

  void _inc(Product p) {
    if (p.stock <= 0) return;
    final max = _maxPerItem(p);
    final current = _qty[p.id] ?? 0;
    if (current >= p.stock) return;
    if (current >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
      );
      return;
    }
    _setQty(p, current + 1);
    _cartAdd(p, 1);
  }

  void _dec(Product p) {
    final current = _qty[p.id] ?? 0;
    if (current <= 0) return;
    _setQty(p, current - 1);
    context.read<CartProvider>().removeOne(p.id.toString());
  }

  void _addToCart(Product p) {
    final current = _qty[p.id] ?? 0;
    final requested = current > 0 ? current : 1;
    final max = _maxPerItem(p);
    final canAdd = (max - current).clamp(0, requested);
    if (canAdd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 2 allowed for DAYALBAGH PRODUCT')),
      );
      return;
    }
    _cartAdd(p, canAdd);
    _setQty(p, current + canAdd);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added $canAdd × "${p.name}"')));
  }

  // dynamic categories from VISIBLE products
  void _buildDynamicCategories() {
    final Map<int, _CategoryInfo> m = {};
    for (final p in _visibleProducts) {
      final id = p.category;
      final name = (p.categoryName.isNotEmpty) ? p.categoryName : 'Other';
      m.putIfAbsent(
        id,
        () => _CategoryInfo(id: id, name: name, icon: _iconForCategory(name)),
      );
    }
    final list = m.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    _categories = list;
  }

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('grocery') || n.contains('grocer')) return Icons.scale;
    if (n.contains('dairy')) return Icons.local_drink;
    if (n.contains('electrical')) return Icons.lightbulb_outline;
    if (n.contains('electronic')) return Icons.tv;
    if (n.contains('furniture')) return Icons.chair;
    if (n.contains('utensil') || n.contains('kitchen')) return Icons.kitchen;
    if (n.contains('home')) return Icons.home_outlined;
    if (n.contains('personal') || n.contains('care')) return Icons.spa_outlined;
    if (n.contains('beverage') || n.contains('drink')) {
      return Icons.local_cafe_outlined;
    }
    return Icons.inventory_2_outlined;
  }

  // search control (debounced) — searches visible products only
  void _onSearchChanged(String v) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _q = v.trim().toLowerCase());
    });
  }

  List<Product> get _searchResults {
    if (_q.isEmpty) return const [];
    final base = _visibleProducts;
    return base.where((p) {
      final name = p.name.toLowerCase();
      final cat = p.categoryName.toLowerCase();
      return name.contains(_q) || cat.contains(_q);
    }).toList();
  }

  // ===== UI parts =====

  Widget _buildCategoryChip(_CategoryInfo c) {
    return Padding(
      // +2.0 px horizontal padding to avoid overlay crowding
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: () {
          final products = _visibleProducts
              .where((p) => p.category == c.id)
              .toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _CategoryProductsPage(
                categoryId: c.id,
                categoryName: c.name,
                products: products,
                imgUrlBuilder: _imgUrl,
                onAddToCart: _addToCart,
                onInc: _inc,
                onDec: _dec,
                getQtyVN: _vnFor,
                maxPerItem: _maxPerItem,
              ),
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: kPrimary, // palette
              child: Icon(c.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            // Long names: smaller font, tight height, ellipsis
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                c.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  letterSpacing: 0.2,
                  color: kTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kTextPrimary,
        ),
      ),
    );
  }

  // product card (no stock badge). Only the qty row rebuilds via ValueListenableBuilder.
  Widget _productCard(Product p) {
    final img = _imgUrl(p);
    final priceText = _priceText(p);
    final vn = _vnFor(p);

    return Card(
      color: kCard, // palette card bg
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 180,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: img == null
                    ? Container(
                        color: kCard,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: kTextPrimary,
                            size: 44,
                          ),
                        ),
                      )
                    : Image.network(
                        img,
                        fit: BoxFit.cover,
                        cacheWidth: 400,
                        filterQuality: FilterQuality.low,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: kCard,
                            child: const Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: kCard,
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: kTextPrimary,
                              size: 44,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Name
            SizedBox(
              height: 36,
              child: Text(
                p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: kTextPrimary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Price pill (tap = add to cart)
            GestureDetector(
              onTap: () => _addToCart(p),
              child: Container(
                height: 32,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: kPrimarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _alpha(kPrimary, 0.35)),
                ),
                child: Text(
                  priceText,
                  style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Quantity row (fast updates)
            ValueListenableBuilder<int>(
              valueListenable: vn,
              builder: (_, q, __) {
                final canInc =
                    (p.stock > 0) && (q < p.stock) && (q < _maxPerItem(p));
                return SizedBox(
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
                          color: kBgBottom,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(
                          '$q',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: kTextPrimary,
                          ),
                        ),
                      ),
                      _qtyButton(
                        icon: Icons.add,
                        onTap: canInc ? () => _inc(p) : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // small rounded icon button for qty (uses palette + passed icon)
  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap == null ? kBorder : kPrimary,
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

  // === BUILD ===
  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    final results = _searchResults;
    final showingSearch = _q.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: CustomScrollView(
        slivers: [
          // HERO HEADER
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kBgTop, kBgBottom],
                  stops: const [0.0, 0.3],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                children: [
                  // Menu + Search
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.menu, color: kTextPrimary, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search products',
                              hintStyle: TextStyle(
                                color: kTextPrimary.withOpacity(0.55),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: kTextPrimary,
                              ),
                              suffixIcon: (_q.isNotEmpty)
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: kTextPrimary.withOpacity(0.6),
                                      ),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : Icon(Icons.mic, color: kTextPrimary),
                              fillColor: Colors.white, // keeps contrast
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

                  const SizedBox(height: 22),

                  // Dynamic categories (horizontal)
                  SizedBox(
                    height: 106,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (_, i) => _buildCategoryChip(_categories[i]),
                      separatorBuilder: (_, __) => const SizedBox(width: 18),
                      itemCount: _categories.length,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search results grid (only when typing)
          if (showingSearch)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Results (${results.length})'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: results.length,
                      itemBuilder: (_, i) => _productCard(results[i]),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

          // ALL PRODUCTS grid (lazy-built) when not searching
          if (!showingSearch)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final p = _visibleProducts[index];
                  return _productCard(p);
                }, childCount: _visibleProducts.length),
              ),
            ),

          // Optional error banner (non-blocking if cache shown)
          if (_error != null && _products.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: MaterialBanner(
                  backgroundColor: kCard,
                  content: Text(
                    'Couldn\'t refresh: $_error',
                    style: TextStyle(color: kTextPrimary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: _loadProducts,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===== Category page (opens when a category chip is tapped) =====

class _CategoryProductsPage extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final List<Product> products; // already filtered to stock > 5
  final String? Function(Product) imgUrlBuilder;
  final void Function(Product) onAddToCart;
  final void Function(Product) onInc;
  final void Function(Product) onDec;
  final ValueNotifier<int> Function(Product) getQtyVN;
  final int Function(Product) maxPerItem;

  const _CategoryProductsPage({
    required this.categoryId,
    required this.categoryName,
    required this.products,
    required this.imgUrlBuilder,
    required this.onAddToCart,
    required this.onInc,
    required this.onDec,
    required this.getQtyVN,
    required this.maxPerItem,
    super.key,
  });

  // color alpha helper for this widget too
  Color _alpha(Color c, double o) => c.withAlpha((o * 255).round());

  double _priceDouble(Product p) => p.price is num
      ? (p.price as num).toDouble()
      : double.tryParse('${p.price}') ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Column(
        children: [
          _CategorySearch(title: categoryName),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                final img = imgUrlBuilder(p);
                final priceText = '₹ ${_priceDouble(p).toStringAsFixed(2)}';
                final vn = getQtyVN(p);

                return Card(
                  color: kCard, // palette card bg
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: img == null
                                ? Container(
                                    color: kCard,
                                    child: Center(
                                      child: Icon(
                                        Icons.image,
                                        color: kTextPrimary,
                                        size: 44,
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    img,
                                    fit: BoxFit.cover,
                                    cacheWidth: 400,
                                    filterQuality: FilterQuality.low,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: kCard,
                                        child: const Center(
                                          child: SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 36,
                          child: Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: kTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => onAddToCart(p),
                          child: Container(
                            height: 32,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: kPrimarySoft,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _alpha(kPrimary, 0.35)),
                            ),
                            child: Text(
                              priceText,
                              style: TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder<int>(
                          valueListenable: vn,
                          builder: (_, q, __) {
                            final canInc =
                                (p.stock > 0) &&
                                (q < p.stock) &&
                                (q < maxPerItem(p));
                            return SizedBox(
                              height: 36,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _qtyBtn(
                                    icon: Icons.remove,
                                    onTap: q > 0 ? () => onDec(p) : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kBgBottom,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: kBorder),
                                    ),
                                    child: Text(
                                      '$q',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: kTextPrimary,
                                      ),
                                    ),
                                  ),
                                  _qtyBtn(
                                    icon: Icons.add,
                                    onTap: canInc ? () => onInc(p) : null,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: onTap == null ? kBorder : kPrimary,
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
}

// small search on category page (kept as a visual aid)
class _CategorySearch extends StatefulWidget {
  final String title;
  const _CategorySearch({required this.title});

  @override
  State<_CategorySearch> createState() => _CategorySearchState();
}

class _CategorySearchState extends State<_CategorySearch> {
  String _q = '';
  final _ctrl = TextEditingController();
  Timer? _deb;

  @override
  void dispose() {
    _deb?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _q = v.trim().toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _ctrl,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: 'Search "${widget.title}"',
          hintStyle: TextStyle(color: kTextPrimary.withOpacity(0.55)),
          prefixIcon: Icon(Icons.search, color: kTextPrimary),
          suffixIcon: (_q.isNotEmpty)
              ? IconButton(
                  icon: Icon(Icons.clear, color: kTextPrimary.withOpacity(0.6)),
                  onPressed: () {
                    _ctrl.clear();
                    _onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          isDense: true,
        ),
      ),
    );
  }
}

// ===== internal types =====
class _CategoryInfo {
  final int id;
  final String name;
  final IconData icon;
  _CategoryInfo({required this.id, required this.name, required this.icon});
}
