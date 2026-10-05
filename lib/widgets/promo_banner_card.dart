import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PromoBannerCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? offer;
  final Color backgroundColor;
  final Color? accentColor;
  final IconData icon;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const PromoBannerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.offer,
    this.backgroundColor = AppColors.green50,
    this.accentColor,
    this.icon = Icons.local_offer,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);
    final cardWidth = width ?? (isDesktop ? 260.0 : 280.0);
    final cardHeight = height ?? (isDesktop ? 140.0 : 120.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appSurface(backgroundColor),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: context.appForeground(accentColor ?? AppColors.primary),
                  size: 24,
                ),
                if (offer != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.appSurface((accentColor ?? AppColors.primary).withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      offer!,
                      style: TextStyle(
                        color: context.appForeground(accentColor ?? AppColors.primary),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: isDesktop ? 15 : 14,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  AppText(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appForeground(AppColors.grey600),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PromoBannerStrip extends StatelessWidget {
  final List<PromoBannerConfig> banners;
  final double? height;

  const PromoBannerStrip({
    super.key,
    required this.banners,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);
    final screenWidth = AppTheme.screenWidth(context);

    if (isDesktop) {
      final crossAxisCount = screenWidth > 1400 ? 4 : (screenWidth > 1200 ? 3 : 2);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: screenWidth / (crossAxisCount * 140),
          ),
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final config = banners[index];
            return PromoBannerCard(
              title: config.title,
              subtitle: config.subtitle,
              offer: config.offer,
              backgroundColor: config.backgroundColor,
              accentColor: config.accentColor,
              icon: config.icon,
              onTap: config.onTap != null
                  ? () => config.onTap!(context)
                  : null,
            );
          },
        ),
      );
    }

    return SizedBox(
      height: height ?? 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final config = banners[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: PromoBannerCard(
              title: config.title,
              subtitle: config.subtitle,
              offer: config.offer,
              backgroundColor: config.backgroundColor,
              accentColor: config.accentColor,
              icon: config.icon,
              width: 280,
              onTap: config.onTap != null
                  ? () => config.onTap!(context)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class PromoBannerConfig {
  final String title;
  final String? subtitle;
  final String? offer;
  final Color backgroundColor;
  final Color? accentColor;
  final IconData icon;
  final void Function(BuildContext)? onTap;

  const PromoBannerConfig({
    required this.title,
    this.subtitle,
    this.offer,
    this.backgroundColor = AppColors.cream,
    this.accentColor,
    this.icon = Icons.local_offer,
    this.onTap,
  });
}
