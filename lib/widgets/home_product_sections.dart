import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/widgets/product_carousel.dart';
import 'package:flutter/material.dart';

/// Category previews and live search shared by mobile and desktop home pages.
class HomeProductSections extends StatelessWidget {
  const HomeProductSections({
    super.key,
    required this.categories,
    required this.allProducts,
    this.query = '',
    this.onCategoryTap,
  });

  final Map<String, List<Product>> categories;
  final List<Product> allProducts;
  final String query;
  final ValueChanged<String>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final search = query.trim().toLowerCase();
    if (search.isNotEmpty) {
      final results = allProducts.where((product) {
        return [
          product.name,
          product.category,
          product.description,
        ].any((value) => value?.toLowerCase().contains(search) ?? false);
      }).toList();

      if (results.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: AppText('No products found', textAlign: TextAlign.center),
        );
      }

      return ProductCarousel(title: 'Search Results', products: results);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: categories.entries.map((entry) {
        return ProductCarousel(
          title: entry.key,
          products: entry.value.take(4).toList(),
          onViewAllTap: () {
            if (onCategoryTap != null) {
              onCategoryTap!(entry.key);
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CategoryFilterPage(
                  categories: categories,
                  initialSelectedCategory: entry.key,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
