class Product {
  final String? id;
  final String title;
  final String description;
  final double price;
  final double mrp;
  
  final double rating;
  final String category;
  final int stock;
  final List<String> images; 

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.mrp,
    
    required this.rating,
    required this.category,
    required this.stock,
    List<String>? images, // Changed from 'image' to 'images'
  }) : images = images ?? [];

  // ================= FROM JSON =================
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      images: json['images'] != null // Changed from 'image' to 'images'
          ? List<String>.from(json['images'])
          : [],
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'mrp': mrp,
          'rating': rating,
      'category': category,
      'stock': stock,
      'images': images, // Changed from 'image' to 'images'
    };
  }

  // ================= COPY WITH =================
  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? mrp,
    double? discount,
    double? rating,
    String? category,
    int? stock,
    List<String>? images, // Changed from 'image' to 'images'
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
  
      rating: rating ?? this.rating,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      images: images ?? this.images,
    );
  }
}