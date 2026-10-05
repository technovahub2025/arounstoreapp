import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PromoTopBar extends StatelessWidget implements PreferredSizeWidget {
  const PromoTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);

    return Container(
      color: context.appSurface(AppColors.primary),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: isDesktop
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (isDesktop) _buildContactInfo(context, ),
          _buildPromoText(context, ),
          if (isDesktop) _buildCtaButton(context, ),
        ],
      ),
    );
  }

  Widget _buildPromoText(BuildContext context, ) {
    return  AppText(
      'FOR MODERN GROCERY SHOPPING, SHOP WITH US!',
      style: TextStyle(
        color: context.appForeground(Colors.white),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, ) {
    return  Row(
      children: [
        Icon(
          Icons.phone,
          color: context.appForeground(Colors.white),
          size: 16,
        ),
        SizedBox(width: 6),
        AppText(
          '1800-123-4560',
          style: TextStyle(
            color: context.appForeground(Colors.white),
            fontSize: 12,
          ),
        ),
        SizedBox(width: 4),
        AppText(
          '|',
          style: TextStyle(
            color: context.appForeground(Colors.white70),
            fontSize: 12,
          ),
        ),
        SizedBox(width: 4),
        Icon(
          Icons.email_outlined,
          color: context.appForeground(Colors.white),
          size: 16,
        ),
        SizedBox(width: 6),
        AppText(
          'support@arounstores.com',
          style: TextStyle(
            color: context.appForeground(Colors.white),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context, ) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: context.appSurface(AppColors.green100.withValues(alpha: 0.3)),
        foregroundColor: context.appForeground(Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const AppText(
        'Get Pro',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
