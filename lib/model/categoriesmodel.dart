// categoriesmodel.dart
class Product {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final List<String> images;
  final String? category;
  final double? rating; // Add this
  final int? stock; // Add this

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    required this.images,
    this.category,
    this.rating, // Add this
    this.stock, // Add this
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<String> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      imageList = List<String>.from(
        json['images'].where((img) => img != null && img.toString().isNotEmpty)
            .map((img) => img.toString())
      );
    }
    
    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['title']?.toString() ?? 
            json['name']?.toString() ?? 
            'Unknown Product',
      description: json['description']?.toString() ?? '',
      price: _parsePrice(json['price']),
      images: imageList,
      category: json['category']?.toString() ?? 'Uncategorized',
      rating: _parseRating(json['rating']), // Add this
      stock: _parseStock(json['stock']), // Add this
    );
  }

  // Get first image URL (for backward compatibility)
  String? get imageUrl => images.isNotEmpty ? images[0] : null;

  static double? _parsePrice(dynamic price) {
    if (price == null) return null;
    
    if (price is int) {
      return price.toDouble();
    } else if (price is double) {
      return price;
    } else if (price is String) {
      return double.tryParse(price);
    }
    
    return null;
  }

  static double? _parseRating(dynamic rating) {
    if (rating == null) return null;
    
    if (rating is int) {
      return rating.toDouble();
    } else if (rating is double) {
      return rating;
    } else if (rating is String) {
      return double.tryParse(rating);
    }
    
    return null;
  }

  static int? _parseStock(dynamic stock) {
    if (stock == null) return null;
    
    if (stock is int) {
      return stock;
    } else if (stock is String) {
      return int.tryParse(stock);
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'rating': rating,
      'stock': stock,
    };
  }
}