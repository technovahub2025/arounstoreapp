import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CategoryCarousel extends StatelessWidget {
  final Map<String, List<Product>> categories;
  final Function(String)? onCategoryTap;

  const CategoryCarousel({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  List<MapEntry<String, List<Product>>> _getCategoryList(BuildContext context) {
    final categoryNames = categories.keys.toList();

    final List<MapEntry<String, List<Product>>> items = categoryNames
        .map((name) => MapEntry(name, categories[name] ?? []))
        .toList();

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _getCategoryList(context);

    if (items.isEmpty) {
      return _buildEmptyState(context, );
    }

    return SizedBox(
      height: AppDimensions.categoryCardSize + 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final entry = items[index];
          final categoryName = entry.key;
          final products = entry.value;

          String? imageUrl;
          if (products.isNotEmpty && products[0].images.isNotEmpty) {
            imageUrl = products[0].images[0];
          }

          return CategoryCard(
            name: categoryName,
            imageUrl: imageUrl,
            productCount: products.length,
            onTap: () {
              if (onCategoryTap != null) {
                onCategoryTap!(categoryName);
              } else {
                _navigateToCategory(context, categoryName, products);
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryName, List<Product> products) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFilterPage(
          categories: {categoryName: products},
          initialSelectedCategory: categoryName,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ) {
    return SizedBox(
      height: 160,
      child: Center(
        child: AppText(
          'No categories available',
          style: TextStyle(
            color: context.appForeground(AppColors.grey500),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final int productCount;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.productCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.categoryCardSize + 40,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppDimensions.categoryCardSize,
              height: AppDimensions.categoryCardSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appSurface(AppColors.green50),
                border: Border.all(color: context.appBorder(AppColors.green200), width: 2),
                boxShadow: AppShadows.cardShadow,
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: context.appSurface(AppColors.grey100),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.category,
                          size: 40,
                          color: context.appForeground(AppColors.grey400),
                        ),
                      )
                    : Icon(
                        Icons.category,
                        size: 40,
                        color: context.appForeground(AppColors.grey400),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              name,
              style: AppTextStyles.caption.copyWith(
                color: context.appForeground(AppColors.darkText),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppText(
              '$productCount items',
              style: TextStyle(
                fontSize: 10,
                color: context.appForeground(AppColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
