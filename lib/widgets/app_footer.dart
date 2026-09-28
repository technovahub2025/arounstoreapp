import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppTheme.isDesktop(context);
    final screenWidth = AppTheme.screenWidth(context);

    return Container(
      width: double.infinity,
      color: AppColors.darkText,
      padding: EdgeInsets.only(
        top: isDesktop ? 40 : 28,
        bottom: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainContent(isDesktop, screenWidth),
              _buildDivider(),
              _buildBottomBar(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop, double screenWidth) {
    if (isDesktop) {
      return _buildDesktopColumns(screenWidth);
    }
    return _buildMobileColumns();
  }

  Widget _buildDesktopColumns(double screenWidth) {
    final crossAxisCount = screenWidth > 1200 ? 4 : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth = constraints.maxWidth / crossAxisCount;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumn('Quick Links', _quickLinks, columnWidth),
              _buildColumn('Customer Service', _customerService, columnWidth),
              _buildColumn('Information', _information, columnWidth),
              if (crossAxisCount == 4)
                _buildColumn('Contact Us', [], columnWidth, isContactColumn: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileColumns() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FooterColumn(
            title: 'Quick Links',
            links: _quickLinks,
          ),
          SizedBox(height: 24),
          _FooterColumn(
            title: 'Customer Service',
            links: _customerService,
          ),
          SizedBox(height: 24),
          _FooterColumn(
            title: 'Information',
            links: _information,
          ),
          SizedBox(height: 24),
          _FooterColumn(
            title: 'Contact Us',
            links: _contactLinks,
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(
    String title,
    List<_FooterLink> links,
    double width, {
    bool isContactColumn = false,
  }) {
    final effectiveLinks = isContactColumn ? _contactLinks : links;

    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.only(right: isContactColumn ? 0 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 14),
            ...effectiveLinks.map((link) => _buildLinkItem(link)),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(_FooterLink link) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: link.onTap,
        child: Text(
          link.title,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey400,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 24),
      color: AppColors.grey700,
    );
  }

  Widget _buildBottomBar(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: isDesktop
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (isDesktop)
                _buildSocialIcons(),
              _buildPaymentIcons(isDesktop),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 Aroun Stores. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey500,
            ),
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    final socialIcons = [
      Icons.facebook,
      Icons.chat,
      Icons.camera,
      Icons.videocam,
    ];

    return Row(
      children: socialIcons.asMap().entries.map((entry) {
        final icon = entry.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.grey700,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 18,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentIcons(bool isDesktop) {
    final paymentIcons = [
      Icons.payment,
      Icons.account_balance,
      Icons.wallet,
      Icons.credit_card,
    ];

    return Wrap(
      spacing: isDesktop ? 16 : 12,
      alignment: isDesktop ? WrapAlignment.end : WrapAlignment.center,
      children: paymentIcons.map((icon) {
        return Icon(
          icon,
          color: AppColors.grey600,
          size: 24,
        );
      }).toList(),
    );
  }

  static const List<_FooterLink> _quickLinks = [
    _FooterLink(title: 'Home'),
    _FooterLink(title: 'Shop'),
    _FooterLink(title: 'Offers'),
    _FooterLink(title: 'Best Sellers'),
    _FooterLink(title: 'New Arrivals'),
    _FooterLink(title: 'Contact Us'),
  ];

  static const List<_FooterLink> _customerService = [
    _FooterLink(title: 'My Account'),
    _FooterLink(title: 'Track Order'),
    _FooterLink(title: 'Returns & Refunds'),
    _FooterLink(title: 'Shipping Policy'),
    _FooterLink(title: 'Terms & Conditions'),
    _FooterLink(title: 'FAQ'),
  ];

  static const List<_FooterLink> _information = [
    _FooterLink(title: 'About Us'),
    _FooterLink(title: 'Privacy Policy'),
    _FooterLink(title: 'Blog'),
    _FooterLink(title: 'Careers'),
    _FooterLink(title: 'Sitemap'),
  ];

  static const List<_FooterLink> _contactLinks = [
    _FooterLink(title: '📞 +91 1800-123-4560'),
    _FooterLink(title: '✉ support@arounstores.com'),
    _FooterLink(title: '📍 Aroun Stores, Puducherry, India'),
  ];
}

class _FooterLink {
  final String title;
  final VoidCallback? onTap;

  const _FooterLink({
    required this.title,
    this.onTap,
  });
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<_FooterLink> links;

  const _FooterColumn({
    required this.title,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 14),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                link.title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey400,
                  height: 1.4,
                ),
              ),
            )),
      ],
    );
  }
}
