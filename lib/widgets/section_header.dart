import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAllTap,
    this.viewAllText = 'View All',
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onViewAllTap;
  final String viewAllText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style:  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.appForeground(Color(0xFF1F2937)),
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  AppText(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appForeground(Colors.grey[600]),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onViewAllTap != null)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                foregroundColor: context.appForeground(const Color(0xFF15803D)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: Row(
                children: [
                  AppText(
                    viewAllText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                   Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: context.appForeground(Color(0xFF15803D)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
