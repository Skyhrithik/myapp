// import 'package:flutter/foundation.dart';

// class CartLine {
//   final String productId;
//   final String title;
//   final double price;
//   int qty;
//   CartLine({
//     required this.productId,
//     required this.title,
//     required this.price,
//     this.qty = 1,
//   });
//   double get lineTotal => price * qty;
// }

// class CartProvider extends ChangeNotifier {
//   final Map<String, CartLine> _lines = {}; // key = productId
//   Map<String, CartLine> get lines => Map.unmodifiable(_lines);

//   int get itemCount => _lines.values.fold(0, (a, l) => a + l.qty);
//   double get total => _lines.values.fold(0.0, (a, l) => a + l.lineTotal);

//   void add({
//     required String id,
//     required String title,
//     required double price,
//     int qty = 1,
//   }) {
//     _lines.update(
//       id,
//       (e) => CartLine(
//         productId: e.productId,
//         title: e.title,
//         price: e.price,
//         qty: e.qty + qty,
//       ),
//       ifAbsent: () =>
//           CartLine(productId: id, title: title, price: price, qty: qty),
//     );
//     notifyListeners();
//   }

//   void addById(String productId, {int qty = 1}) {
//     final line = _lines[productId];
//     if (line == null) return;
//     line.qty += qty;
//     notifyListeners();
//   }

//   void removeOne(String productId) {
//     final line = _lines[productId];
//     if (line == null) return;
//     if (line.qty > 1) {
//       line.qty -= 1;
//     } else {
//       _lines.remove(productId);
//     }
//     notifyListeners();
//   }

//   void removeAll(String productId) {
//     _lines.remove(productId);
//     notifyListeners();
//   }

//   void clear() {
//     _lines.clear();
//     notifyListeners();
//   }
// }

// // lib/providers/provider.dart
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CartLine {
//   final String productId;
//   final String title;
//   final double price;
//   int qty;

//   CartLine({
//     required this.productId,
//     required this.title,
//     required this.price,
//     this.qty = 1,
//   });

//   double get lineTotal => price * qty;

//   Map<String, dynamic> toJson() => {
//     'product_id': productId,
//     'title': title,
//     'price': price,
//     'qty': qty,
//   };

//   factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
//     productId: (j['product_id'] ?? j['id'] ?? '').toString(),
//     title: (j['title'] ?? '').toString(),
//     price: (j['price'] is num)
//         ? (j['price'] as num).toDouble()
//         : double.tryParse('${j['price']}') ?? 0.0,
//     qty: j['qty'] is int ? j['qty'] as int : int.tryParse('${j['qty']}') ?? 1,
//   );
// }

// class CartProvider extends ChangeNotifier {
//   static const _prefsKey = 'cart_lines_v2'; // bump key if schema changes
//   final Map<String, CartLine> _lines = {}; // key = productId

//   CartProvider() {
//     _loadFromPrefs(); // async, fire-and-forget restore
//   }

//   Map<String, CartLine> get lines => Map.unmodifiable(_lines);
//   int get itemCount => _lines.values.fold(0, (a, l) => a + l.qty);
//   double get total => _lines.values.fold(0.0, (a, l) => a + l.lineTotal);

//   // ---- Public API (kept compatible with your code) ----

//   void add({
//     required String id,
//     required String title,
//     required double price,
//     int qty = 1,
//   }) {
//     final existing = _lines[id];
//     if (existing != null) {
//       existing.qty += qty;
//     } else {
//       _lines[id] = CartLine(
//         productId: id,
//         title: title,
//         price: price,
//         qty: qty,
//       );
//     }
//     notifyListeners();
//     _saveToPrefs();
//   }

//   void addById(String productId, {int qty = 1}) {
//     final line = _lines[productId];
//     if (line == null) return;
//     line.qty += qty;
//     notifyListeners();
//     _saveToPrefs();
//   }

//   void removeOne(String productId) {
//     final line = _lines[productId];
//     if (line == null) return;
//     if (line.qty > 1) {
//       line.qty -= 1;
//     } else {
//       _lines.remove(productId);
//     }
//     notifyListeners();
//     _saveToPrefs();
//   }

//   void removeAll(String productId) {
//     _lines.remove(productId);
//     notifyListeners();
//     _saveToPrefs();
//   }

//   void clear() {
//     _lines.clear();
//     notifyListeners();
//     _saveToPrefs();
//   }

//   // Optional helper if you ever need to set a specific qty directly
//   void setQty(String productId, int qty) {
//     final line = _lines[productId];
//     if (line == null) return;
//     if (qty <= 0) {
//       _lines.remove(productId);
//     } else {
//       line.qty = qty;
//     }
//     notifyListeners();
//     _saveToPrefs();
//   }

//   // ---- Persistence ----

//   Future<void> _loadFromPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final raw = prefs.getString(_prefsKey);
//       if (raw == null || raw.isEmpty) return;

//       final decoded = jsonDecode(raw);
//       _lines.clear();

//       if (decoded is List) {
//         // Preferred format: list of lines
//         for (final e in decoded) {
//           final line = CartLine.fromJson(e as Map<String, dynamic>);
//           _lines[line.productId] = line;
//         }
//       } else if (decoded is Map) {
//         // Backward-compat format: map productId -> line
//         decoded.forEach((key, value) {
//           final line = CartLine.fromJson(value as Map<String, dynamic>);
//           _lines[line.productId] = line;
//         });
//       }

//       notifyListeners();
//     } catch (e) {
//       debugPrint('Cart load error: $e');
//     }
//   }

//   Future<void> _saveToPrefs() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final list = _lines.values.map((l) => l.toJson()).toList();
//       await prefs.setString(_prefsKey, jsonEncode(list));
//     } catch (e) {
//       debugPrint('Cart save error: $e');
//     }
//   }
// }
// lib/providers/provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLine {
  final String productId; // normalized to String
  final String title;
  final double price;
  int qty;

  CartLine({
    required this.productId,
    required this.title,
    required this.price,
    this.qty = 1,
  });

  double get lineTotal => price * qty;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'title': title,
    'price': price,
    'qty': qty,
  };

  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
    productId: (j['product_id'] ?? j['id'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    price: (j['price'] is num)
        ? (j['price'] as num).toDouble()
        : double.tryParse('${j['price']}') ?? 0.0,
    qty: j['qty'] is int ? j['qty'] as int : int.tryParse('${j['qty']}') ?? 1,
  );
}

class CartProvider extends ChangeNotifier {
  static const _prefsKey = 'cart_lines_v2';
  final Map<String, CartLine> _lines = {}; // key = productId (String)

  CartProvider() {
    _loadFromPrefs();
  }

  Map<String, CartLine> get lines => Map.unmodifiable(_lines);
  int get itemCount => _lines.values.fold(0, (a, l) => a + l.qty);
  double get total => _lines.values.fold(0.0, (a, l) => a + l.lineTotal);

  // Accept both int and String ids
  void add({
    required dynamic id,
    required String title,
    required double price,
    int qty = 1,
  }) {
    final key = id.toString();
    final existing = _lines[key];
    if (existing != null) {
      existing.qty += qty;
    } else {
      _lines[key] = CartLine(
        productId: key,
        title: title,
        price: price,
        qty: qty,
      );
    }
    notifyListeners();
    _saveToPrefs();
  }

  void addById(dynamic productId, {int qty = 1}) {
    final key = productId.toString();
    final line = _lines[key];
    if (line == null) return;
    line.qty += qty;
    notifyListeners();
    _saveToPrefs();
  }

  void removeOne(dynamic productId) {
    final key = productId.toString();
    final line = _lines[key];
    if (line == null) return;
    if (line.qty > 1) {
      line.qty -= 1;
    } else {
      _lines.remove(key);
    }
    notifyListeners();
    _saveToPrefs();
  }

  void removeAll(dynamic productId) {
    final key = productId.toString();
    _lines.remove(key);
    notifyListeners();
    _saveToPrefs();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
    _saveToPrefs();
  }

  // Optional helper if you need direct qty sets
  void setQty(dynamic productId, int qty) {
    final key = productId.toString();
    final line = _lines[key];
    if (line == null) return;
    if (qty <= 0) {
      _lines.remove(key);
    } else {
      line.qty = qty;
    }
    notifyListeners();
    _saveToPrefs();
  }

  // ---- Persistence ----
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      _lines.clear();

      if (decoded is List) {
        for (final e in decoded) {
          final line = CartLine.fromJson(e as Map<String, dynamic>);
          _lines[line.productId] = line;
        }
      } else if (decoded is Map) {
        decoded.forEach((_, value) {
          final line = CartLine.fromJson(value as Map<String, dynamic>);
          _lines[line.productId] = line;
        });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Cart load error: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _lines.values.map((l) => l.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Cart save error: $e');
    }
  }
}
