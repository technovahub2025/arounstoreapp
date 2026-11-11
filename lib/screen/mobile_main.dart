import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/allorder.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/mobile_home.dart';
import 'package:arunstore/screen/mobile_account.dart';
import 'package:arunstore/screen/settings/settings_screen.dart';
import 'package:arunstore/service/categoryservice.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({super.key});

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final ProductController _productController = ProductController();
  late final ProductCatalogSession _catalog = ProductCatalogSession(_productController);
  Timer? _searchTimer;
  Map<String, int> _categoryCounts = {};
  String _activeSearch = '';
  Map<String, List<Product>> get _categoryMap => _catalog.categories;
  List<Product> get _allProducts => _catalog.products;
  bool get _loading => _catalog.loading;
  bool get _loadingMore => _catalog.loadingMore;
  bool get _hasMore => _catalog.hasMore;
  String? get _error => _catalog.error;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _catalog.loadFirst();
    try {
      _categoryCounts = await _productController.fetchCategoryCounts();
      for (final category in _categoryCounts.keys) {
        _categoryMap.putIfAbsent(category, () => []);
      }
    } catch (e) {
      debugPrint('Could not load category counts: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadMoreProducts() async {
    await _catalog.loadMore();
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _activeSearch = query.trim();
    _catalog.invalidatePending();
    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      await _catalog.loadFirst(search: query);
      if (query.trim().isEmpty) {
        for (final category in _categoryCounts.keys) {
          _categoryMap.putIfAbsent(category, () => []);
        }
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _retryCatalog() async {
    await _catalog.loadFirst(search: _activeSearch);
    if (_activeSearch.isEmpty) {
      for (final category in _categoryCounts.keys) {
        _categoryMap.putIfAbsent(category, () => []);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    await AuthManager().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  void _openOrders() {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => authManager.isLoggedIn
            ? const Allorder()
            : const LoginScreen(),
      ),
    );
  }

  void _navigateToCategoryFilter(Map<String, List<Product>> categories, {String? initialCategory}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFilterPage(
          categories: categories,
          initialSelectedCategory: initialCategory,
          onProfileTap: () {
            Navigator.pop(context);
            _onNavTap(2);
          },
        ),
      ),
    );
  }

  void _navigateToSearchResults(List<Product> results, String query) {
    final map = <String, List<Product>>{};
    if (results.isNotEmpty) {
      map['Search Results'] = results;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFilterPage(
          categories: map,
          searchQuery: query,
          onProfileTap: () {
            Navigator.pop(context);
            _onNavTap(2);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MobileHomeScreen(
        categoryMap: _categoryMap,
        allProducts: _allProducts,
        categoryCounts: _categoryCounts,
        loading: _loading,
        loadingMore: _loadingMore,
        hasMore: _hasMore,
        onLoadMore: _loadMoreProducts,
        error: _error,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onCategoryTap: (categoryName) {
          _navigateToCategoryFilter(_categoryMap, initialCategory: categoryName);
        },
        onSearchSubmitted: (query) {
          _navigateToSearchResults(_allProducts, query);
        },
        onSearchChanged: _onSearchChanged,
        onRetry: _retryCatalog,
      ),
      _loading
          ?  Center(child: CircularProgressIndicator(color: context.appForeground(AppColors.primary)))
          : _error != null
              ? Center(child: AppText(_error ?? 'Error loading categories'))
              : CategoryFilterPage(
                  categories: _categoryMap,
                  onProfileTap: () => _onNavTap(2),
                ),
      MobileAccountScreen(
        onLogoutTap: () async {
          await _logout();
        },
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildNavigationDrawer(),
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNavigationDrawer() {
    final user = Provider.of<AuthManager>(context).currentUser;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: context.appSurface(AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Icon(Icons.storefront, color: context.appForeground(AppColors.white), size: 32),
                  const SizedBox(height: 12),
                   AppText(
                    'Aroun Stores',
                    style: TextStyle(
                      color: context.appForeground(AppColors.white),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.name.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.name,
                      style:  TextStyle(color: context.appForeground(Colors.white70)),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const AppText('Home'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const AppText('Categories'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(1);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const AppText('Cart'),
              onTap: () {
                Navigator.pop(context);
                _openCart();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const AppText('Orders'),
              onTap: () {
                Navigator.pop(context);
                _openOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const AppText('My Profile'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const AppText('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final authManager = Provider.of<AuthManager>(context);
    final isLoggedIn = authManager.isLoggedIn;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.appSurface(AppColors.white),
      selectedItemColor: context.appForeground(AppColors.primary),
      unselectedItemColor: context.appForeground(AppColors.grey500),
      elevation: 8,
      currentIndex: _currentIndex,
      onTap: _onNavTap,
      items: [
         BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: context.tr('Home'),
        ),
         BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: context.tr('Categories'),
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isLoggedIn ? Icons.person : Icons.person_outline,
              ),
              if (isLoggedIn)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.appSurface(AppColors.primary),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.appBorder(AppColors.white), width: 1),
                    ),
                  ),
                ),
            ],
          ),
          label: context.tr('Account'),
        ),
      ],
    );
  }
}
