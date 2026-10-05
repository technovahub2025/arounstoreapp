import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/cart/cartscreen.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/checkout.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cart = CartManager.instance;

  @override
  void initState() {
    super.initState();
    cart.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    cart.removeListener(_onCartChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: AppText('Cart is empty'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Cartscreen(
                        key: ValueKey(item.product.id),
                        product: item.product,
                        initialQuantity: item.quantity,
                        onRemove: () => cart.remove(item.product),
                        onQuantityChanged: (quantity) =>
                            cart.updateQuantity(item.product, quantity),
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
    final total = cart.total.toDouble();
    final subtotal = cart.subTotal.toDouble();
    final shipping = total - subtotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface(Colors.white),
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
                backgroundColor: context.appSurface(Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
              child: AppText(
                'Proceed to Checkout',
                style: TextStyle(color: context.appForeground(Colors.white)),
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
        Expanded(child: AppText(label)),
        AppText(
          'INR ${value.toStringAsFixed(2)}',
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    );
  }
}
