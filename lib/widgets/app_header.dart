import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/service/homescreenfunction.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatefulWidget {
  final HomeScreenLogic logic;
  final TextEditingController searchController;
  final Function(String)? onSearchChanged;
  final VoidCallback? onMenuTap;
  final List<String> navItems;
  final String? activeNavItem;
  final void Function(String)? onNavTap;

  const AppHeader({
    super.key,
    required this.logic,
    required this.searchController,
    this.onSearchChanged,
    this.onMenuTap,
    required this.navItems,
    this.activeNavItem,
    this.onNavTap,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isSearchFocused = false;

  void _toggleSearchFocus(bool focused) {
    setState(() {
      _isSearchFocused = focused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWide = maxWidth >= 1024;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
          
            if (isWide) _buildDesktopNavigation(),
            if (!isWide) _buildMobileSearchBar(),
          ],
        );
      },
    );
  }

 

 

 

  Widget _buildSearchBar({bool expanded = true}) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: context.appSurface(AppColors.white),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search for groceries, vegetables, fruits...',
          hintStyle: TextStyle(
            color: context.appForeground(AppColors.lightText),
            fontSize: 14,
          ),
          prefixIcon:  Icon(
            Icons.search,
            color: context.appForeground(AppColors.primary),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          isDense: true,
          suffixIcon: _isSearchFocused && widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    widget.searchController.clear();
                    widget.onSearchChanged?.call('');
                    _toggleSearchFocus(false);
                  },
                )
              : null,
        ).localized(context),
        style: const TextStyle(fontSize: 14),
        onTap: () => _toggleSearchFocus(true),
        onEditingComplete: () {
          final query = widget.searchController.text.trim();
          if (query.isNotEmpty) {
            widget.logic.navigateToSearchResults(context, query);
          }
        },
      ),
    );
  }

  Widget _buildMobileSearchBar() {
    return Container(
      color: context.appSurface(AppColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: _buildSearchBar(expanded: false),
    );
  }




  Widget _buildDesktopNavigation() {
    if (widget.navItems.isEmpty) return const SizedBox.shrink();

    return Container(
      color: context.appSurface(AppColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 4, runSpacing: 4,
        children: widget.navItems.map((item) {
          final isActive = widget.activeNavItem == item;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              onPressed: () => widget.onNavTap?.call(item),
              style: TextButton.styleFrom(
                foregroundColor: context.appForeground(isActive ? AppColors.primary : AppColors.mutedText),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: AppText(
                item,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: context.appForeground(isActive ? AppColors.primary : AppColors.mutedText),
                ),
              ),
            ),
          );
        }).toList(),
      ),
     );
  }
}
