import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HeroBanner extends StatefulWidget {
  final Map<String, List<Product>> categoryMap;
  final VoidCallback? onShopNow;

  const HeroBanner({super.key, required this.categoryMap, this.onShopNow});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentSlide = 0;

  static const _slides = [
    (
      asset: 'assets/banners/daily_essentials.png',
      label: 'Daily Essentials, Better Prices',
    ),
    (
      asset: 'assets/banners/snacks_and_drinks.png',
      label: 'Snacks & Drinks for Every Craving',
    ),
    (
      asset: 'assets/banners/snacks_and_drinks.png',
      label: 'Fresh groceries and daily essentials delivered to your home',
    ),
  ];

  void _shopNow() {
    if (widget.onShopNow != null) {
      widget.onShopNow!();
      return;
    }
    final allProducts = widget.categoryMap.values.expand((p) => p).toList();
    if (allProducts.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CategoryFilterPage(
          categories: <String, List<Product>>{'All Products': allProducts},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = (constraints.maxWidth * 9 / 16)
              .clamp(0.0, 560.0)
              .toDouble();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: heroHeight,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.easeInOut,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() => _currentSlide = index);
                  },
                ),
                items: _slides.map((slide) {
                  return Semantics(
                    button: true,
                    label: '${slide.label}. ${context.tr('Shop Now')}',
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXL,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _shopNow,
                        child: Image.asset(
                          slide.asset,
                          width: double.infinity,
                          height: heroHeight,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = _currentSlide == index;
                  return Semantics(
                    button: true,
                    selected: isActive,
                    label: _slides[index].label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _carouselController.animateToPage(index),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.appSurface(
                                isActive
                                    ? AppColors.primary
                                    : AppColors.grey200,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
