import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:arunstore/widgets/grocery_product_card.dart';
import 'package:arunstore/widgets/section_header.dart';
import 'package:flutter/material.dart';

class ProductCarousel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Product> products;
  final Function(String)? onCategoryTap;
  final ScrollController? controller;

  const ProductCarousel({
    super.key,
    required this.title,
    this.subtitle,
    required this.products,
    this.onCategoryTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);
    final isTablet = AppTheme.isTablet(context);

    final cardWidth = isDesktop ? 180.0 : (isTablet ? 160.0 : 150.0);
    final compact = isTablet && !isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: 8),
        if (products.isEmpty)
          _buildEmptyState()
        else if (isDesktop)
          _buildDesktopGrid(context, cardWidth, compact)
        else
          _buildMobileCarousel(context, cardWidth, compact),
      ],
    );
  }

  Widget _buildDesktopGrid(BuildContext context, double cardWidth, bool compact) {
    final crossAxisCount = _calculateCrossAxisCount();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: cardWidth / (compact ? 240 : 280),
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return GroceryProductCard(
            product: products[index],
            maxWidth: cardWidth,
            compact: compact,
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount() {
    // Approximate based on available space
    // Each card is ~180 wide with spacing
    return 4;
  }

  Widget _buildMobileCarousel(BuildContext context, double cardWidth, bool compact) {
    return SizedBox(
      height: (compact ? 240 : 280) + 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 12),
            child: GroceryProductCard(
              product: products[index],
              maxWidth: cardWidth,
              compact: compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        'No products available at the moment.',
        style: TextStyle(
          color: AppColors.grey500,
          fontSize: 14,
        ),
      ),
    );
  }
}
