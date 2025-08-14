// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../config/config.dart';
// import '../providers/provider.dart';

// const kConstCity = 'Agra';
// const kConstState = 'UP';
// const kConstPincode = '282005';

// const kMerchantVpa = 'paytmqr6jkklj@ptys';
// const kMerchantName = 'FPS Store';

// const kApiBase = '${AppConfig.baseUrl}/me/orders/';

// Future<String?> _readAuthToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');
//   return (token != null && token.trim().isNotEmpty) ? token : null;
// }

// enum PaymentMethod { cod, online }

// enum UpiMode { qr, upiId }

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Dynamic profile fields (non-editable UI)
//   String _name = 'Customer';
//   String _phone = '';
//   String _addr1 = '';
//   String _addr2 = '';

//   PaymentMethod _method = PaymentMethod.cod;
//   UpiMode _upiMode = UpiMode.qr;
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadProfileFromPrefs();
//   }

//   Future<void> _loadProfileFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final name = prefs.getString('name') ?? 'Customer';
//     final phone = prefs.getString('phone') ?? '';
//     final address = prefs.getString('address') ?? '';

//     // Best-effort split of address into two lines
//     String line1 = address, line2 = '';
//     final comma = address.indexOf(',');
//     if (comma > 0) {
//       line1 = address.substring(0, comma).trim();
//       line2 = address.substring(comma + 1).trim();
//     }

//     setState(() {
//       _name = name;
//       _phone = phone;
//       _addr1 = line1;
//       _addr2 = line2;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cart = context.watch<CartProvider>();
//     final lines = cart.lines.values.toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Checkout')),
//       body: lines.isEmpty
//           ? const Center(child: Text('Your cart is empty'))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // ===== Shipping Details (single, non-editable card) =====
//                     _Section(
//                       title: 'Shipping Details',
//                       child: _shippingSummaryCard(),
//                     ),

//                     const SizedBox(height: 16),

//                     // ===== Payment Method =====
//                     _Section(
//                       title: 'Payment Method',
//                       child: Column(
//                         children: [
//                           RadioListTile(
//                             value: PaymentMethod.cod,
//                             groupValue: _method,
//                             onChanged: (v) => setState(() => _method = v!),
//                             title: const Text('Cash on Delivery'),
//                             subtitle: const Text('Pay when your order arrives'),
//                           ),
//                           RadioListTile(
//                             value: PaymentMethod.online,
//                             groupValue: _method,
//                             onChanged: (v) => setState(() => _method = v!),
//                             title: const Text('UPI'),
//                             subtitle: const Text(
//                               'Pay via UPI app (QR or UPI ID)',
//                             ),
//                           ),
//                           if (_method == PaymentMethod.online)
//                             _buildUpiOptions(context),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // ===== Order Summary =====
//                     _Section(
//                       title: 'Order Summary',
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           for (final l in lines)
//                             ListTile(
//                               dense: true,
//                               contentPadding: EdgeInsets.zero,
//                               title: Text(l.title),
//                               trailing: Text(
//                                 'x${l.qty}  ₹${(l.price * l.qty).toStringAsFixed(2)}',
//                               ),
//                             ),
//                           const Divider(),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Total',
//                                 style: TextStyle(fontWeight: FontWeight.w700),
//                               ),
//                               Text(
//                                 '₹ ${cart.total.toStringAsFixed(2)}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // ===== Place Order =====
//                     SizedBox(
//                       width: double.infinity,
//                       child: FilledButton(
//                         onPressed: _loading ? null : _onMakePayment,
//                         child: _loading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text('Place Your Order'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   // Single, non-editable summary card for user details
//   Widget _shippingSummaryCard() {
//     final addrFull = [
//       if (_addr1.isNotEmpty) _addr1,
//       if (_addr2.isNotEmpty) _addr2,
//       '$kConstCity, $kConstState - $kConstPincode',
//     ].join('\n');

//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.location_on_outlined),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Name + Phone
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         _name.isEmpty ? 'Customer' : _name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       _phone.isEmpty ? '' : '+91 $_phone',
//                       style: TextStyle(color: Colors.grey.shade700),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 // Address lines + city/state/pincode
//                 Text(addrFull, style: const TextStyle(height: 1.3)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUpiOptions(BuildContext context) {
//     final cart = context.read<CartProvider>();
//     final amount = cart.total;

//     final upiUrl = _buildUpiUrl(
//       payeeVpa: kMerchantVpa,
//       payeeName: kMerchantName,
//       amount: amount,
//       note: 'Order payment',
//       tr: 'ref_${DateTime.now().millisecondsSinceEpoch}',
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: 8),
//         SegmentedButton<UpiMode>(
//           segments: const [
//             ButtonSegment(value: UpiMode.qr, label: Text('QR')),
//             ButtonSegment(value: UpiMode.upiId, label: Text('UPI ID')),
//           ],
//           selected: <UpiMode>{_upiMode},
//           onSelectionChanged: (s) => setState(() => _upiMode = s.first),
//         ),
//         const SizedBox(height: 12),
//         if (_upiMode == UpiMode.qr) ...[
//           Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.asset(
//                 'assets/fps_QR.jpeg',
//                 width: 220,
//                 height: 220,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Scan with any UPI app to pay ₹${amount.toStringAsFixed(2)} to $kMerchantName',
//             textAlign: TextAlign.center,
//           ),
//         ] else ...[
//           const _LabeledRow(
//             label: 'Pay to UPI ID',
//             value: kMerchantVpa,
//             copyable: true,
//           ),
//           const SizedBox(height: 8),
//           FilledButton.icon(
//             onPressed: () async {
//               final uri = Uri.parse(upiUrl);
//               await launchUrl(uri, mode: LaunchMode.externalApplication);
//             },
//             icon: const Icon(Icons.open_in_new),
//             label: Text('Pay ₹${amount.toStringAsFixed(2)} via UPI'),
//           ),
//         ],
//       ],
//     );
//   }

//   Future<void> _onMakePayment() async {
//     // Manual sanity checks since there are no editable fields now
//     if ((_name.trim().isEmpty) ||
//         (_phone.trim().length < 10) ||
//         (_addr1.trim().isEmpty)) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Missing profile details. Please add name/phone/address in your account.',
//           ),
//         ),
//       );
//       return;
//     }

//     final cart = context.read<CartProvider>();
//     if (cart.lines.isEmpty) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final payload = _buildOrderPayload(
//         paymentMethod: _method == PaymentMethod.cod ? 'COD' : 'UPI',
//         name: _name.trim(),
//         phone: _phone.trim(),
//         addr1: _addr1.trim(),
//         addr2: _addr2.trim(),
//         city: kConstCity,
//         state: kConstState,
//         pincode: kConstPincode,
//         cart: cart,
//       );

//       if (_method == PaymentMethod.cod) {
//         final ok = await _createOrder(payload);
//         if (!ok) throw Exception('Failed to place COD order.');
//         if (!mounted) return;
//         cart.clear();
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Order placed (COD).')));
//         Navigator.pop(context);
//         return;
//       }

//       // UPI flow
//       final createRes = await _createOrderAndGetId(payload);
//       if (createRes == null) throw Exception('Failed to create UPI order.');
//       final orderId = createRes.orderId;
//       final amount = createRes.amount;

//       final upiUrl = _buildUpiUrl(
//         payeeVpa: kMerchantVpa,
//         payeeName: kMerchantName,
//         amount: amount,
//         note: 'Order #$orderId',
//         tr: 'order_$orderId',
//       );
//       final upiResult = await _launchUpi(upiUrl);

//       if (upiResult == null) {
//         throw Exception('Payment cancelled or no response from UPI app.');
//       }
//       final status = upiResult['status']?.toString().toUpperCase() ?? 'FAILURE';
//       final txnId = upiResult['txnId'] ?? upiResult['transactionId'] ?? '';

//       if (status == 'SUCCESS') {
//         final ok = await _confirmUpi(orderId, txnId.toString());
//         if (!ok) debugPrint('WARN: Server could not verify UPI payment.');
//         if (!mounted) return;
//         cart.clear();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Payment successful. Order placed.')),
//         );
//         Navigator.pop(context);
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Payment failed: $status')));
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   // --- Helpers ---

//   Map<String, dynamic> _buildOrderPayload({
//     required String paymentMethod,
//     required String name,
//     required String phone,
//     required String addr1,
//     required String addr2,
//     required String city,
//     required String state,
//     required String pincode,
//     required CartProvider cart,
//   }) {
//     final items = cart.lines.values
//         .map((l) => {'product_id': l.productId, 'quantity': l.qty})
//         .toList();

//     return {
//       'payment_method': paymentMethod, // 'COD' or 'ONLONE'
//       'shipping_name': name,
//       'shipping_phone': phone,
//       'address_line1': addr1,
//       'address_line2': addr2,
//       'city': city,
//       'state': state,
//       'pincode': pincode,
//       'items': items,
//     };
//   }

//   String _buildUpiUrl({
//     required String payeeVpa,
//     required String payeeName,
//     required double amount,
//     required String note,
//     required String tr,
//   }) {
//     final params = {
//       'pa': payeeVpa,
//       'pn': payeeName,
//       'am': amount.toStringAsFixed(2),
//       'tn': note,
//       'cu': 'INR',
//       'tr': tr,
//     };
//     final qp = params.entries
//         .map(
//           (e) =>
//               '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
//         )
//         .join('&');
//     return 'upi://pay?$qp';
//   }

//   Future<Map<String, String>?> _launchUpi(String upiUrl) async {
//     final uri = Uri.parse(upiUrl);
//     final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
//     if (!ok) return null;

//     if (!mounted) return null;
//     final res = await showDialog<Map<String, String>>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('UPI Payment'),
//         content: const Text('Did the payment succeed in your UPI app?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, {'status': 'FAILURE'}),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () =>
//                 Navigator.pop(context, {'status': 'SUCCESS', 'txnId': ''}),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     );
//     return res;
//   }

//   // ---------- Networking helpers ----------

//   Future<Map<String, String>> _authJsonHeaders() async {
//     final token = await _readAuthToken();
//     if (token == null || token.isEmpty) {
//       throw Exception('Not authenticated. Please log in again.');
//     }
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       'Authorization': 'Token $token',
//     };
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

//   Future<bool> _createOrder(Map<String, dynamic> payload) async {
//     try {
//       final headers = await _authJsonHeaders();
//       final res = await http.post(
//         Uri.parse(kApiBase),
//         headers: headers,
//         body: jsonEncode(payload),
//       );
//       if (res.statusCode == 200 || res.statusCode == 201) return true;

//       debugPrint('Create COD order failed: ${res.statusCode} ${res.body}');
//       final msg = _extractErrorMessage(res.body) ?? 'HTTP ${res.statusCode}';
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Create order failed: $msg')));
//       }
//       return false;
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Auth/Network error: $e')));
//       }
//       return false;
//     }
//   }

//   Future<_OrderCreateRes?> _createOrderAndGetId(
//     Map<String, dynamic> payload,
//   ) async {
//     try {
//       final headers = await _authJsonHeaders();
//       final res = await http.post(
//         Uri.parse(kApiBase),
//         headers: headers,
//         body: jsonEncode(payload),
//       );
//       if (res.statusCode != 200 && res.statusCode != 201) {
//         debugPrint('Create UPI order failed: ${res.statusCode} ${res.body}');
//         final msg = _extractErrorMessage(res.body);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Create UPI order failed: ${msg ?? res.statusCode}',
//               ),
//             ),
//           );
//         }
//         return null;
//       }
//       final data = jsonDecode(res.body);
//       final id = data['id'] ?? data['order_id'];
//       final amount = (data['total_amount'] ?? data['amount'] ?? 0).toDouble();
//       return _OrderCreateRes(
//         orderId: id is int ? id : int.tryParse(id.toString()) ?? 0,
//         amount: amount,
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Auth/Network error: $e')));
//       }
//       return null;
//     }
//   }

//   Future<bool> _confirmUpi(int orderId, String txnId) async {
//     try {
//       final headers = await _authJsonHeaders();
//       final confirmUri = Uri.parse(
//         '${AppConfig.baseUrl}/me/orders/$orderId/confirm-upi/',
//       );
//       final res = await http.post(
//         confirmUri,
//         headers: headers,
//         body: jsonEncode({'txn_id': txnId}),
//       );
//       if (res.statusCode != 200) {
//         debugPrint('UPI confirm failed: ${res.statusCode} ${res.body}');
//         return false;
//       }
//       return true;
//     } catch (e) {
//       debugPrint('UPI confirm error: $e');
//       return false;
//     }
//   }
// }

// class _OrderCreateRes {
//   final int orderId;
//   final double amount;
//   _OrderCreateRes({required this.orderId, required this.amount});
// }

// class _Section extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _Section({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0.5,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//             ),
//             const SizedBox(height: 8),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LabeledRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool copyable;
//   const _LabeledRow({
//     required this.label,
//     required this.value,
//     this.copyable = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: Text('$label: $value')),
//         if (copyable)
//           IconButton(
//             icon: const Icon(Icons.copy),
//             onPressed: () async {
//               await Clipboard.setData(ClipboardData(text: value));
//               if (context.mounted) {
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(const SnackBar(content: Text('Copied')));
//               }
//             },
//           ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../providers/provider.dart';

// === Constants ===
const kConstCity = 'Agra';
const kConstState = 'UP';
const kConstPincode = '282005';

// === UPI (replace with your merchant details) ===
const kMerchantVpa = 'paytmqr6jkklj@ptys';
const kMerchantName = 'FPS Store';

// === API base ===
const kApiBase = '${AppConfig.baseUrl}/me/orders/';

// ====== TOKEN (SharedPreferences-based) ======
Future<String?> _readAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return (token != null && token.trim().isNotEmpty) ? token : null;
}

enum PaymentMethod { cod, online }

enum UpiMode { qr, upiId }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dynamic profile fields (non-editable UI)
  String _name = 'Customer';
  String _phone = '';
  String _addr1 = '';
  String _addr2 = '';

  PaymentMethod _method = PaymentMethod.cod;
  UpiMode _upiMode = UpiMode.qr;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileFromPrefs();
  }

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'Customer';
    final phone = prefs.getString('phone') ?? '';
    final address = prefs.getString('address') ?? '';

    // Best-effort split of address into two lines
    String line1 = address, line2 = '';
    final comma = address.indexOf(',');
    if (comma > 0) {
      line1 = address.substring(0, comma).trim();
      line2 = address.substring(comma + 1).trim();
    }

    setState(() {
      _name = name;
      _phone = phone;
      _addr1 = line1;
      _addr2 = line2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final lines = cart.lines.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: lines.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ===== Shipping Details (single, non-editable card) =====
                    _Section(
                      title: 'Shipping Details',
                      child: _shippingSummaryCard(),
                    ),

                    const SizedBox(height: 16),

                    // ===== Payment Method =====
                    _Section(
                      title: 'Payment Method',
                      child: Column(
                        children: [
                          RadioListTile(
                            value: PaymentMethod.cod,
                            groupValue: _method,
                            onChanged: (v) => setState(() => _method = v!),
                            title: const Text('Cash on Delivery'),
                            subtitle: const Text('Pay when your order arrives'),
                          ),
                          RadioListTile(
                            value: PaymentMethod.online,
                            groupValue: _method,
                            onChanged: (v) => setState(() => _method = v!),
                            title: const Text('UPI'),
                            subtitle: const Text(
                              'Pay via UPI app (QR or UPI ID)',
                            ),
                          ),
                          if (_method == PaymentMethod.online)
                            _buildUpiOptions(context),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== Order Summary =====
                    _Section(
                      title: 'Order Summary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final l in lines)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.title),
                              trailing: Text(
                                'x${l.qty}  ₹${(l.price * l.qty).toStringAsFixed(2)}',
                              ),
                            ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '₹ ${cart.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Place Order =====
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _onMakePayment,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Place Your Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Single, non-editable summary card for user details
  Widget _shippingSummaryCard() {
    final addrFull = [
      if (_addr1.isNotEmpty) _addr1,
      if (_addr2.isNotEmpty) _addr2,
      '$kConstCity, $kConstState - $kConstPincode',
    ].join('\n');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Phone
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _name.isEmpty ? 'Customer' : _name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      _phone.isEmpty ? '' : '+91 $_phone',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Address lines + city/state/pincode
                Text(addrFull, style: const TextStyle(height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPI options WITHOUT any links or app launches (per new UPI risk policy)
  Widget _buildUpiOptions(BuildContext context) {
    final cart = context.read<CartProvider>();
    final amount = cart.total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        SegmentedButton<UpiMode>(
          segments: const [
            ButtonSegment(value: UpiMode.qr, label: Text('QR')),
            ButtonSegment(value: UpiMode.upiId, label: Text('UPI ID')),
          ],
          selected: <UpiMode>{_upiMode},
          onSelectionChanged: (s) => setState(() => _upiMode = s.first),
        ),
        const SizedBox(height: 12),

        // --- QR Mode ---
        if (_upiMode == UpiMode.qr) ...[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/fps_QR.jpeg',
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan with any UPI app to pay ₹${amount.toStringAsFixed(2)} to $kMerchantName',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const _LabeledRow(
            label: 'UPI ID',
            value: kMerchantVpa,
            copyable: true,
          ),
        ],

        // --- UPI ID Mode ---
        if (_upiMode == UpiMode.upiId) ...[
          const _LabeledRow(
            label: 'UPI ID',
            value: kMerchantVpa,
            copyable: true,
          ),
          const SizedBox(height: 6),
          Text(
            'Use any UPI app and pay to the UPI ID above. No in-app launch.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ],
    );
  }

  Future<void> _onMakePayment() async {
    // Manual sanity checks (no editable fields)
    if ((_name.trim().isEmpty) ||
        (_phone.trim().length < 10) ||
        (_addr1.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Missing profile details. Please add name/phone/address in your account.',
          ),
        ),
      );
      return;
    }

    final cart = context.read<CartProvider>();
    if (cart.lines.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() => _loading = true);

    try {
      final payload = _buildOrderPayload(
        paymentMethod: _method == PaymentMethod.cod ? 'COD' : 'ONLINE',
        name: _name.trim(),
        phone: _phone.trim(),
        addr1: _addr1.trim(),
        addr2: _addr2.trim(),
        city: kConstCity,
        state: kConstState,
        pincode: kConstPincode,
        cart: cart,
      );

      if (_method == PaymentMethod.cod) {
        final ok = await _createOrder(payload);
        if (!ok) throw Exception('Failed to place COD order.');
        if (!mounted) return;
        cart.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order placed (COD).')));
        Navigator.pop(context);
        return;
      }

      // === UPI (NO GATEWAY / NO LINKS / NO VERIFICATION) ===
      // 1) Create order first to get order id + amount.
      final createRes = await _createOrderAndGetId(payload);
      if (createRes == null) throw Exception('Failed to create UPI order.');
      final orderId = createRes.orderId;
      final amount = createRes.amount;

      // 2) DO NOT open any UPI intent or show URLs.
      // 3) Immediately finish (manual verification by shopkeeper).
      if (!mounted) return;
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #$orderId placed (UPI). Please pay ₹${amount.toStringAsFixed(2)} to $kMerchantVpa. We will verify payment on call.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- Helpers ---

  Map<String, dynamic> _buildOrderPayload({
    required String paymentMethod,
    required String name,
    required String phone,
    required String addr1,
    required String addr2,
    required String city,
    required String state,
    required String pincode,
    required CartProvider cart,
  }) {
    final items = cart.lines.values
        .map((l) => {'product_id': l.productId, 'quantity': l.qty})
        .toList();

    return {
      'payment_method': paymentMethod, // 'COD' or 'UPI'
      'shipping_name': name,
      'shipping_phone': phone,
      'address_line1': addr1,
      'address_line2': addr2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'items': items,
    };
  }

  // ---------- Networking helpers ----------
  Future<Map<String, String>> _authJsonHeaders() async {
    final token = await _readAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please log in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    };
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

  Future<bool> _createOrder(Map<String, dynamic> payload) async {
    try {
      final headers = await _authJsonHeaders();
      final res = await http.post(
        Uri.parse(kApiBase),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200 || res.statusCode == 201) return true;

      debugPrint('Create COD order failed: ${res.statusCode} ${res.body}');
      final msg = _extractErrorMessage(res.body) ?? 'HTTP ${res.statusCode}';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Create order failed: $msg')));
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auth/Network error: $e')));
      }
      return false;
    }
  }

  Future<_OrderCreateRes?> _createOrderAndGetId(
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _authJsonHeaders();
      final res = await http.post(
        Uri.parse(kApiBase),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        debugPrint('Create UPI order failed: ${res.statusCode} ${res.body}');
        final msg = _extractErrorMessage(res.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Create UPI order failed: ${msg ?? res.statusCode}',
              ),
            ),
          );
        }
        return null;
      }
      final data = jsonDecode(res.body);
      final id = data['id'] ?? data['order_id'];
      final amount = (data['total_amount'] ?? data['amount'] ?? 0).toDouble();
      return _OrderCreateRes(
        orderId: id is int ? id : int.tryParse(id.toString()) ?? 0,
        amount: amount,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auth/Network error: $e')));
      }
      return null;
    }
  }
}

class _OrderCreateRes {
  final int orderId;
  final double amount;
  _OrderCreateRes({required this.orderId, required this.amount});
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  const _LabeledRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('$label: $value')),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Copied')));
              }
            },
          ),
      ],
    );
  }
}
