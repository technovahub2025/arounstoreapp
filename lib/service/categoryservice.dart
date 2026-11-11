import 'dart:convert';

import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  static const String apiUrl =
      'https://aroun-shopping-website-5nnj.onrender.com/api/products';
  static const int pageSize = 20;
  static const Duration _cacheTtl = Duration(minutes: 2);
  static final Map<String, Future<ProductPage>> _requests = {};

  final AuthManager? _authManager;
  ProductController({AuthManager? authManager}) : _authManager = authManager;

  Map<String, String> _headers() {
    final token = _authManager?.token ?? AuthManager().token;
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ProductPage> fetchProductPage({
    String? cursor,
    String search = '',
    String? category,
    List<String>? categories,
    int limit = pageSize,
    bool forceRefresh = false,
  }) async {
    final normalizedSearch = search.trim();
    final params = <String, String>{'limit': '$limit'};
    if (normalizedSearch.isNotEmpty) params['search'] = normalizedSearch;
    final categoryFilters = (categories ?? [if (category != null) category])
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (categoryFilters.isNotEmpty) {
      params['categories'] = jsonEncode(categoryFilters);
    }
    if (cursor != null && cursor.isNotEmpty) params['cursor'] = cursor;

    // The full query and cursor identify both persistent cache entries and
    // in-flight requests, so different searches can never share a page.
    final cacheIdentity = jsonEncode(params);
    final cacheKey = 'catalog_page_${base64Url.encode(utf8.encode(cacheIdentity))}';
    if (!forceRefresh) {
      final cached = await _readCachedPage(cacheKey);
      if (cached != null && cached.isFresh) return cached.page;
    }
    final requestKey = '$apiUrl/catalog?$cacheIdentity';
    final existing = _requests[requestKey];
    if (existing != null) return existing;

    final request = _fetchPage(params, cacheKey);
    _requests[requestKey] = request;
    try {
      return await request;
    } finally {
      if (identical(_requests[requestKey], request)) _requests.remove(requestKey);
    }
  }

  Future<ProductPage> _fetchPage(
    Map<String, String> params,
    String cacheKey,
  ) async {
    try {
      final uri = Uri.parse('$apiUrl/catalog').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode != 200) {
        throw ProductApiException(response.statusCode, response.body);
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rawItems = decoded['items'];
      if (rawItems is! List) throw const FormatException('Missing catalogue items');
      final products = rawItems
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
      final hasMore = decoded['hasMore'] == true;
      final nextCursor = decoded['nextCursor']?.toString();
      if (hasMore && (nextCursor == null || nextCursor.isEmpty)) {
        throw const FormatException('Catalogue did not return its next cursor');
      }
      final page = ProductPage(
        products: products,
        hasMore: hasMore,
        nextCursor: nextCursor,
        total: decoded['total'] is num ? (decoded['total'] as num).toInt() : null,
      );
      await _writeCachedPage(cacheKey, page);
      return page;
    } catch (error) {
      debugPrint('Catalogue request failed: $error');
      // Offline fallback is limited to the same exact query/cursor cache.
      final stale = await _readCachedPage(cacheKey);
      if (stale != null) return stale.page;
      rethrow;
    }
  }

  Future<Map<String, int>> fetchCategoryCounts() async {
    final response = await http.get(
      Uri.parse('$apiUrl/catalog-facets'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw ProductApiException(response.statusCode, response.body);
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rows = decoded['categories'];
    if (rows is! List) return const {};
    return {
      for (final row in rows.whereType<Map<String, dynamic>>())
        (row['name']?.toString().trim().isNotEmpty == true
                ? row['name'].toString()
                : 'Uncategorized'):
            (row['count'] as num?)?.toInt() ?? 0,
    };
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'), headers: _headers());
      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      debugPrint('Product detail request failed: ${response.statusCode}');
      return null;
    } catch (error) {
      debugPrint('Product detail request failed: $error');
      return null;
    }
  }

  Future<_CachedPage?> _readCachedPage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final products = (decoded['products'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
      final cachedAt = decoded['cachedAt'] as int? ?? 0;
      final page = ProductPage(
        products: products,
        hasMore: decoded['hasMore'] == true,
        nextCursor: decoded['nextCursor']?.toString(),
        total: decoded['total'] as int?,
      );
      final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
      return _CachedPage(page, age >= 0 && age < _cacheTtl.inMilliseconds);
    } catch (error) {
      debugPrint('Could not read catalogue cache: $error');
      return null;
    }
  }

  Future<void> _writeCachedPage(String key, ProductPage page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode({
        'products': page.products.map((product) => product.toJson()).toList(),
        'hasMore': page.hasMore,
        'nextCursor': page.nextCursor,
        'total': page.total,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      }));
    } catch (error) {
      debugPrint('Could not save catalogue cache: $error');
    }
  }

  Future<List<Product>> fetchProducts() async =>
      (await fetchProductPage()).products;

  Future<Map<String, List<Product>>> fetchProductsByCategory() async {
    final products = await fetchProducts();
    final groups = <String, List<Product>>{};
    for (final product in products) {
      final name = product.category?.trim();
      groups.putIfAbsent(name == null || name.isEmpty ? 'Uncategorized' : name, () => [])
          .add(product);
    }
    return groups;
  }
}

/// Shared cursor state for the mobile and dashboard home screens.
class ProductCatalogSession {
  ProductCatalogSession(this.controller);
  final ProductController controller;
  final List<Product> products = [];
  final Map<String, List<Product>> categories = {};
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = false;
  String? error;
  String? _cursor;
  String _search = '';
  List<String> _categories = const [];
  int _generation = 0;
  String get searchQuery => _search;

  void invalidatePending() {
    _generation++;
  }

  Future<void> reloadFirst() => loadFirst(search: _search, categories: _categories);

  Future<void> loadFirst({String search = '', List<String> categories = const []}) async {
    final generation = ++_generation;
    _search = search.trim();
    _categories = List.unmodifiable(categories);
    _cursor = null;
    products.clear();
    this.categories.clear();
    loading = true;
    loadingMore = false;
    hasMore = false;
    error = null;
    try {
      final page = await controller.fetchProductPage(search: _search, categories: _categories);
      if (generation != _generation) return;
      _append(page.products);
      _cursor = page.nextCursor;
      hasMore = page.hasMore;
    } catch (e) {
      if (generation == _generation) error = 'Failed to load products. Please try again.';
    } finally {
      if (generation == _generation) loading = false;
    }
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasMore || _cursor == null) return;
    final generation = _generation;
    loadingMore = true;
    error = null;
    try {
      final page = await controller.fetchProductPage(
        cursor: _cursor,
        search: _search,
        categories: _categories,
      );
      if (generation != _generation) return;
      _append(page.products);
      _cursor = page.nextCursor;
      hasMore = page.hasMore;
    } catch (e) {
      if (generation == _generation) error = 'Could not load more products. Please retry.';
    } finally {
      if (generation == _generation) loadingMore = false;
    }
  }

  void _append(Iterable<Product> incoming) {
    final ids = products.map((product) => product.id).whereType<String>().toSet();
    for (final product in incoming) {
      if (product.id != null && !ids.add(product.id!)) continue;
      products.add(product);
      final name = product.category?.trim();
      categories.putIfAbsent(name == null || name.isEmpty ? 'Uncategorized' : name, () => [])
          .add(product);
    }
  }
}

class ProductPage {
  final List<Product> products;
  final bool hasMore;
  final String? nextCursor;
  final int? total;
  const ProductPage({
    required this.products,
    required this.hasMore,
    this.nextCursor,
    this.total,
  });
}

class ProductApiException implements Exception {
  final int statusCode;
  final String body;
  const ProductApiException(this.statusCode, this.body);
  @override
  String toString() => 'Product API returned $statusCode';
}

class _CachedPage {
  final ProductPage page;
  final bool isFresh;
  const _CachedPage(this.page, this.isFresh);
}
