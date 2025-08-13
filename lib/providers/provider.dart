import 'package:flutter/foundation.dart';

class CartLine {
  final String productId;
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
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartLine> _lines = {}; // key = productId
  Map<String, CartLine> get lines => Map.unmodifiable(_lines);

  int get itemCount => _lines.values.fold(0, (a, l) => a + l.qty);
  double get total => _lines.values.fold(0.0, (a, l) => a + l.lineTotal);

  void add({
    required String id,
    required String title,
    required double price,
    int qty = 1,
  }) {
    _lines.update(
      id,
      (e) => CartLine(
        productId: e.productId,
        title: e.title,
        price: e.price,
        qty: e.qty + qty,
      ),
      ifAbsent: () =>
          CartLine(productId: id, title: title, price: price, qty: qty),
    );
    notifyListeners();
  }

  void addById(String productId, {int qty = 1}) {
    final line = _lines[productId];
    if (line == null) return;
    line.qty += qty;
    notifyListeners();
  }

  void removeOne(String productId) {
    final line = _lines[productId];
    if (line == null) return;
    if (line.qty > 1) {
      line.qty -= 1;
    } else {
      _lines.remove(productId);
    }
    notifyListeners();
  }

  void removeAll(String productId) {
    _lines.remove(productId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
