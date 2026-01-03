import 'dart:convert';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/model/productmodel.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';


class ApiService {
  static const String baseUrl =
      'https://aroun-shopping-website-a2he.onrender.com/api';

  // Get token from AuthManager
  static String? _getToken() {
    try {
      return AuthManager().token;
    } catch (e) {
      
      return null;
    }
  }

  // Get headers with user token
  static Map<String, String> get _headers {
    final token = _getToken();
    final headers = {
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      
      if (kDebugMode) {
        print('Using user token: ${token.substring(0, min(30, token.length))}...');
      }
    } else {
      if (kDebugMode) {
        print('No user token available');
      }
    }
    
    return headers;
  }

  // Get admin headers - checks if user is admin

  // ================= GET PRODUCTS =================
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
      );

      if (kDebugMode) {
        print('Get Products Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        if (kDebugMode) {
          print('Authentication failed for getProducts');
        }
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getProducts: $e');
      }
      rethrow;
    }
  }

  // ================= ADD PRODUCT =================
  static Future<void> addProduct(Product product, XFile? imageFile) async {
    try {
      // Check authentication
      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login first.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/products'),
      );

      // Add token to headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add text fields
      request.fields.addAll({
        'title': product.title,
        'description': product.description,
        'price': product.price.toString(),
        'mrp': product.mrp.toString(),
        'rating': product.rating.toString(),
        'category': product.category,
        'stock': product.stock.toString(),
      });

      // Add image if exists
      if (imageFile != null) {
        try {
          final bytes = await imageFile.readAsBytes();
          final fileName = imageFile.name.isNotEmpty 
              ? imageFile.name 
              : 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: fileName,
            contentType: getContentType(imageFile.mimeType, fileName),
          );
          request.files.add(multipartFile);
          
          if (kDebugMode) {
            print('📤 Uploading image with token authentication');
            print('📏 Image size: ${bytes.length} bytes');
          }
        } catch (e) {
          throw Exception('Failed to process image: $e');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ No image provided for upload');
        }
      }

      // Debug info
      if (kDebugMode) {
        print('📝 Request fields:');
        request.fields.forEach((key, value) => print('  $key: $value'));
        print('🖼️ Files count: ${request.files.length}');
      }
      
      final response = await http.Response.fromStream(await request.send());

      if (kDebugMode) {
        print('📊 Add Product Status Code: ${response.statusCode}');
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Token may be expired.');
      } else if (response.statusCode == 403) {
        throw Exception('Permission denied. Admin access required.');
      } else if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Add product failed: ${response.body}');
      } else {
        // Success
        if (kDebugMode) {
          print('✅ Product added successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in addProduct: $e');
      }
      rethrow;
    }
  }

  // ================= UPDATE PRODUCT =================
  static Future<void> updateProduct(Product product, XFile? imageFile) async {
    try {
      // Check authentication
      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login first.');
      }

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/products/${product.id}'),
      );

      // Add token to headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields.addAll({
        'title': product.title,
        'description': product.description,
        'price': product.price.toString(),
        'mrp': product.mrp.toString(),
        'rating': product.rating.toString(),
        'category': product.category,
        'stock': product.stock.toString(),
      });

      if (imageFile != null) {
        try {
          final bytes = await imageFile.readAsBytes();
          final fileName = imageFile.name;
          
          final multipartFile = http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: fileName,
            contentType: getContentType(imageFile.mimeType, fileName),
          );
          request.files.add(multipartFile);
          
          if (kDebugMode) {
            print('🔄 Updating product image with authentication');
          }
        } catch (e) {
          throw Exception('Failed to process image: $e');
        }
      }

      final response = await http.Response.fromStream(await request.send());

      if (kDebugMode) {
        print('📊 Update Product Status Code: ${response.statusCode}');
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Token may be expired.');
      } else if (response.statusCode == 403) {
        throw Exception('Permission denied. Admin access required.');
      } else if (response.statusCode != 200) {
        throw Exception('Update failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in updateProduct: $e');
      }
      rethrow;
    }
  }

  // ================= DELETE PRODUCT =================
  static Future<void> deleteProduct(String id) async {
    try {
      // Check authentication
      final token = _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login first.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('🗑️ Delete Product Status Code: ${response.statusCode}');
      }

      if (response.statusCode == 401) {
        throw Exception('Authentication failed. Token may be expired.');
      } else if (response.statusCode == 403) {
        throw Exception('Permission denied. Admin access required.');
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Delete failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in deleteProduct: $e');
      }
      rethrow;
    }
  }

  // Helper method to get proper content type
  static http.MediaType? getContentType(String? mimeType, String fileName) {
    if (mimeType != null && mimeType.isNotEmpty) {
      try {
        return http.MediaType.parse(mimeType);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Failed to parse mimeType: $mimeType');
        }
      }
    }
    
    // Fallback based on file extension
    if (fileName.toLowerCase().endsWith('.png')) {
      return http.MediaType('image', 'png');
    } else if (fileName.toLowerCase().endsWith('.jpeg') || 
               fileName.toLowerCase().endsWith('.jpg')) {
      return http.MediaType('image', 'jpeg');
    } else if (fileName.toLowerCase().endsWith('.gif')) {
      return http.MediaType('image', 'gif');
    } else if (fileName.toLowerCase().endsWith('.webp')) {
      return http.MediaType('image', 'webp');
    }
    
    // Default to JPEG
    return http.MediaType('image', 'jpeg');
  }

  // Enhanced method with better error handling
  static Future<Product> addProductWithAuth(Product product, XFile? imageFile) async {
    try {
      await addProduct(product, imageFile);
      
      // Fetch the created product to return complete data
      final products = await getProducts();
      final createdProduct = products.firstWhere(
        (p) => p.title == product.title && p.category == product.category,
        orElse: () => product,
      );
      
      return createdProduct;
    } catch (e) {
      if (kDebugMode) {
        print('Error in addProductWithAuth: $e');
      }
      rethrow;
    }
  }

  // Check if user can perform admin operations
  static bool canPerformAdminOperations() {
    try {
      final authManager = AuthManager();
      return authManager.isLoggedIn && authManager.isAdmin;
    } catch (e) {
      return false;
    }
  }

  // Get user role for debugging
  static String? getUserRole() {
    try {
      return AuthManager().currentUser?.role;
    } catch (e) {
      return null;
    }
  }

  // Helper for min function
  static int min(int a, int b) => a < b ? a : b;
}
