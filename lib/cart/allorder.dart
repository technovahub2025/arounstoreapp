
import 'package:arunstore/cart/order.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:flutter/material.dart';

class Allorder extends StatefulWidget {
  Allorder({super.key});

  @override
  State<Allorder> createState() => _CartPageState();
}

class _CartPageState extends State<Allorder> {
  final cart = CartManager.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Order')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Order  is empty'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return orderscreen(
                        product: item.product,
                        quantity: item.quantity,
                       
                        
                     
                      );
                    },
                  ),
          ),

          /// TOTAL + CHECKOUT
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black12),
        ],
      ),
      child: Column(
        children: [
          _row('Subtotal', cart.subTotal),
          _row('Shipping', 10),
          const Divider(),
          _row('Total', cart.total, bold: true),
          const SizedBox(height: 12),
          
        ],
      ),
    );
  }

  Widget _row(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '₹$value',
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    );
  }
}
