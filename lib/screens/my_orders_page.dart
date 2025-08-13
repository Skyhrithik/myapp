// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../config/config.dart';

// /// ====== CONFIG ======
// Uri get _ordersListUri =>
//     Uri.parse('${AppConfig.baseUrl}/me/orders/'); // GET list
// Uri _orderDetailUri(int id) =>
//     Uri.parse('${AppConfig.baseUrl}/me/orders/$id/'); // GET one
// Uri _orderCancelUri(int id) =>
//     Uri.parse('${AppConfig.baseUrl}/me/orders/$id/cancel/'); // POST cancel

// Future<Map<String, String>> _authJsonHeaders() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token'); // MUST be set at login
//   return {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
//   };
// }

// /// ====== MODELS ======
// class MyOrder {
//   final int id;
//   final String status; // PENDING, PAID, CANCELLED, RECEIVED, etc.
//   final String statusDisplay; // "Pending"
//   final String paymentMethod; // COD, UPI
//   final double totalAmount;
//   final DateTime? createdAt;
//   final List<MyOrderLine> items;

//   bool get canCancel => status.toUpperCase() == 'PENDING';

//   MyOrder({
//     required this.id,
//     required this.status,
//     required this.statusDisplay,
//     required this.paymentMethod,
//     required this.totalAmount,
//     required this.items,
//     required this.createdAt,
//   });

//   factory MyOrder.fromJson(Map<String, dynamic> j) {
//     double _toDouble(dynamic v) {
//       if (v == null) return 0.0;
//       if (v is num) return v.toDouble();
//       return double.tryParse(v.toString()) ?? 0.0;
//     }

//     return MyOrder(
//       id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
//       status: (j['status'] ?? '').toString(),
//       statusDisplay: (j['status_display'] ?? j['status'] ?? '').toString(),
//       paymentMethod: (j['payment_method'] ?? '').toString(),
//       totalAmount: _toDouble(j['total_amount'] ?? j['amount']),
//       createdAt: j['created_at'] != null
//           ? DateTime.tryParse(j['created_at'].toString())
//           : null,
//       items: (j['items'] as List<dynamic>? ?? [])
//           .map((x) => MyOrderLine.fromJson(x as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   MyOrder copyWith({String? status, String? statusDisplay}) => MyOrder(
//     id: id,
//     status: status ?? this.status,
//     statusDisplay: statusDisplay ?? this.statusDisplay,
//     paymentMethod: paymentMethod,
//     totalAmount: totalAmount,
//     items: items,
//     createdAt: createdAt,
//   );
// }

// class MyOrderLine {
//   final int id;
//   final int productId;
//   final String name;
//   final int qty;
//   final double unitPrice;
//   final double lineTotal;

//   MyOrderLine({
//     required this.id,
//     required this.productId,
//     required this.name,
//     required this.qty,
//     required this.unitPrice,
//     required this.lineTotal,
//   });

//   factory MyOrderLine.fromJson(Map<String, dynamic> j) {
//     double _d(dynamic v) =>
//         v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0.0;
//     return MyOrderLine(
//       id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
//       productId: j['product_id'] is int
//           ? j['product_id']
//           : int.tryParse('${j['product_id']}') ?? 0,
//       name: (j['product_name'] ?? j['name'] ?? 'Item').toString(),
//       qty: j['quantity'] is int
//           ? j['quantity']
//           : int.tryParse('${j['quantity']}') ?? 0,
//       unitPrice: _d(j['unit_price']),
//       lineTotal: _d(j['line_total']),
//     );
//   }
// }

// /// ====== SCREEN ======
// class MyOrdersPage extends StatefulWidget {
//   const MyOrdersPage({super.key});

//   @override
//   State<MyOrdersPage> createState() => _MyOrdersPageState();
// }

// class _MyOrdersPageState extends State<MyOrdersPage> {
//   bool _loading = true;
//   String? _error;
//   List<MyOrder> _orders = [];
//   final Map<int, bool> _canceling = {}; // orderId -> in-flight

//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders();
//   }

//   Future<void> _fetchOrders() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final headers = await _authJsonHeaders();
//       final res = await http.get(_ordersListUri, headers: headers);
//       if (res.statusCode != 200) {
//         setState(() {
//           _error =
//               _extractErrorMessage(res.body) ??
//               'HTTP ${res.statusCode}: Failed to load orders';
//           _loading = false;
//         });
//         return;
//       }
//       final data = jsonDecode(res.body);
//       final list = (data as List<dynamic>).cast<dynamic>();
//       final parsed = list
//           .map((e) => MyOrder.fromJson(e as Map<String, dynamic>))
//           .toList();
//       setState(() {
//         _orders = parsed;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Error: $e';
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _refresh() => _fetchOrders();

//   Future<void> _openOrder(int id) async {
//     try {
//       final headers = await _authJsonHeaders();
//       final res = await http.get(_orderDetailUri(id), headers: headers);
//       if (res.statusCode == 200) {
//         final j = jsonDecode(res.body) as Map<String, dynamic>;
//         final ord = MyOrder.fromJson(j);
//         if (!mounted) return;
//         await showDialog(
//           context: context,
//           builder: (_) => _OrderDetailDialog(order: ord),
//         );
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               _extractErrorMessage(res.body) ??
//                   'HTTP ${res.statusCode}: Couldn\'t fetch order',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   Future<void> _cancelOrder(MyOrder order) async {
//     if (!order.canCancel) return;
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Cancel order?'),
//         content: Text('Order #${order.id} will be cancelled.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('No'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Yes, cancel'),
//           ),
//         ],
//       ),
//     );
//     if (confirm != true) return;

//     setState(() {
//       _canceling[order.id] = true;
//     });

//     try {
//       final headers = await _authJsonHeaders();
//       final res = await http.post(_orderCancelUri(order.id), headers: headers);
//       if (res.statusCode == 200 || res.statusCode == 202) {
//         MyOrder updated = order;
//         try {
//           final body = jsonDecode(res.body);
//           if (body is Map<String, dynamic>) {
//             final status = (body['status'] ?? '').toString();
//             final statusDisplay = (body['status_display'] ?? status).toString();
//             if (status.isNotEmpty) {
//               updated = order.copyWith(
//                 status: status,
//                 statusDisplay: statusDisplay,
//               );
//             }
//           }
//         } catch (_) {
//           updated = order.copyWith(
//             status: 'CANCELLED',
//             statusDisplay: 'Cancelled',
//           );
//         }

//         setState(() {
//           _orders = _orders.map((o) => o.id == order.id ? updated : o).toList();
//         });

//         if (!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Order cancelled')));
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               _extractErrorMessage(res.body) ??
//                   'HTTP ${res.statusCode}: Cancel failed',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _canceling.remove(order.id);
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Orders'),
//         actions: [
//           IconButton(
//             onPressed: _refresh,
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//           ? Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(_error!, textAlign: TextAlign.center),
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: _refresh,
//               child: _orders.isEmpty
//                   ? ListView(
//                       children: const [
//                         SizedBox(height: 120),
//                         Center(child: Text('No orders found')),
//                         SizedBox(height: 120),
//                       ],
//                     )
//                   : ListView.separated(
//                       padding: const EdgeInsets.all(12),
//                       itemBuilder: (_, i) {
//                         final o = _orders[i];
//                         return _OrderTile(
//                           order: o,
//                           busy: _canceling[o.id] == true,
//                           onOpen: () => _openOrder(o.id),
//                           onCancel: o.canCancel ? () => _cancelOrder(o) : null,
//                         );
//                       },
//                       separatorBuilder: (_, __) => const SizedBox(height: 8),
//                       itemCount: _orders.length,
//                     ),
//             ),
//     );
//   }

//   String? _extractErrorMessage(String body) {
//     try {
//       final parsed = jsonDecode(body);
//       if (parsed is Map) {
//         if (parsed['detail'] != null) return parsed['detail'].toString();
//         if (parsed['error'] != null) return parsed['error'].toString();
//         if (parsed.values.isNotEmpty) return parsed.values.first.toString();
//       }
//     } catch (_) {}
//     return null;
//   }
// }

// /// ====== WIDGETS ======
// class _OrderTile extends StatelessWidget {
//   final MyOrder order;
//   final VoidCallback? onOpen;
//   final VoidCallback? onCancel;
//   final bool busy;

//   const _OrderTile({
//     required this.order,
//     this.onOpen,
//     this.onCancel,
//     this.busy = false,
//   });

//   Color _statusColor(BuildContext context) {
//     final s = order.status.toUpperCase();
//     if (s == 'PENDING') return Colors.orange;
//     if (s == 'PAID') return Colors.green;
//     if (s == 'CANCELLED') return Colors.red;
//     if (s == 'RECEIVED' || s == 'DELIVERED') return Colors.blue;
//     return Theme.of(context).colorScheme.secondary;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateStr = order.createdAt != null
//         ? '${order.createdAt!.day.toString().padLeft(2, '0')}-'
//               '${order.createdAt!.month.toString().padLeft(2, '0')}-'
//               '${order.createdAt!.year}'
//         : '';

//     final subtitle = [
//       if (dateStr.isNotEmpty) 'Date: $dateStr',
//       'Items: ${order.items.length}',
//       'Pay: ${order.paymentMethod}',
//     ].join(' • ');

//     return Card(
//       elevation: 0.5,
//       child: ListTile(
//         onTap: onOpen,
//         title: Row(
//           children: [
//             Expanded(child: Text('Order #${order.id}')),
//             Chip(
//               label: Text(
//                 order.statusDisplay.isNotEmpty
//                     ? order.statusDisplay
//                     : order.status,
//               ),
//               backgroundColor: _statusColor(context).withOpacity(0.1),
//               labelStyle: TextStyle(
//                 color: _statusColor(context),
//                 fontWeight: FontWeight.w600,
//               ),
//               side: BorderSide(color: _statusColor(context)),
//               visualDensity: VisualDensity.compact,
//               padding: const EdgeInsets.symmetric(horizontal: 6),
//             ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text(subtitle),
//         ),
//         trailing: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '₹ ${order.totalAmount.toStringAsFixed(2)}',
//               style: const TextStyle(fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 6),
//             if (onCancel != null)
//               SizedBox(
//                 height: 28,
//                 child: OutlinedButton(
//                   onPressed: busy ? null : onCancel,
//                   child: busy
//                       ? const SizedBox(
//                           height: 14,
//                           width: 14,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Cancel'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _OrderDetailDialog extends StatelessWidget {
//   final MyOrder order;
//   const _OrderDetailDialog({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Order #${order.id}'),
//       content: SizedBox(
//         width: 380,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Status: ',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 Text(
//                   order.statusDisplay.isNotEmpty
//                       ? order.statusDisplay
//                       : order.status,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 const Text(
//                   'Payment: ',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 Text(order.paymentMethod),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 const Text(
//                   'Total: ',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 Text('₹ ${order.totalAmount.toStringAsFixed(2)}'),
//               ],
//             ),
//             const Divider(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Items',
//                 style: TextStyle(fontWeight: FontWeight.w700),
//               ),
//             ),
//             const SizedBox(height: 6),
//             SizedBox(
//               height: 200,
//               child: ListView.separated(
//                 itemCount: order.items.length,
//                 itemBuilder: (_, i) {
//                   final it = order.items[i];
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(child: Text(it.name)),
//                       Text('x${it.qty}'),
//                       const SizedBox(width: 8),
//                       Text('₹ ${it.lineTotal.toStringAsFixed(2)}'),
//                     ],
//                   );
//                 },
//                 separatorBuilder: (_, __) => const SizedBox(height: 6),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Close'),
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

/// ====== CONFIG ======
Uri get _ordersListUri =>
    Uri.parse('${AppConfig.baseUrl}/me/orders/'); // GET list
Uri _orderDetailUri(int id) =>
    Uri.parse('${AppConfig.baseUrl}/me/orders/$id/'); // GET one
Uri _orderCancelUri(int id) =>
    Uri.parse('${AppConfig.baseUrl}/me/orders/$id/cancel/'); // POST cancel

Future<Map<String, String>> _authJsonHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token'); // MUST be set at login
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
  };
}

/// ====== MODELS ======
class MyOrder {
  final int id;
  final String status; // PENDING, PAID, CANCELLED, RECEIVED, etc.
  final String statusDisplay; // "Pending"
  final String paymentMethod; // COD, UPI
  final double totalAmount;
  final DateTime? createdAt;
  final List<MyOrderLine> items;

  bool get canCancel => status.toUpperCase() == 'PENDING';

  MyOrder({
    required this.id,
    required this.status,
    required this.statusDisplay,
    required this.paymentMethod,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
  });

  factory MyOrder.fromJson(Map<String, dynamic> j) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return MyOrder(
      id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      status: (j['status'] ?? '').toString(),
      statusDisplay: (j['status_display'] ?? j['status'] ?? '').toString(),
      paymentMethod: (j['payment_method'] ?? '').toString(),
      totalAmount: _toDouble(j['total_amount'] ?? j['amount']),
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      items: (j['items'] as List<dynamic>? ?? [])
          .map((x) => MyOrderLine.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }

  MyOrder copyWith({String? status, String? statusDisplay}) => MyOrder(
    id: id,
    status: status ?? this.status,
    statusDisplay: statusDisplay ?? this.statusDisplay,
    paymentMethod: paymentMethod,
    totalAmount: totalAmount,
    items: items,
    createdAt: createdAt,
  );
}

class MyOrderLine {
  final int id;
  final int productId;
  final String name;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  MyOrderLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory MyOrderLine.fromJson(Map<String, dynamic> j) {
    double _d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0.0;
    return MyOrderLine(
      id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
      productId: j['product_id'] is int
          ? j['product_id']
          : int.tryParse('${j['product_id']}') ?? 0,
      name: (j['product_name'] ?? j['name'] ?? 'Item').toString(),
      qty: j['quantity'] is int
          ? j['quantity']
          : int.tryParse('${j['quantity']}') ?? 0,
      unitPrice: _d(j['unit_price']),
      lineTotal: _d(j['line_total']),
    );
  }
}

/// ====== SCREEN ======
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  bool _loading = true;
  String? _error;
  List<MyOrder> _orders = [];
  final Map<int, bool> _canceling = {}; // orderId -> in-flight

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final headers = await _authJsonHeaders();
      final res = await http.get(_ordersListUri, headers: headers);
      if (res.statusCode != 200) {
        setState(() {
          _error =
              _extractErrorMessage(res.body) ??
              'HTTP ${res.statusCode}: Failed to load orders';
          _loading = false;
        });
        return;
      }
      final data = jsonDecode(res.body);
      final list = (data as List<dynamic>).cast<dynamic>();
      final parsed = list
          .map((e) => MyOrder.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _orders = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() => _fetchOrders();

  /// Shows a blocking loader while [task] runs. Closes loader even on error.
  Future<T?> _withLoader<T>(Future<T> Function() task) async {
    if (!mounted) return null;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    // The dialog is shown; now run the task and then pop the loader.
    try {
      return await task();
    } finally {
      if (mounted) Navigator.of(context).pop(); // close loader
    }
  }

  Future<void> _openOrder(int id) async {
    final ord = await _withLoader<MyOrder?>(() async {
      try {
        final headers = await _authJsonHeaders();
        final res = await http.get(_orderDetailUri(id), headers: headers);
        if (res.statusCode == 200) {
          final j = jsonDecode(res.body) as Map<String, dynamic>;
          return MyOrder.fromJson(j);
        } else {
          final msg =
              _extractErrorMessage(res.body) ??
              'HTTP ${res.statusCode}: Couldn\'t fetch order';
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          }
          return null;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
        return null;
      }
    });

    if (!mounted || ord == null) return;
    await showDialog(
      context: context,
      builder: (_) => _OrderDetailDialog(order: ord),
    );
  }

  Future<void> _cancelOrder(MyOrder order) async {
    if (!order.canCancel) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel order?'),
        content: Text('Order #${order.id} will be cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _canceling[order.id] = true;
    });

    try {
      final headers = await _authJsonHeaders();
      final res = await http.post(_orderCancelUri(order.id), headers: headers);
      if (res.statusCode == 200 || res.statusCode == 202) {
        MyOrder updated = order;
        try {
          final body = jsonDecode(res.body);
          if (body is Map<String, dynamic>) {
            final status = (body['status'] ?? '').toString();
            final statusDisplay = (body['status_display'] ?? status).toString();
            if (status.isNotEmpty) {
              updated = order.copyWith(
                status: status,
                statusDisplay: statusDisplay,
              );
            }
          }
        } catch (_) {
          updated = order.copyWith(
            status: 'CANCELLED',
            statusDisplay: 'Cancelled',
          );
        }

        setState(() {
          _orders = _orders.map((o) => o.id == order.id ? updated : o).toList();
        });

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order cancelled')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _extractErrorMessage(res.body) ??
                  'HTTP ${res.statusCode}: Cancel failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _canceling.remove(order.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _orders.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No orders found')),
                        SizedBox(height: 120),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, i) {
                        final o = _orders[i];
                        return _OrderTile(
                          order: o,
                          busy: _canceling[o.id] == true,
                          onOpen: () => _openOrder(o.id),
                          onCancel: o.canCancel ? () => _cancelOrder(o) : null,
                          colorScheme: scheme,
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: _orders.length,
                    ),
            ),
    );
  }

  String? _extractErrorMessage(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map) {
        if (parsed['detail'] != null) return parsed['detail'].toString();
        if (parsed['error'] != null) return parsed['error'].toString();
        if (parsed.values.isNotEmpty) return parsed.values.first.toString();
      }
    } catch (_) {}
    return null;
  }
}

/// ====== WIDGETS ======
class _OrderTile extends StatelessWidget {
  final MyOrder order;
  final VoidCallback? onOpen;
  final VoidCallback? onCancel;
  final bool busy;
  final ColorScheme colorScheme;

  const _OrderTile({
    required this.order,
    this.onOpen,
    this.onCancel,
    this.busy = false,
    required this.colorScheme,
  });

  Color _statusColor(BuildContext context) {
    final s = order.status.toUpperCase();
    if (s == 'PENDING') return Colors.orange;
    if (s == 'PAID') return Colors.green;
    if (s == 'CANCELLED') return Colors.red;
    if (s == 'RECEIVED' || s == 'DELIVERED') return Colors.blue;
    return Theme.of(context).colorScheme.secondary;
  }

  String _dateStr(DateTime? dt) {
    if (dt == null) return '';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd-$mm-$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final dateStr = _dateStr(order.createdAt);

    return Card(
      elevation: 0.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: statusColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Top row: ID + Status chip + Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (dateStr.isNotEmpty)
                          Text(
                            '• $dateStr',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Status chip
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          (order.statusDisplay.isNotEmpty
                                  ? order.statusDisplay
                                  : order.status)
                              .toString(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Middle: summary line
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Items: ${order.items.length} • Pay: ${order.paymentMethod}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹ ${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Bottom: Cancel button (if allowed)
              if (onCancel != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      icon: busy
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(
                        busy ? 'Cancelling...' : 'Cancel',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: busy ? null : onCancel,
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(color: statusColor.withOpacity(0.7)),
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

class _OrderDetailDialog extends StatelessWidget {
  final MyOrder order;
  const _OrderDetailDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        'Order #${order.id}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _kv(
              'Status',
              order.statusDisplay.isNotEmpty
                  ? order.statusDisplay
                  : order.status,
            ),
            const SizedBox(height: 6),
            _kv('Payment', order.paymentMethod),
            const SizedBox(height: 6),
            _kv('Total', '₹ ${order.totalAmount.toStringAsFixed(2)}'),
            const Divider(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Items',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.separated(
                itemCount: order.items.length,
                itemBuilder: (_, i) {
                  final it = order.items[i];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(it.name)),
                      Text('x${it.qty}'),
                      const SizedBox(width: 8),
                      Text('₹ ${it.lineTotal.toStringAsFixed(2)}'),
                    ],
                  );
                },
                separatorBuilder: (_, __) =>
                    Divider(height: 12, color: Colors.grey.shade200),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Row(
    children: [
      Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w700)),
      Flexible(child: Text(v)),
    ],
  );
}
