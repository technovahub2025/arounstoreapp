import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ServiceFeatureBar extends StatelessWidget {
  const ServiceFeatureBar({super.key});

  static final List<ServiceItem> _services = [
    ServiceItem(
      icon: Icons.local_shipping_outlined,
      title: 'Free Delivery',
      subtitle: 'On orders above ₹499',
    ),
    ServiceItem(
      icon: Icons.content_paste_rounded,
      title: 'Easy Returns',
      subtitle: '7 days return policy',
    ),
    ServiceItem(
      icon: Icons.lock_outline,
      title: 'Secure Payments',
      subtitle: '100% secure payments',
    ),
    ServiceItem(
      icon: Icons.support_outlined,
      title: '24/7 Support',
      subtitle: 'We are here to help',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);

    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        color: context.appSurface(AppColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _services
              .asMap()
              .entries
              .map((entry) => Expanded(
                    child: _buildServiceItem(context, entry.value, isDesktop),
                  ))
              .toList(),
        ),
      );
    }

    return Container(
      height: 120,
      color: context.appSurface(AppColors.white),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: _buildServiceItem(context, _services[index], false),
          );
        },
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, ServiceItem item, bool isDesktop) {
    return Row(
      children: [
        Container(
          width: isDesktop ? 48 : 40,
          height: isDesktop ? 48 : 40,
          decoration: BoxDecoration(
            color: context.appSurface(AppColors.green50),
            borderRadius: BorderRadius.circular(isDesktop ? 14 : 10),
          ),
          child: Icon(
            item.icon,
            color: context.appForeground(AppColors.primary),
            size: isDesktop ? 24 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                item.title,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: context.appForeground(AppColors.darkText),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppText(
                item.subtitle,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 11,
                  color: context.appForeground(AppColors.grey500),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
