import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HeroBanner extends StatefulWidget {
  final Map<String, List<Product>> categoryMap;
  final VoidCallback? onShopNow;

  const HeroBanner({
    super.key,
    required this.categoryMap,
    this.onShopNow,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  final List<HeroSlide> _slides = [
    HeroSlide(
      title: 'Fresh Groceries,',
      subtitle: 'Better Living',
      description: 'Get the freshest groceries & daily essentials delivered to your doorstep.',
      bgImage: 'https://images.unsplash.com/photo-1542838689403-0f93d4f3d3c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&q=80',
      primaryButtonText: 'Shop Now',
      secondaryButtonText: 'Explore Offers',
    ),
    HeroSlide(
      title: 'Fresh Fruits &',
      subtitle: 'Vegetables',
      description: '100% organic, farm-fresh produce straight from local farmers.',
      bgImage: 'https://images.unsplash.com/photo-1612865194665-a6520743d6e9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&q=80',
      primaryButtonText: 'Shop Produce',
      secondaryButtonText: 'Deals',
    ),
    HeroSlide(
      title: 'Daily Essentials,',
      subtitle: 'Zero Hassle',
      description: 'Everything you need for your home, delivered in 30 minutes or less.',
      bgImage: 'https://images.unsplash.com/photo-1584917187314-8d55e3c75df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&q=80',
      primaryButtonText: 'Shop Essentials',
      secondaryButtonText: 'Best Sellers',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);
    final screenHeight = AppTheme.screenHeight(context);
    final heroHeight = isDesktop
        ? (screenHeight > 800 ? 500.0 : 400.0)
        : (screenHeight > 700 ? 280.0 : 240.0);

    return Container(
      width: double.infinity,
      height: heroHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: heroHeight,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInOut,
              enableInfiniteScroll: true,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentSlide = index % _slides.length;
                });
              },
            ),
            items: _slides.asMap().entries.map((entry) {
              final slide = entry.value;
              return _buildSlide(slide, isDesktop);
            }).toList(),
          ),
          _buildIndicators(),
        ],
      ),
    );
  }

  Widget _buildSlide(HeroSlide slide, bool isDesktop) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              slide.bgImage,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: AppColors.grey200);
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.green100,
                   child: const Icon(Icons.broken_image, size: 40, color: AppColors.grey400),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 20,
              vertical: 24,
            ),
            child: isDesktop
                ? _buildDesktopContent(slide)
                : _buildMobileContent(slide),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(HeroSlide slide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 42,
                  ),
                ),
                Text(
                  slide.subtitle,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.green100,
                    fontSize: 42,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slide.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildPrimaryButton(slide.primaryButtonText),
                    const SizedBox(width: 16),
                    _buildSecondaryButton(slide.secondaryButtonText),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(),
          ),
        ],
    );
  }

  Widget _buildMobileContent(HeroSlide slide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          slide.title,
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.white,
            fontSize: 28,
          ),
        ),
        Text(
          slide.subtitle,
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.green100,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          slide.description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPrimaryButton(slide.primaryButtonText, small: true),
            const SizedBox(width: 10),
            _buildSecondaryButton(slide.secondaryButtonText, small: true),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, {bool small = false}) {
    return ElevatedButton(
      onPressed: widget.onShopNow ??
          () {
            final allProducts = widget.categoryMap.values.expand((p) => p).toList();
            if (allProducts.isNotEmpty) {
              final searchMap = <String, List<Product>>{'All Products': allProducts};
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryFilterPage(
                    categories: searchMap,
                  ),
                ),
              );
            }
          },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 16 : 32,
          vertical: small ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 13 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, {bool small = false}) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.white, width: 1.5),
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 16 : 32,
          vertical: small ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 13 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _slides.asMap().entries.map((entry) {
          final index = entry.key;
          final isActive = _currentSlide == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class HeroSlide {
  final String title;
  final String subtitle;
  final String description;
  final String bgImage;
  final String primaryButtonText;
  final String secondaryButtonText;

  const HeroSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bgImage,
    required this.primaryButtonText,
    required this.secondaryButtonText,
  });
}
