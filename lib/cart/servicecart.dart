import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static Future<void> saveCart(String userId, List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart_$userId', jsonEncode(cartItems));
  }

  static Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_$userId');
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  static Future<void> clearCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('cart_$userId');
  }
}
