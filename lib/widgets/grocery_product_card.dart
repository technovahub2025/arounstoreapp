import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/categories/productdetail.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroceryProductCard extends StatelessWidget {
  final Product product;
  final double? maxWidth;
  final bool compact;

  const GroceryProductCard({
    super.key,
    required this.product,
    this.maxWidth = 180,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final rupeeFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final cartManager = Provider.of<CartManager>(context, listen: true);
    final quantityInCart = cartManager.getProductQuantity(product);
    final isInCart = cartManager.isProductInCart(product);
    final discount = product.discountPercent;
    final originalPrice = product.originalPrice;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(
          maxHeight: compact ? 240 : 280,
        ),
        decoration: BoxDecoration(
          color: context.appSurface(AppColors.white),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(context, discount, isInCart, quantityInCart),
            _buildDetailsSection(context, rupeeFormat, originalPrice, discount),
            _buildActionSection(context, isInCart, quantityInCart),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    int? discount,
    bool isInCart,
    int quantityInCart,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
          child: Container(
            height: compact ? 100 : AppDimensions.productImageHeight,
            width: double.infinity,
            color: context.appSurface(AppColors.grey100),
            child: _buildProductImage(context, ),
          ),
        ),
        if (discount != null && discount > 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.appSurface(AppColors.red),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: AppText(
                '$discount% OFF',
                style:  TextStyle(
                  color: context.appForeground(AppColors.white),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (quantityInCart > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.appSurface(AppColors.primary),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: AppText(
                quantityInCart.toString(),
                style:  TextStyle(
                  color: context.appForeground(AppColors.white),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (product.stock != null && product.stock! <= 0)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: context.appSurface(Colors.black45),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLarge),
                ),
              ),
              child:  Center(
                child: AppText(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: context.appForeground(AppColors.white),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    NumberFormat rupeeFormat,
    double? originalPrice,
    int? discount,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDataText(
              product.name, fallback: 'Unnamed Product',
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 13,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (product.category != null)
              AppText(
                product.category!,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appForeground(AppColors.grey500),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppText(
                  rupeeFormat.format(product.price ?? 0),
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 15,
                    color: context.appForeground(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                if (originalPrice != null &&
                    originalPrice > (product.price ?? 0))
                  Flexible(
                    child: AppText(
                      rupeeFormat.format(originalPrice),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appForeground(AppColors.grey500),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.grey400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (discount != null && discount > 0) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.appSurface(AppColors.green100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        'Save $discount%',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.appForeground(AppColors.green700),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            if (product.rating != null && product.rating! > 0)
              Row(
                children: [
                   Icon(
                    Icons.star,
                    size: 14,
                    color: context.appForeground(Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 2),
                  AppText(
                    product.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appForeground(AppColors.grey700),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, bool isInCart, int quantityInCart) {
    final canAddToCart = product.stock != null && product.stock! > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: compact ? 32 : 36,
        child: ElevatedButton.icon(
          onPressed: canAddToCart
              ? () {
                  if (isInCart) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  } else {
                    final cartManager = Provider.of<CartManager>(context, listen: false);
                    cartManager.addProduct(product);
                  }
                }
              : null,
          icon: Icon(
            isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
            size: 14,
          ),
          label: AppText(
            isInCart ? 'In Cart ($quantityInCart)' : 'Add to Cart',
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.appSurface(isInCart ? AppColors.green50 : AppColors.primary),
            foregroundColor: context.appForeground(isInCart ? AppColors.primary : AppColors.white),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 6 : 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              side: BorderSide(
                color: context.appBorder(isInCart ? AppColors.primary : Colors.transparent),
                width: isInCart ? 1 : 0,
              ),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
  Widget _buildProductImage(BuildContext context, ) {
    if (product.images.isEmpty) {
      return  Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: context.appForeground(AppColors.grey400),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: product.images[0],
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) =>  Center(
        child: Icon(
          Icons.broken_image,
          size: 30,
          color: context.appForeground(AppColors.grey400),
        ),
      ),
      maxWidthDiskCache: 400,
      maxHeightDiskCache: 400,
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
      },
    );
  }
}
