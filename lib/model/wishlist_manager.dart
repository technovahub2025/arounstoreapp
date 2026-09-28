import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/foundation.dart';

class WishlistManager extends ChangeNotifier {
  WishlistManager._();
  static final WishlistManager instance = WishlistManager._();

  final Set<String> _wishlistIds = {};
  final Map<String, Product> _products = {};

  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  Map<String, Product> get products => Map.unmodifiable(_products);
  List<Product> get items => _products.values.toList();
  int get count => _wishlistIds.length;

  bool isInWishlist(Product product) {
    final id = product.id ?? product.name ?? '';
    return _wishlistIds.contains(id);
  }

  void addToWishlist(Product product) {
    final id = product.id ?? product.name ?? '';
    if (!_wishlistIds.contains(id)) {
      _wishlistIds.add(id);
      _products[id] = product;
      notifyListeners();
    }
  }

  void removeFromWishlist(Product product) {
    final id = product.id ?? product.name ?? '';
    if (_wishlistIds.remove(id)) {
      _products.remove(id);
      notifyListeners();
    }
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product)) {
      removeFromWishlist(product);
    } else {
      addToWishlist(product);
    }
  }

  void clearWishlist() {
    _wishlistIds.clear();
    _products.clear();
    notifyListeners();
  }
}
