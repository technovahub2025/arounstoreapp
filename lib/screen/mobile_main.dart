import 'package:arunstore/authmanager.dart';
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

class MobileMainScreen extends StatefulWidget {
  const MobileMainScreen({super.key});

  @override
  State<MobileMainScreen> createState() => _MobileMainScreenState();
}

class _MobileMainScreenState extends State<MobileMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  final ProductController _productController = ProductController();
  Map<String, List<Product>> _categoryMap = {};
  List<Product> _allProducts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _productController.fetchProductsByCategory();
      if (mounted) {
        setState(() {
          _categoryMap = data;
          _allProducts = data.values.expand((p) => p).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoryMap = {};
          _allProducts = [];
          _error = 'Failed to load products';
          _loading = false;
        });
      }
    }
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

  void _navigateToSearchResults(List<Product> results) {
    final map = <String, List<Product>>{};
    if (results.isNotEmpty) {
      map['Search Results'] = results;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFilterPage(
          categories: map,
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
    final authManager = Provider.of<AuthManager>(context);

    final screens = [
      MobileHomeScreen(
        categoryMap: _categoryMap,
        allProducts: _allProducts,
        loading: _loading,
        error: _error,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onCategoryTap: (categoryName) {
          _navigateToCategoryFilter(_categoryMap, initialCategory: categoryName);
        },
        onSearchSubmitted: (query) {
          final results = _allProducts.where((p) {
            final lower = query.toLowerCase();
            return (p.name?.toLowerCase().contains(lower) ?? false) ||
                (p.category?.toLowerCase().contains(lower) ?? false) ||
                (p.description?.toLowerCase().contains(lower) ?? false);
          }).toList();
          _navigateToSearchResults(results);
        },
      ),
      _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Text(_error ?? 'Error loading categories'))
              : CategoryFilterPage(
                  categories: _categoryMap,
                  onProfileTap: () => _onNavTap(2),
                ),
      MobileAccountScreen(
        onLogoutTap: () async {
          await authManager.logout();
          if (mounted) setState(() {});
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
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront, color: AppColors.white, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Aroun Stores',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.name.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.name,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(1);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                _openCart();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                _openOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                _onNavTap(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
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
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      elevation: 8,
      currentIndex: _currentIndex,
      onTap: _onNavTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
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
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Account',
        ),
      ],
    );
  }
}
