import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:arunstore/widgets/hero_banner.dart';
import 'package:arunstore/widgets/category_carousel.dart';
import 'package:arunstore/widgets/product_carousel.dart';
import 'package:arunstore/widgets/promo_banner_card.dart';
import 'package:arunstore/widgets/service_feature_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileHomeScreen extends StatefulWidget {
  final Map<String, List<Product>> categoryMap;
  final List<Product> allProducts;
  final bool loading;
  final String? error;
  final void Function(String categoryName)? onCategoryTap;
  final void Function(Product product)? onDealProductTap;
  final void Function(String query)? onSearchSubmitted;
  final VoidCallback? onMenuTap;

  const MobileHomeScreen({
    super.key,
    required this.categoryMap,
    required this.allProducts,
    required this.loading,
    this.error,
    this.onCategoryTap,
    this.onDealProductTap,
    this.onSearchSubmitted,
    this.onMenuTap,
  });

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _dealProducts => widget.allProducts.where((p) {
    final discount = p.discountPercent;
    return discount != null && discount > 0;
  }).toList();

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return  Center(
        child: CircularProgressIndicator(color: context.appForeground(AppColors.primary)),
      );
    }

    if (widget.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.error_outline, size: 48, color: context.appForeground(AppColors.red)),
              const SizedBox(height: 12),
              AppText(widget.error ?? 'An error occurred'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () {}, child: const AppText('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appBackground(AppColors.background),
      body: RefreshIndicator(
        onRefresh: () async {
          // refresh handled by parent
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              HeroBanner(categoryMap: widget.categoryMap),
              _buildCategorySection(),
              _buildDealProductsSection(),
              _buildPromoStrip(),
              const ServiceFeatureBar(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: context.appSurface(AppColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (widget.onMenuTap != null)
              IconButton(
                tooltip: context.tr('Open navigation menu'),
                icon: const Icon(Icons.menu_rounded),
                onPressed: widget.onMenuTap,
              ),
            AppText(
              'AROUN STORES',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.appForeground(AppColors.primary),
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Consumer<CartManager>(
              builder: (context, cartManager, child) {
                return _buildCartBadge(cartManager.totalItems);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBadge(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, size: 24),
          color: context.appForeground(AppColors.darkText),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration:  BoxDecoration(
                color: context.appSurface(AppColors.red),
                shape: BoxShape.circle,
              ),
              child: AppText(
                count.toString(),
                style:  TextStyle(
                  fontSize: 10,
                  color: context.appForeground(AppColors.white),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: context.appSurface(AppColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface(AppColors.grey50),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search for groceries...',
            hintStyle: TextStyle(color: context.appForeground(AppColors.grey500), fontSize: 13),
            prefixIcon: Icon(Icons.search, color: context.appForeground(AppColors.grey500), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    color: context.appForeground(AppColors.grey400),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                : null,
          ).localized(context),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              widget.onSearchSubmitted?.call(value.trim());
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Shop by Category',
            style: AppTextStyles.headingMedium.copyWith(color: context.appForeground(AppColors.darkText)),
          ),
          const SizedBox(height: 12),
          if (widget.categoryMap.isEmpty)
            _buildEmptyCategories()
          else
            CategoryCarousel(
              categories: widget.categoryMap,
              onCategoryTap: (categoryName) {
                widget.onCategoryTap?.call(categoryName);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategories() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (_, i) => Container(
          width: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: context.appSurface(AppColors.grey200),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDealProductsSection() {
    final products = _dealProducts.isNotEmpty ? _dealProducts : widget.allProducts;
    if (products.isEmpty) return const SizedBox.shrink();

    return ProductCarousel(
      title: _dealProducts.isNotEmpty ? 'Best Deals' : 'Top Products',
      subtitle: _dealProducts.isNotEmpty
          ? 'Special discounts just for you'
          : 'Handpicked for you',
      products: products,
    );
  }

  Widget _buildPromoStrip() {
    final banners = [
      PromoBannerConfig(
        title: 'Save More with Combo Deals',
        subtitle: 'Buy more, save more on groceries',
        offer: 'UP TO 30% OFF',
        backgroundColor: AppColors.cream,
        accentColor: AppColors.primary,
        icon: Icons.local_offer,
        onTap: (context) {},
      ),
      PromoBannerConfig(
        title: 'Big Savings',
        subtitle: 'On Daily Essentials',
        offer: 'UP TO 40% OFF',
        backgroundColor: AppColors.green100,
        accentColor: AppColors.amber,
        icon: Icons.savings,
        onTap: (context) {},
      ),
      PromoBannerConfig(
        title: 'Monthly Sale',
        subtitle: "Don't Miss Out!",
        offer: 'LIMITED TIME',
        backgroundColor: AppColors.lightGreen,
        accentColor: AppColors.primary,
        icon: Icons.calendar_month,
        onTap: (context) {},
      ),
      PromoBannerConfig(
        title: 'Free Delivery',
        subtitle: 'On Orders Above ₹499',
        offer: 'FREE',
        backgroundColor: AppColors.green100,
        accentColor: AppColors.primaryLight,
        icon: Icons.local_shipping,
        onTap: (context) {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: AppText(
            'Special Offers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.appForeground(AppColors.darkText),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PromoBannerStrip(banners: banners),
      ],
    );
  }
}
