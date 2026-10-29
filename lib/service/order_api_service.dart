import 'dart:convert';

import 'package:arunstore/config/app_env.dart';
import 'package:http/http.dart' as http;

class OrderApiService {
  const OrderApiService._();

  static Future<void> cancelOrder({
    required String orderId,
    required String reason,
    required String authToken,
  }) async {
    final token = authToken.replaceFirst(RegExp(r'^Bearer\s+'), '').trim();
    final response = await http.patch(
      Uri.parse('${AppEnv.ordersBaseUrl}/$orderId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'x-access-token': token,
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'Could not cancel this order. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          message = (decoded['message'] ?? decoded['error'] ?? message).toString();
        }
      } catch (_) {
        if (response.body.trim().isNotEmpty) message = response.body;
      }
      throw Exception(message);
    }
  }
}
