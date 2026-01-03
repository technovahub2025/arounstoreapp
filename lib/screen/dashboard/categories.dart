import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/screen/dashboard/categorypage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CategoriesCarousel extends StatelessWidget {
  final Map<String, List<Product>> categories;
  final Function(String)? onCategoryTap;

  const CategoriesCarousel({
    Key? key,
    required this.categories,
        this.onCategoryTap, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryNames = categories.keys.toList();
    
    if (kDebugMode) {
      print('CategoriesCarousel: ${categoryNames.length} categories');
    }

    if (categoryNames.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No categories available'),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final categoryName = categoryNames[index];
          final products = categories[categoryName] ?? [];
          
         
          String? imageUrl;
          if (products.isNotEmpty && products[0].images.isNotEmpty) {
            imageUrl = products[0].images[0];
            if (kDebugMode) {
              print('Category: $categoryName, Image URL: $imageUrl');
            }
          }
          
          return GestureDetector(
            onTap: () {
              // Navigate to category details page
              _navigateToCategoryDetails(context, categoryName, products);
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Image
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: _buildCategoryImage(imageUrl, categoryName),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${products.length} ${products.length == 1 ? 'product' : 'products'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (products.isNotEmpty && products[0].price != null)
                          Text(
                          'From ₹${products[0].price!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  

  void _navigateToCategoryDetails(BuildContext context, String categoryName, List<Product> products) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsPage(
          categoryName: categoryName,
          products: products,
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String? imageUrl, String categoryName) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(12),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Failed to load image: $imageUrl');
            print('Error: $error');
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 5),
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

