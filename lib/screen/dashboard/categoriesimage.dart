import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';


import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:arunstore/widgets/product_image.dart';

class CategoryImagesHorizontal extends StatelessWidget {
  final Map<String, List<Product>> categories;
  final Function(String)? onCategoryTap;

  const CategoryImagesHorizontal({
    Key? key,
    required this.categories,
    this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryNames = categories.keys.toList();
    
    if (kDebugMode) {
      print('Categories: ${categoryNames.length}');
    }

    if (categoryNames.isEmpty) {
      return const SizedBox.shrink();
    }

    String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}


    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryNames.length,
      itemBuilder: (context, index) {
        final categoryName = categoryNames[index];
        final products = categories[categoryName] ?? [];
        
        if (kDebugMode) {
          print('Category: $categoryName, Products: ${products.length}');
        }

        // Get ALL images from ALL products in this category
        List<String> allImages = [];
        for (var product in products) {
          allImages.addAll(product.images.map(resolveProductImageUrl));
        }
        
        if (kDebugMode && allImages.isNotEmpty) {
          print('First image URL in $categoryName: ${allImages[0]}');
        }

        return GestureDetector(
          onTap: () {
            if (onCategoryTap != null) {
              onCategoryTap!(categoryName);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Name with arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   AppText(
  capitalizeFirst(categoryName),
  style:  TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: context.appForeground(Colors.black87),
  ),
),
                     Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: context.appForeground(Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Horizontal Scroll for Images
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allImages.length,
                    itemBuilder: (context, imgIndex) {
                      final imageUrl = allImages[imgIndex];
                      
                      // Optimize Cloudinary URL for display
                      final optimizedUrl = _optimizeCloudinaryUrl(imageUrl, 120, 120);
                      
                      return Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: context.appSurface(Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildProductImage(context, optimizedUrl, imgIndex + 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Optimize Cloudinary URL for specific dimensions
  String _optimizeCloudinaryUrl(String originalUrl, int width, int height) {
    if (!originalUrl.contains('res.cloudinary.com')) {
      return originalUrl;
    }
    
    try {
      // Check if URL already has Cloudinary transformations
      if (originalUrl.contains('/upload/')) {
        // Split the URL at /upload/
        List<String> parts = originalUrl.split('/upload/');
        if (parts.length == 2) {
          // Add optimization parameters
          return '${parts[0]}/upload/w_$width,h_$height,c_fill,q_auto,f_auto/${parts[1]}';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error optimizing Cloudinary URL: $e');
      }
    }
    
    return originalUrl;
  }

  Widget _buildProductImage(BuildContext context, String imageUrl, int imageNumber) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context, 'Empty URL', imageNumber);
    }
    
    if (kDebugMode) {
      print('Loading image $imageNumber: $imageUrl');
    }
    
    return ProductImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: 120,
      height: 120,
      placeholder: _buildLoadingWidget(context, imageNumber),
      fallbackImageUrl: imageUrl.contains('res.cloudinary.com')
          ? _getCloudinaryFallbackUrl(imageUrl)
          : null,
      errorWidget: _buildErrorWidget(context, 'Load failed', imageNumber),
    );
  }

  // Get alternative format for Cloudinary images
  String _getCloudinaryFallbackUrl(String originalUrl) {
    try {
      // If AVIF fails, try WebP
      if (originalUrl.contains('.avif')) {
        return originalUrl.replaceAll('.avif', '.webp');
      }
      // If WebP fails, try JPG
      else if (originalUrl.contains('.webp')) {
        return originalUrl.replaceAll('.webp', '.jpg');
      }
      // Remove quality parameters if they cause issues
      else if (originalUrl.contains('/q_')) {
        return originalUrl.replaceAll(RegExp(r'/q_[^/]+/'), '/');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating fallback URL: $e');
      }
    }
    
    return originalUrl;
  }

  Widget _buildLoadingWidget(BuildContext context, int imageNumber) {
    return Container(
      color: context.appSurface(Colors.grey[100]),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF15803D)),
            ),
            const SizedBox(height: 8),
            AppText(
              'Image $imageNumber',
              style:  TextStyle(
                fontSize: 10,
                color: context.appForeground(Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String errorType, int imageNumber) {
    return Container(
      color: context.appSurface(Colors.grey[100]),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
              Icons.broken_image,
              size: 24,
              color: context.appForeground(Colors.grey),
            ),
            const SizedBox(height: 4),
            AppText(
              'Img $imageNumber',
              style:  TextStyle(
                fontSize: 10,
                color: context.appForeground(Colors.grey),
              ),
            ),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  errorType,
                  style:  TextStyle(
                    fontSize: 8,
                    color: context.appForeground(Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
