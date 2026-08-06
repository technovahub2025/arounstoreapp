import 'dart:convert';

import 'package:http/http.dart' as http;

class RazorpayOrderResult {
  final String orderId;
  final int amount;
  final String currency;
  final Map<String, dynamic> raw;

  const RazorpayOrderResult({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.raw,
  });

  factory RazorpayOrderResult.fromResponse(Map<String, dynamic> response) {
    final order = _extractOrderMap(response);
    final orderId = (order['id'] ?? order['order_id'] ?? order['razorpay_order_id'] ?? '').toString();
    final amount = (order['amount'] ?? response['amount'] ?? 0) is int
        ? (order['amount'] ?? response['amount'] ?? 0) as int
        : int.tryParse((order['amount'] ?? response['amount'] ?? 0).toString()) ?? 0;
    final currency = (order['currency'] ?? response['currency'] ?? 'INR').toString();

    if (orderId.isEmpty) {
      throw const FormatException('Backend response did not include a Razorpay order id.');
    }

    return RazorpayOrderResult(
      orderId: orderId,
      amount: amount,
      currency: currency,
      raw: response,
    );
  }
}

class RazorpayPaymentVerification {
  final bool success;
  final String message;
  final Map<String, dynamic> raw;

  const RazorpayPaymentVerification({
    required this.success,
    required this.message,
    required this.raw,
  });

  factory RazorpayPaymentVerification.fromResponse(Map<String, dynamic> response) {
    final success = response['success'] == true ||
        response['verified'] == true ||
        response['status'] == 'success';
    final message = (response['message'] ?? response['status'] ?? 'Payment verification completed.')
        .toString();

    return RazorpayPaymentVerification(
      success: success,
      message: message,
      raw: response,
    );
  }
}

Map<String, dynamic> _extractOrderMap(Map<String, dynamic> response) {
  final order = response['order'];
  if (order is Map<String, dynamic>) return order;

  final data = response['data'];
  if (data is Map<String, dynamic>) {
    final nestedOrder = data['order'];
    if (nestedOrder is Map<String, dynamic>) return nestedOrder;
  }

  return response;
}

class RazorpayService {
  const RazorpayService._();

  static const String paymentBaseUrl =
      'https://aroun-shopping-website-a2he.onrender.com/api/payment';
  static const String defaultCreateOrderUrl = paymentBaseUrl;
  static const String defaultVerifyUrl = '$paymentBaseUrl/verify';

  static Map<String, String> _headers({String? authToken}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': authToken.startsWith('Bearer ') ? authToken : 'Bearer $authToken',
    };
  }

  static Future<RazorpayOrderResult> createOrder({
    required String endpoint,
    required int amount,
    required String currency,
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> shippingDetails,
    String? authToken,
  }) async {
    final payload = jsonEncode({
      'amount': amount,
      'currency': currency,
      'cartItems': cartItems,
      'shippingDetails': shippingDetails,
    });

    final endpoints = _candidateCreateOrderEndpoints(endpoint);
    Object? lastError;

    for (final candidate in endpoints) {
      final response = await http.post(
        Uri.parse(candidate),
        headers: _headers(authToken: authToken),
        body: payload,
      );

      final decoded = _decodeJson(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid order response received from backend.');
        }

        return RazorpayOrderResult.fromResponse(decoded);
      }

      lastError = _extractErrorMessage(
        decoded,
        response.statusCode,
        'Failed to create payment order',
      );

      if (response.statusCode != 404) {
        break;
      }
    }

    throw Exception(lastError ?? 'Failed to create payment order');
  }

  static Future<RazorpayPaymentVerification> verifyPayment({
    required String endpoint,
    required Map<String, dynamic> payload,
    String? authToken,
  }) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: _headers(authToken: authToken),
      body: jsonEncode(payload),
    );

    final decoded = _decodeJson(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(decoded, response.statusCode, 'Failed to verify payment'));
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid verification response received from backend.');
    }

    return RazorpayPaymentVerification.fromResponse(decoded);
  }

  static dynamic _decodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  static String _extractErrorMessage(dynamic decoded, int statusCode, String fallback) {
    if (decoded is Map<String, dynamic>) {
      return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
    }

    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded;
    }

    return '$fallback ($statusCode)';
  }
}

List<String> _candidateCreateOrderEndpoints(String endpoint) {
  final candidates = <String>[endpoint];

  try {
    final uri = Uri.parse(endpoint);
    final path = uri.path;

    if (path.endsWith('/create-order')) {
      candidates.add(uri.replace(path: path.replaceFirst('/create-order', '')).toString());
    } else if (path.endsWith('/payment')) {
      candidates.add(uri.replace(path: '$path/create-order').toString());
    }
  } catch (_) {
    if (endpoint.endsWith('/create-order')) {
      candidates.add(endpoint.replaceFirst('/create-order', ''));
    } else if (endpoint.endsWith('/payment')) {
      candidates.add('$endpoint/create-order');
    }
  }

  return candidates.toSet().toList();
}

Map<String, dynamic> buildShippingPayload({
  required String fullName,
  required String email,
  required String phone,
  required String addressLine1,
  required String addressLine2,
  required String city,
  required String state,
  required String pincode,
  required String country,
}) {
  return {
    'customer': {
      'name': fullName,
      'email': email,
      'contact': phone,
    },
    'shippingAddress': {
      'line1': addressLine1,
      'line2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    },
  };
}
