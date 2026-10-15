import 'dart:convert';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProductController {
  static const String apiUrl = 'https://aroun-shopping-website-ysi0.onrender.com/api/products';
  static const Duration _productCacheTtl = Duration(minutes: 2);
  static const int pageSize = 20;
  static final Map<int, Future<ProductPage>> _productRequests = {};
  
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

  Future<ProductPage> fetchProductPage({int page = 1}) async {
    final cached = await _readCachedPage(page);
    if (cached != null && cached.isFresh) return cached.page;
    final existingRequest = _productRequests[page];
    if (existingRequest != null) return existingRequest;
    final request = _fetchPageFromApi(page, cached?.page);
    _productRequests[page] = request;
    try {
      return await request;
    } finally {
      if (identical(_productRequests[page], request)) _productRequests.remove(page);
    }
  }

  Future<ProductPage> _fetchPageFromApi(int page, ProductPage? stalePage) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl).replace(queryParameters: {'page': '$page', 'limit': '$pageSize'}),
        headers: _getHeaders(), // Use headers with auth
      );
      
      if (kDebugMode) {
        print('Products API Status: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('Error response: ${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> rawProducts = decoded is List
            ? decoded
            : (decoded['products'] ?? decoded['data'] ?? decoded['items']) as List<dynamic>;
        final allProducts = rawProducts
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        final start = (page - 1) * pageSize;
        final products = decoded is List && allProducts.length > pageSize
            ? allProducts.skip(start).take(pageSize).toList()
            : allProducts;
        final hasMore = decoded is Map<String, dynamic>
            ? (decoded['hasMore'] as bool? ??
                (decoded['totalPages'] is num
                    ? page < (decoded['totalPages'] as num).toInt()
                    : products.length == pageSize))
            : decoded is List && allProducts.length > pageSize
                ? start + products.length < allProducts.length
                : products.length == pageSize;
        if (kDebugMode) {
          print('Products fetched for page $page: ${products.length}');
        }
        final result = ProductPage(products: products, hasMore: hasMore);
        await _writeCachedPage(page, result);
        return result;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        if (kDebugMode) {
          print('Authentication failed for products API');
        }
        
        // You can trigger logout if needed
        // _authManager?.logout();
        
        return stalePage ?? const ProductPage(products: [], hasMore: false);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return stalePage ?? const ProductPage(products: [], hasMore: false);
      }
    } catch (e) {
      debugPrint('Network error: $e');
      return stalePage ?? const ProductPage(products: [], hasMore: false);
    }
  }

  Future<_CachedPage?> _readCachedPage(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final body = prefs.getString('products_page_$page');
      final cachedAt = prefs.getInt('products_page_time_$page');
      if (body == null || cachedAt == null) return null;
      final decoded = json.decode(body) as Map<String, dynamic>;
      final products = (decoded['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
      final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
      return _CachedPage(
        ProductPage(products: products, hasMore: decoded['hasMore'] as bool),
        age >= 0 && age < _productCacheTtl.inMilliseconds,
      );
    } catch (e) {
      debugPrint('Could not read product cache: $e');
      return null;
    }
  }

  Future<void> _writeCachedPage(int page, ProductPage result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('products_page_$page', json.encode({
        'products': result.products.map((product) => product.toJson()).toList(),
        'hasMore': result.hasMore,
      }));
      await prefs.setInt(
        'products_page_time_$page',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Could not save product cache: $e');
    }
  }

  Future<List<Product>> fetchProducts() async =>
      (await fetchProductPage()).products;

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

class ProductPage {
  final List<Product> products;
  final bool hasMore;

  const ProductPage({required this.products, required this.hasMore});
}

class _CachedPage {
  final ProductPage page;
  final bool isFresh;

  const _CachedPage(this.page, this.isFresh);
}
