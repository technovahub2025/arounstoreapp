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

  void clear() {
    _orders.clear();
    notifyListeners();
  }
}
