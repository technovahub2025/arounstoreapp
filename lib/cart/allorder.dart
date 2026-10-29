import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/cart/order.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/service/order_api_service.dart';
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
  final Set<String> _cancelingOrderIds = {};

  Future<void> _cancelOrder(CompletedOrder order) async {
    final reasonController = TextEditingController(text: 'Ordered by mistake');
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Cancel order?'),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AppText('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, reasonController.text.trim()),
            child: const AppText('Cancel order'),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null || reason.isEmpty || !mounted) return;

    final token = AuthManager().token;
    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Please log in again to cancel your order.')),
      );
      return;
    }

    setState(() => _cancelingOrderIds.add(order.orderId));
    try {
      await OrderApiService.cancelOrder(
        orderId: order.orderId,
        reason: reason,
        authToken: token,
      );
      orderHistory.markOrderCancelled(order.orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Order cancelled successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _cancelingOrderIds.remove(order.orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([cart, orderHistory]),
      builder: (context, _) {
        final orders = orderHistory.orders;

        return Scaffold(
          appBar: AppBar(title: const AppText('Your Order')),
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
            color: context.appSurface(Colors.white),
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
              AppText(
                order.paymentSuccessful ? 'Payment successful' : 'Payment ${order.paymentStatus.toLowerCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.appForeground(order.paymentSuccessful ? Colors.green.shade700 : Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 8),
              AppText('Order ID: ${order.orderId}'),
              AppText('Order status: ${order.orderStatus}'),
              if (order.paymentSuccessful) AppText('Payment ID: ${order.paymentId}'),
              AppText('Placed on: ${order.createdAt}'),
              const SizedBox(height: 12),
              _summaryRow('Subtotal', order.subtotal),
              _summaryRow('Shipping', order.shipping),
              const Divider(),
              _summaryRow('Total', order.total, bold: true),
              const SizedBox(height: 14),
              const AppText(
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
              if (order.paymentSuccessful && order.orderStatus.toLowerCase() != 'cancelled') ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _cancelingOrderIds.contains(order.orderId)
                        ? null
                        : () => _cancelOrder(order),
                    icon: _cancelingOrderIds.contains(order.orderId)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: AppText(_cancelingOrderIds.contains(order.orderId)
                        ? 'Cancelling...'
                        : 'Cancel order'),
                  ),
                ),
              ],
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
              ? const Center(child: AppText('Order is empty'))
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
      decoration:  BoxDecoration(
        color: context.appSurface(Colors.white),
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
        AppText(label),
        AppText(
          'INR ${value.toStringAsFixed(2)}',
          style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    );
  }
}
