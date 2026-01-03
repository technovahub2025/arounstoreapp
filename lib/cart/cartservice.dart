import 'package:flutter/material.dart';
import 'package:arunstore/cart/cartscreen.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cart = CartManager.instance;
  double subtotal = 0.0;

  @override
  void initState() {
    super.initState();
    subtotal = cart.subTotal.toDouble();
  }

  void updateSubtotal(double delta) {
    setState(() {
      subtotal += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Cartscreen(
                        product: item.product,
                        initialQuantity: item.quantity,
                        onRemove: () {
                          setState(() {
                            cart.remove(item.product);
                            subtotal = cart.subTotal.toDouble();
                          });
                        },
                        onQuantityChanged: updateSubtotal,
                      );
                    },
                  ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _bottomBar() {
  final shipping = 10.0;
  final total = (subtotal + shipping).clamp(0.0, double.infinity);
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
    ),
    child: Column(
      children: [
        _row('Subtotal', subtotal),
        _row('Shipping', shipping),
        const Divider(),
        _row('Total', total, bold: true),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, 
              padding: const EdgeInsets.symmetric(vertical: 14)
            ),
            onPressed: cart.items.isEmpty ? null : () {
           
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const CheckoutScreen())
              );
            },
            child: const Text(
              'Proceed to Checkout', 
              style: TextStyle(color: Colors.white)
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _row(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text('₹${value.toStringAsFixed(2)}', style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
      ],
    );
  }
}
