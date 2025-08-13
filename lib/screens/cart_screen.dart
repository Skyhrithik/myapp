import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/checkout_screen.dart';
import '../providers/provider.dart';
// If you already created a PaymentScreen (Razorpay etc.), import it here.
// import '../screens/payment_screen.dart';

enum PaymentMethod { cod, online }

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final lines = cart.lines.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: lines.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final l = lines[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text(l.title),
                    subtitle: Text('₹ ${l.price.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 160,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cart.removeOne(l.productId),
                          ),
                          Text(
                            '${l.qty}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cart.addById(l.productId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => cart.removeAll(l.productId),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Total: ₹ ${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: lines.isEmpty
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    ),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCheckout(BuildContext context) async {
    final method = await _showPaymentOptions(context);
    if (method == null) return;

    switch (method) {
      case PaymentMethod.cod:
        // TODO: Replace this with your COD confirm API call.
        // e.g. await api.confirmCod(orderId)
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('COD selected')));
          // Optionally: clear cart and go to success page
          // context.read<CartProvider>().clear();
          // Navigator.pushNamed(context, '/order-success');
        }
        break;

      case PaymentMethod.online:
        // If you have a PaymentScreen (Razorpay), navigate to it here:
        // final cart = context.read<CartProvider>();
        // final amountInPaise = (cart.total * 100).round();
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => PaymentScreen(
        //     orderId: /* create/get draft order id */,
        //     amountInPaise: amountInPaise,
        //     authToken: /* your token if needed */,
        //   ),
        // ));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Online payment selected')),
          );
        }
        break;
    }
  }

  Future<PaymentMethod?> _showPaymentOptions(BuildContext context) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Select Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delivery_dining_outlined),
                title: const Text('Cash on Delivery'),
                subtitle: const Text('Pay when you receive your order'),
                onTap: () => Navigator.pop(context, PaymentMethod.cod),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('UPI / Card (Online)'),
                subtitle: const Text('Pay securely via UPI, cards, or wallets'),
                onTap: () => Navigator.pop(context, PaymentMethod.online),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your cart is empty', style: TextStyle(fontSize: 16)),
    );
  }
}
