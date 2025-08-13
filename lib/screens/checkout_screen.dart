import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- added
import '../config/config.dart';

import '../providers/provider.dart'; // CartProvider

// === Constants you asked for ===
const kConstCity = 'Agra';
const kConstState = 'UP';
const kConstPincode = '282005';

// === UPI (replace with your merchant details) ===
// Customer pays to THIS UPI ID (your store's VPA)
const kMerchantVpa = 'paytmqr6jkklj@ptys'; // todo: put your real UPI ID
const kMerchantName = 'FPS Store';

// === API base (config-driven is better; keep it simple here) ===
const kApiBase = '${AppConfig.baseUrl}/me/orders/';
// This works because baseUrl is static const

// Optional: temporary dev token fallback while you wire login storage.
// Remove this in production.
const String? kDevTokenForDebug = 'c0a70d98a54873f784cd81f5a07a9924690674f8';

// If you use JWT, inject it via Provider or secure storage
String? getAuthToken(BuildContext context) {
  // todo: wire your auth provider / secure storage
  return null;
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

  // Prefill from profile (wire these to your Auth/Profile provider if available)
  final _nameCtrl = TextEditingController(text: 'Rohit Singh'); // from profile
  final _phoneCtrl = TextEditingController(text: '8910009475'); // from profile
  final _addr1Ctrl = TextEditingController(
    text: '123 Street',
  ); // from profile/address book
  final _addr2Ctrl = TextEditingController(text: '');

  PaymentMethod _method = PaymentMethod.cod;
  UpiMode _upiMode = UpiMode.qr;

  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    super.dispose();
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
                    _Section(
                      title: 'Shipping Details',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().length < 10)
                                ? 'Invalid phone'
                                : null,
                          ),
                          TextFormField(
                            controller: _addr1Ctrl,
                            decoration: const InputDecoration(
                              labelText: 'Address line 1',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          TextFormField(
                            controller: _addr2Ctrl,
                            decoration: const InputDecoration(
                              labelText: 'Address line 2 (optional)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Expanded(
                                child: _LockedField(
                                  label: 'City',
                                  value: kConstCity,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _LockedField(
                                  label: 'State',
                                  value: kConstState,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _LockedField(
                                  label: 'Pincode',
                                  value: kConstPincode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading
                            ? null
                            : () => _onMakePayment(context),
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

  Widget _buildUpiOptions(BuildContext context) {
    final cart = context.read<CartProvider>();
    final amount = cart.total;

    final upiUrl = _buildUpiUrl(
      payeeVpa: kMerchantVpa,
      payeeName: kMerchantName,
      amount: amount,
      note: 'Order payment',
      tr: 'ref_${DateTime.now().millisecondsSinceEpoch}', // transaction ref / order ref
    );

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
        ] else ...[
          const _LabeledRow(
            label: 'Pay to UPI ID',
            value: kMerchantVpa,
            copyable: true,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Future<void> _onMakePayment(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    if (cart.lines.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() => _loading = true);

    try {
      // Build the payload once from cart + form
      final payload = _buildOrderPayload(
        paymentMethod: _method == PaymentMethod.cod ? 'COD' : 'UPI',
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        addr1: _addr1Ctrl.text.trim(),
        addr2: _addr2Ctrl.text.trim(),
        city: kConstCity,
        state: kConstState,
        pincode: kConstPincode,
        cart: cart,
      );

      if (_method == PaymentMethod.cod) {
        final ok = await _createOrder(payload);
        if (!ok) throw Exception('Failed to place COD order.');
        if (!mounted) return;
        // success → clear cart and go success page (or show a snackbar)
        cart.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order placed (COD).')));
        Navigator.pop(context); // back to cart/home
        return;
      }

      // UPI flow:
      // 1) Create order with payment_method=UPI and status=PENDING (server side)
      final createRes = await _createOrderAndGetId(payload);
      if (createRes == null) throw Exception('Failed to create UPI order.');
      final orderId = createRes.orderId;
      final amount = createRes.amount;

      // 2) Launch UPI intent
      final upiUrl = _buildUpiUrl(
        payeeVpa: kMerchantVpa,
        payeeName: kMerchantName,
        amount: amount,
        note: 'Order #$orderId',
        tr: 'order_$orderId',
      );
      final upiResult = await _launchUpi(upiUrl);

      // 3) Parse result (best-effort; depends on UPI app)
      if (upiResult == null) {
        throw Exception('Payment cancelled or no response from UPI app.');
      }
      final status = upiResult['status']?.toString().toUpperCase() ?? 'FAILURE';
      final txnId = upiResult['txnId'] ?? upiResult['transactionId'] ?? '';

      if (status == 'SUCCESS') {
        // 4) Confirm with backend (optional but recommended)
        final ok = await _confirmUpi(orderId, txnId.toString());
        if (!ok) {
          // If server cannot verify, at least inform user
          debugPrint('WARN: Server could not verify UPI payment.');
        }
        if (!mounted) return;
        cart.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful. Order placed.')),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $status')));
      }
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

  String _buildUpiUrl({
    required String payeeVpa,
    required String payeeName,
    required double amount,
    required String note,
    required String tr, // transaction/order ref
  }) {
    final params = {
      'pa': payeeVpa,
      'pn': payeeName,
      'am': amount.toStringAsFixed(2),
      'tn': note,
      'cu': 'INR',
      'tr': tr,
    };
    final qp = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
    return 'upi://pay?$qp';
  }

  /// Launch UPI and attempt to parse callback (Android-first).
  /// Returns a Map like {status: SUCCESS|FAILURE|SUBMITTED, txnId: ..., responseCode: ...}
  Future<Map<String, String>?> _launchUpi(String upiUrl) async {
    final uri = Uri.parse(upiUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) return null;

    // Many UPI apps do NOT return to app with data reliably.
    // If your UPI PSP supports deeplink callback, handle it here.
    // For a basic flow, we can't programmatically capture result; return null.
    // If you integrate a package that supports onActivityResult, parse it.
    // As a placeholder, show a dialog to let user confirm success manually.
    if (!mounted) return null;

    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('UPI Payment'),
        content: const Text('Did the payment succeed in your UPI app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {'status': 'FAILURE'}),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, {'status': 'SUCCESS', 'txnId': ''}),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return res;
  }

  // ---------- Networking helpers (auth + requests) ----------

  Future<Map<String, String>> _authJsonHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer a token you saved at login:
    final stored = prefs.getString('token');

    // If not present yet, fall back to the provided dev token to keep you unblocked.
    final token = stored ?? kDevTokenForDebug;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
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
  }

  /// Create order and get its id & amount (for UPI)
  Future<_OrderCreateRes?> _createOrderAndGetId(
    Map<String, dynamic> payload,
  ) async {
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
            content: Text('Create UPI order failed: ${msg ?? res.statusCode}'),
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
  }

  Future<bool> _confirmUpi(int orderId, String txnId) async {
    final headers = await _authJsonHeaders();
    // Adjust this endpoint if your backend uses a different confirm path.
    // Kept separate from kApiBase to avoid accidental double "orders".
    final confirmUri = Uri.parse(
      '${AppConfig.baseUrl}/me/orders/$orderId/confirm-upi/',
    );
    final res = await http.post(
      confirmUri,
      headers: headers,
      body: jsonEncode({'txn_id': txnId}),
    );
    if (res.statusCode != 200) {
      debugPrint('UPI confirm failed: ${res.statusCode} ${res.body}');
      return false;
    }
    return true;
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

class _LockedField extends StatelessWidget {
  final String label;
  final String value;
  const _LockedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(labelText: label),
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
