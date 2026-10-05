import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/categories/productdetail.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/model/wishlist_manager.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final rupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground(AppColors.background),
      appBar: AppBar(
        backgroundColor: context.appSurface(AppColors.white),
        elevation: 1,
        foregroundColor: context.appForeground(AppColors.darkText),
        title:  AppText(
          'My Wishlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.appForeground(AppColors.darkText),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: WishlistManager.instance,
            builder: (context, _) {
              if (WishlistManager.instance.count == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  WishlistManager.instance.clearWishlist();
                },
                child:  AppText(
                  'Clear All',
                  style: TextStyle(color: context.appForeground(AppColors.red), fontSize: 13),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: WishlistManager.instance,
        builder: (context, _) {
          final items = WishlistManager.instance.items;
          if (items.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildWishlistItem(items[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistItem(Product product) {
    final discount = product.discountPercent;
    final originalPrice = product.originalPrice;

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: context.appSurface(AppColors.grey100),
                ),
                child: _buildProductImage(product),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDataText(
                      product.name, fallback: 'Unnamed Product',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.appForeground(AppColors.darkText),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (product.category != null)
                      AppText(
                        product.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appForeground(AppColors.grey600),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(
                          rupeeFormat.format(product.price ?? 0),
                          style:  TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.appForeground(AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (discount != null && discount > 0 && originalPrice != null)
                          AppText(
                            rupeeFormat.format(originalPrice),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.appForeground(AppColors.grey500),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.grey400,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              WishlistManager.instance.toggleWishlist(product);
                            },
                            icon: const Icon(Icons.favorite, size: 16),
                            label: const AppText('Remove', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.appForeground(AppColors.red),
                              side:  BorderSide(color: context.appBorder(AppColors.red)),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility, size: 14),
                            label: const AppText('View', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appSurface(AppColors.primary),
                              foregroundColor: context.appForeground(AppColors.white),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.images.isEmpty) {
      return  Center(
        child: Icon(
          Icons.shopping_bag,
          size: 40,
          color: context.appForeground(AppColors.grey400),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        product.images[0],
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) {
          return  Center(
            child: Icon(
              Icons.broken_image,
              size: 40,
              color: context.appForeground(AppColors.grey400),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.appSurface(AppColors.grey100),
                shape: BoxShape.circle,
              ),
              child:  Icon(
                Icons.favorite_border,
                size: 50,
                color: context.appForeground(AppColors.grey400),
              ),
            ),
            const SizedBox(height: 24),
             AppText(
              'Your Wishlist is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.appForeground(AppColors.darkText),
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              'Tap the heart icon on any product to add it to your wishlist',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.appForeground(AppColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
