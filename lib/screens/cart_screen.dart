import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder:
            (context, index) => Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text('Cart Item ${index + 1}'),
                subtitle: const Text('Quantity: 1'),
                trailing: const Text('₹ 100'),
              ),
            ),
      ),
    );
  }
}
