import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/cart/allorder.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/adminscreen/dashboard.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/mobile_home.dart';
import 'package:arunstore/screen/mobile_account.dart';
import 'package:arunstore/screen/registerscreen.dart';
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

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _goToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductDashboard()),
    );
  }

  void _navigateToCategoryFilter(Map<String, List<Product>> categories, {String? initialCategory}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFilterPage(
          categories: categories,
          initialSelectedCategory: initialCategory,
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
        builder: (_) => CategoryFilterPage(categories: map),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    final isLoggedIn = authManager.isLoggedIn;

    final screens = [
      MobileHomeScreen(
        categoryMap: _categoryMap,
        allProducts: _allProducts,
        loading: _loading,
        error: _error,
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
              : CategoryFilterPage(categories: _categoryMap),
      const CartPage(),
      isLoggedIn ? const Allorder() : _buildLoginPrompt(),
      isLoggedIn
          ? MobileAccountScreen(
              onLogoutTap: () async {
                await authManager.logout();
                setState(() {});
              },
              onDashboardTap: _goToDashboard,
            )
          : MobileAccountScreen(
              onLogoutTap: () {},
              onDashboardTap: _goToDashboard,
              showLoginPrompt: true,
              onLoginTap: _goToLogin,
              onRegisterTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(),
                  ),
                );
              },
            ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.grey400),
              const SizedBox(height: 16),
              const Text(
                'Sign in to view your orders',
                style: TextStyle(fontSize: 18, color: AppColors.grey600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _goToLogin,
                child: const Text('Login'),
              ),
            ],
          ),
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
          icon: Builder(
            builder: (context) {
              final cart = Provider.of<CartManager>(context, listen: true);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            isLoggedIn ? Icons.shopping_bag : Icons.shopping_bag_outlined,
          ),
          label: 'Orders',
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
