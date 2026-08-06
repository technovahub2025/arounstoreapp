import 'package:arunstore/cart/order.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/service/order_history_service.dart';
import 'package:flutter/material.dart';

class Allorder extends StatefulWidget {
  const Allorder({super.key});

  @override
  State<Allorder> createState() => _AllorderState();
}

class _AllorderState extends State<Allorder> {
  final cart = CartManager.instance;
  final orderHistory = OrderHistoryService.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([cart, orderHistory]),
      builder: (context, _) {
        final orders = orderHistory.orders;

        return Scaffold(
          appBar: AppBar(title: const Text('Your Order')),
          body: orders.isNotEmpty ? _buildOrderHistory(orders) : _buildCartFallback(),
        );
      },
    );
  }

  Widget _buildOrderHistory(List<CompletedOrder> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order confirmed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text('Order ID: ${order.orderId}'),
              Text('Payment ID: ${order.paymentId}'),
              Text('Placed on: ${order.createdAt}'),
              const SizedBox(height: 12),
              _summaryRow('Subtotal', order.subtotal),
              _summaryRow('Shipping', order.shipping),
              const Divider(),
              _summaryRow('Total', order.total, bold: true),
              const SizedBox(height: 14),
              const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => orderscreen(
                  product: item.product,
                  quantity: item.quantity,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartFallback() {
    return Column(
      children: [
        Expanded(
          child: cart.items.isEmpty
              ? const Center(child: Text('Order is empty'))
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
        _bottomBar(),
      ],
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
          _summaryRow('Subtotal', cart.subTotal.toDouble()),
          _summaryRow('Shipping', cart.total.toDouble() - cart.subTotal.toDouble()),
          const Divider(),
          _summaryRow('Total', cart.total.toDouble(), bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          'INR ${value.toStringAsFixed(2)}',
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    );
  }
}
