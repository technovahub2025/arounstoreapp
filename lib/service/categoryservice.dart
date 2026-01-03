import 'dart:convert';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';


class ProductController {
  static const String apiUrl = 'https://aroun-shopping-website-a2he.onrender.com/api/products';
  
  // Add AuthManager reference
  AuthManager? _authManager;
  
  // Constructor that accepts AuthManager
  ProductController({AuthManager? authManager}) {
    _authManager = authManager;
  }
  
  // Helper method to get token
  String? _getToken() {
    // If AuthManager was provided, use it
    if (_authManager != null) {
      return _authManager!.token;
    }
    // Otherwise, use the singleton instance
    return AuthManager().token;
  }
  
  // Helper method to get headers with authentication
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      
      if (kDebugMode) {
        print('Adding token to request headers');
        print('Token length: ${token.length}');
      }
    } else {
      if (kDebugMode) {
        print('No token available for request');
      }
    }
    
    return headers;
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getHeaders(), // Use headers with auth
      );
      
      if (kDebugMode) {
        print('Products API Status: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('Error response: ${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        if (kDebugMode) {
          print('Products fetched: ${jsonList.length}');
        }
        
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        if (kDebugMode) {
          print('Authentication failed for products API');
        }
        
        // You can trigger logout if needed
        // _authManager?.logout();
        
        return [];
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Network error: $e');
      return [];
    }
  }

  // Group products by category
  Future<Map<String, List<Product>>> fetchProductsByCategory() async {
    try {
      List<Product> products = await fetchProducts();
      
      Map<String, List<Product>> categoryMap = {};

      for (var product in products) {
        String category = product.category?.trim() ?? 'Uncategorized';
        
        if (category.isEmpty) {
          category = 'Uncategorized';
        }
        
        categoryMap.putIfAbsent(category, () => []).add(product);
      }

      if (kDebugMode) {
        print('Categories found: ${categoryMap.length}');
      }

      return categoryMap;
    } catch (e) {
      debugPrint('Error categorizing products: $e');
      return {};
    }
  }
  
  // Add other product operations that need authentication
  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$id'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Product.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }
  
}