import 'dart:convert';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProductController {
  static const String apiUrl = 'https://aroun-shopping-website-ysi0.onrender.com/api/products';
  static const String _productCacheKey = 'products_cache_v1';
  static const String _productCacheTimeKey = 'products_cache_time_v1';
  static const Duration _productCacheTtl = Duration(minutes: 2);
  static Future<List<Product>>? _productsRequest;
  
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
    // Reuse a fresh response across screens, and share concurrent requests.
    final cached = await _readCachedProducts();
    if (cached != null && cached.isFresh) return cached.products;
    final existingRequest = _productsRequest;
    if (existingRequest != null) return existingRequest;

    final request = _fetchProductsFromApi(cached?.products);
    _productsRequest = request;
    try {
      return await request;
    } finally {
      if (identical(_productsRequest, request)) _productsRequest = null;
    }
  }

  Future<List<Product>> _fetchProductsFromApi(List<Product>? staleProducts) async {
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
        
        final products = jsonList
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        await _writeCachedProducts(response.body);
        return products;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        if (kDebugMode) {
          print('Authentication failed for products API');
        }
        
        // You can trigger logout if needed
        // _authManager?.logout();
        
        return staleProducts ?? [];
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return staleProducts ?? [];
      }
    } catch (e) {
      debugPrint('Network error: $e');
      return staleProducts ?? [];
    }
  }

  Future<_CachedProducts?> _readCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final body = prefs.getString(_productCacheKey);
      final cachedAt = prefs.getInt(_productCacheTimeKey);
      if (body == null || cachedAt == null) return null;
      final decoded = json.decode(body) as List<dynamic>;
      final products = decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
      return _CachedProducts(
        products,
        age >= 0 && age < _productCacheTtl.inMilliseconds,
      );
    } catch (e) {
      debugPrint('Could not read product cache: $e');
      return null;
    }
  }

  Future<void> _writeCachedProducts(String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_productCacheKey, body);
      await prefs.setInt(
        _productCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Could not save product cache: $e');
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

class _CachedProducts {
  final List<Product> products;
  final bool isFresh;

  const _CachedProducts(this.products, this.isFresh);
}
