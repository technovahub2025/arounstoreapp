import 'package:arunstore/model/cartmodel.dart';
import 'package:flutter/foundation.dart';

class CompletedOrder {
  final String orderId;
  final String paymentId;
  final String? signature;
  final String customerName;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final DateTime createdAt;
  final bool paymentSuccessful;
  final String paymentStatus;

  const CompletedOrder({
    required this.orderId,
    required this.paymentId,
    required this.signature,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.createdAt,
    this.paymentSuccessful = true,
    this.paymentStatus = 'Successful',
  });
}

class OrderHistoryService extends ChangeNotifier {
  OrderHistoryService._();

  static final OrderHistoryService instance = OrderHistoryService._();

  final List<CompletedOrder> _orders = [];

  List<CompletedOrder> get orders => List.unmodifiable(_orders);

  CompletedOrder? get latestOrder => _orders.isEmpty ? null : _orders.first;

  void addOrder(CompletedOrder order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void addCanceledPayment({
    required List<CartItem> items,
    required double subtotal,
    required double shipping,
    required double total,
    required String customerName,
    String status = 'Canceled',
  }) {
    _orders.insert(0, CompletedOrder(
      orderId: 'Pending',
      paymentId: '—',
      signature: null,
      customerName: customerName,
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      createdAt: DateTime.now(),
      paymentSuccessful: false,
      paymentStatus: status,
    ));
    notifyListeners();
  }

  void clear() {
    _orders.clear();
    notifyListeners();
  }
}
