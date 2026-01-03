// import 'package:arunstore/model/cartmodel.dart';
// import 'package:arunstore/model/categoriesmodel.dart';

// class CartManager {
//   CartManager._();
//   static final CartManager instance = CartManager._();

//   final List<CartItem> _items = [];

//   List<CartItem> get items => _items;

//   void addProduct(Product product) {
//     final index = _items.indexWhere(
//       (item) => item.product.id == product.id,
//     );

//     if (index >= 0) {
//       _items[index].quantity++;
//     } else {
//       _items.add(CartItem(product: product));
//     }
//   }

//   void increase(Product product) {
//     _items.firstWhere((e) => e.product.id == product.id).quantity++;
//   }

//   void decrease(Product product) {
//     final item = _items.firstWhere((e) => e.product.id == product.id);
//     if (item.quantity > 1) {
//       item.quantity--;
//     } else {
//       _items.remove(item);
//     }
//   }

//    void remove(Product product) {
//     _items.removeWhere((e) => e.product.id == product.id); 
//   }

//   int get subTotal {
//     int total = 0;
//     for (var item in _items) {
//       total += (item.product.price ?? 0).toInt() * item.quantity;
//     }
//     return total;
//   }

//   int get total => subTotal + 10; // shipping

//   int get totalItems =>
//       _items.fold(0, (sum, item) => sum + item.quantity);
// }
import 'package:flutter/foundation.dart';
import 'package:arunstore/model/cartmodel.dart';
import 'package:arunstore/model/categoriesmodel.dart';

class CartManager extends ChangeNotifier {
  CartManager._();
  static final CartManager instance = CartManager._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // Get a cart item by product
  CartItem? getCartItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    return index >= 0 ? _items[index] : null;
  }

  void addProduct(Product product, {int quantity = 1}) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
  }

  void increase(Product product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrease(Product product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void remove(Product product) {
    _items.removeWhere((e) => e.product.id == product.id);
    notifyListeners();
  }

  void updateQuantity(Product product, int newQuantity) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    } else if (newQuantity > 0) {
      _items.add(CartItem(product: product, quantity: newQuantity));
      notifyListeners();
    }
  }

  bool isProductInCart(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }

  int get subTotal {
    double total = 0;
    for (var item in _items) {
      total += (item.product.price ?? 0) * item.quantity;
    }
    return total.toInt();
  }

  void addProductWithQuantity(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
  }

  // Clear all items from cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get item count for a specific product
  int getProductQuantity(Product product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    return index >= 0 ? _items[index].quantity : 0;
  }

  // Calculate total with shipping (example)
  int get total => subTotal + _calculateShipping();

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int _calculateShipping() {
    // Example: Free shipping for orders above 500
    if (subTotal > 500) {
      return 0;
    }
    return 50; // Default shipping charge
  }
}