import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/cart/allorder.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/dashboard/wishlist.dart';
import 'package:arunstore/screen/mobile_account.dart';
import 'package:arunstore/screen/settings/settings_screen.dart';
import 'package:arunstore/service/homescreenfunction.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:arunstore/widgets/app_footer.dart';
import 'package:arunstore/widgets/app_header.dart';

import 'package:arunstore/widgets/category_carousel.dart';
import 'package:arunstore/widgets/hero_banner.dart';
import 'package:arunstore/widgets/newsletter_section.dart';
import 'package:arunstore/widgets/product_carousel.dart';
import 'package:arunstore/widgets/promo_banner_card.dart';
import 'package:arunstore/widgets/service_feature_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeScreenLogic? _logic;
  bool _isInitializing = true;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _navItems = [
    'Home',
    'Shop by Category',
    'Shop',
    'Offers',
    'Best Sellers',
    'New Arrivals',
    'Combo Deals',
    'Blog',
    'Contact Us',
    'Settings',
  ];
  final String _activeNavItem = 'Home';

  @override
  void initState() {
    super.initState();
    _logic = HomeScreenLogic();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _logic!.initializeAuthAndData();
      await _logic!.loadCategories();
      _logic!.setupAuthListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing app: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _logic?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleNavTap(String item) {
    if (_logic == null) return;

    switch (item) {
      case 'Settings':
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
        );
        break;
      case 'Shop by Category':
      case 'Shop':
        _logic!.openAllCategoriesFilter(context, _logic!.categoryMap);
        break;
      case 'Offers':
      case 'Combo Deals':
        _navigateToDeals();
        break;
      case 'Best Sellers':
        _navigateToTopRated();
        break;
      case 'New Arrivals':
        _navigateToAllProducts();
        break;
      case 'Blog':
        _showComingSoon(item);
        break;
      case 'Contact Us':
        _showContactInfo();
        break;
      default:
        break;
    }
  }

  void _navigateToDeals() {
    if (_logic == null) return;
    final dealProducts = _logic!.dealProducts;
    _navigateToProductList(dealProducts, 'Best Deals');
  }

  void _navigateToTopRated() {
    if (_logic == null) return;
    final topRated = List.of(_logic!.allProducts);
    topRated.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    _navigateToProductList(topRated, 'Best Sellers');
  }

  void _navigateToAllProducts() {
    if (_logic == null) return;
    _navigateToProductList(List.of(_logic!.allProducts), 'New Arrivals');
  }

  void _navigateToProductList(List<dynamic> products, String title) {
    final map = <String, List<Product>>{title: products.cast<Product>()};
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFilterPage(categories: map),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText('$feature - Coming Soon!')),
    );
  }

  void _showContactInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactRow(Icons.phone, 'Phone', '1800-123-4560'),
            _buildContactRow(Icons.email_outlined, 'Email', 'support@arounstores.com'),
            _buildContactRow(Icons.location_on, 'Address', 'Puducherry, India'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
              AppText(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _logic == null) {
      return _buildLoadingScaffold();
    }

    if (_logic!.authLoading) {
      return _buildLoadingScaffold();
    }

    final isDesktop = AppTheme.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop ? null : _buildMobileAppBar(),
      drawer: isDesktop ? null : _buildMobileDrawer(),
      body: _buildBody(context),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildLogo(),
                const Spacer(),
                _buildCartIcon(),
                const SizedBox(width: 8),
                _buildUserAccountButton(),
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_logic == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBarSection(),
          _buildNavigationSection(),
          HeroBanner(
            categoryMap: _logic!.categoryMap,
          ),
          _buildCategorySection(),
          _buildBestDealsSection(),
          _buildPromoBannerStrip(),
          const ServiceFeatureBar(),
          const SizedBox(height: 24),
       
          const SizedBox(height: 24),
          const NewsletterSection(),
          const SizedBox(height: 24),
         
        ],
      ),
    );
  }

  Widget _buildAppBarSection() {
    return AppHeader(
      logic: _logic!,
      searchController: _searchController,
      onSearchChanged: _onSearchChanged,
      navItems: _navItems,
      activeNavItem: _activeNavItem,
      onNavTap: _handleNavTap,
    );
  }

  Widget _buildNavigationSection() {
    final isDesktop = AppTheme.isDesktop(context);
    if (!isDesktop) return const SizedBox.shrink();

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 4, runSpacing: 4,
        children: _navItems.map((item) {
          final isActive = _activeNavItem == item;
          return TextButton(
            onPressed: () => _handleNavTap(item),
            style: TextButton.styleFrom(
              foregroundColor: isActive ? AppColors.primary : AppColors.mutedText,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: AppText(
              item,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.mutedText,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppText(
            'Shop by Category',
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.darkText,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_logic!.loading)
          _buildLoadingState('Loading categories...')
        else if (_logic!.error != null)
          _buildErrorState()
        else if (_logic!.categoryMap.isEmpty)
          _buildEmptyState()
        else
          CategoryCarousel(
            categories: _logic!.categoryMap,
            onCategoryTap: (categoryName) {
              _logic!.onCategoryImageTap(context, categoryName, _logic!.categoryMap);
            },
          ),
      ],
    );
  }

  Widget _buildBestDealsSection() {
    final products = _logic!.dealProducts;
    final title = products.isNotEmpty ? 'Best Deals for You' : 'Top Products';

    if (_logic!.loading || _logic!.allProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return ProductCarousel(
      title: title,
      subtitle: products.isNotEmpty
          ? 'Special discounts just for you'
          : 'Handpicked for you',
      products: products.isNotEmpty ? products : _logic!.allProducts,
    );
  }

  Widget _buildPromoBannerStrip() {
    final banners = [
      PromoBannerConfig(
        title: 'Save More with Combo Deals',
        subtitle: 'Buy more, save more on groceries',
        offer: 'UP TO 30% OFF',
        backgroundColor: AppColors.cream,
        accentColor: AppColors.primary,
        icon: Icons.local_offer,
        onTap: (context) => _handleNavTap('Combo Deals'),
      ),
      PromoBannerConfig(
        title: 'Big Savings',
        subtitle: 'On Daily Essentials',
        offer: 'UP TO 40% OFF',
        backgroundColor: AppColors.green100,
        accentColor: AppColors.amber,
        icon: Icons.savings,
        onTap: (context) => _handleNavTap('Offers'),
      ),
      PromoBannerConfig(
        title: 'Monthly Sale',
        subtitle: "Don't Miss Out!",
        offer: 'LIMITED TIME',
        backgroundColor: AppColors.lightGreen,
        accentColor: AppColors.primary,
        icon: Icons.calendar_month,
        onTap: (context) => _handleNavTap('New Arrivals'),
      ),
      PromoBannerConfig(
        title: 'Free Delivery',
        subtitle: 'On Orders Above ₹499',
        offer: 'FREE',
        backgroundColor: AppColors.green100,
        accentColor: AppColors.primaryLight,
        icon: Icons.local_shipping,
        onTap: (context) {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: AppText(
            'Special Offers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        PromoBannerStrip(banners: banners),
      ],
    );
  }

  Widget _buildLogo() {
    return AppText(
      'AROUN STORES',
      style: AppTextStyles.displaySmall.copyWith(
        color: AppColors.primary,
        letterSpacing: 1,
        fontSize: 22,
      ),
    );
  }



  Widget _buildCartIcon() {
    return Consumer<CartManager>(
      builder: (context, cartManager, child) {
        final hasItems = cartManager.totalItems > 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              color: AppColors.darkText,
              iconSize: 24,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
            if (hasItems)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: AppText(
                    cartManager.totalItems.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserAccountButton() {
    return Consumer<AuthManager>(
      builder: (context, authManager, child) {
        final isLogged = authManager.isLoggedIn;

        return GestureDetector(
          onTap: () {
            _logic!.showUserMenu(
              context,
              isLoggedIn: isLogged,
              isAdmin: _logic!.isAdmin,
              userName: authManager.currentUser?.name,
              onDashboardTap: () => _logic!.goToDashboard(context),
              onLoginTap: () => _logic!.goToLogin(context),
              onRegisterTap: () => _logic!.goToRegister(context),
              onLogoutTap: () => _logic!.showLogoutConfirmation(context),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLogged ? AppColors.green50 : AppColors.grey100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLogged ? AppColors.green200 : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isLogged ? AppColors.primary : AppColors.grey300,
                  child: Icon(
                    isLogged ? Icons.person : Icons.person_outline,
                    color: isLogged ? AppColors.white : AppColors.grey500,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScaffold() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 10),
          AppText(message, style: TextStyle(color: AppColors.grey600)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 40),
          const SizedBox(height: 10),
          AppText(
            _logic?.error ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey700),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (mounted && _logic != null) {
                setState(() {
                  _logic!.loading = true;
                });
              }
              _logic?.loadCategories().then((_) {
                if (mounted) {
                  setState(() {});
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const AppText('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 40, color: AppColors.grey400),
          SizedBox(height: 10),
          AppText('No categories found'),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    if (_logic == null) return const Drawer();

    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const AppText(
                  'AROUN STORES',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_logic!.authManager.currentUser != null)
                  AppText(
                    _logic!.authManager.currentUser!.phone ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
              ],
            ),
          ),
          if (_logic!.isLoggedIn)
            _buildDrawerItem('My Profile', Icons.person, onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MobileAccountScreen(
                    onLogoutTap: () async {
                      await _logic!.authManager.logout();
                    },
                  ),
                ),
              );
            }),
          _buildDrawerItem('Contact', Icons.contact_phone, onTap: () {
            Navigator.pop(context);
            _showContactInfo();
          }),
          _buildDrawerItem('Settings', Icons.settings_outlined, onTap: () {
            Navigator.pop(context);
            _handleNavTap('Settings');
          }),
          _buildDrawerItem('Filter Products', Icons.filter_alt, onTap: () {
            Navigator.pop(context);
            _logic!.openAllCategoriesFilter(context, _logic!.categoryMap);
          }),
          if (_logic!.isAdmin)
            _buildDrawerItem('Dashboard', Icons.dashboard, onTap: () {
              Navigator.pop(context);
              _logic!.goToDashboard(context);
            }),
          if (_logic!.isLoggedIn)
            _buildDrawerItem('My Orders', Icons.shopping_bag, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Allorder()));
            }),
          if (_logic!.isLoggedIn)
            _buildDrawerItem('Wishlist', Icons.favorite_border, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()));
            }),
          const Divider(),
          if (_logic!.isLoggedIn)
            _buildDrawerItem('Logout', Icons.logout, onTap: () {
              Navigator.pop(context);
              _logic!.showLogoutConfirmation(context);
            }),
          if (!_logic!.isLoggedIn) ...[
            _buildDrawerItem('Login', Icons.login, onTap: () {
              Navigator.pop(context);
              _logic!.goToLogin(context);
            }),
            _buildDrawerItem('Register', Icons.person_add, onTap: () {
              Navigator.pop(context);
              _logic!.goToRegister(context);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: AppText(
        title,
        style: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMobileBottomNav() {
    if (_logic == null) return const SizedBox.shrink();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      onTap: (index) {
        if (index == 0) {
          // Home - already here
        } else if (index == 1) {
          _logic!.openAllCategoriesFilter(context, _logic!.categoryMap);
        } else if (index == 2) {
          _logic!.showUserMenu(
            context,
            isLoggedIn: _logic!.isLoggedIn,
            isAdmin: _logic!.isAdmin,
            userName: _logic!.authManager.currentUser?.name,
            onDashboardTap: () => _logic!.goToDashboard(context),
            onLoginTap: () => _logic!.goToLogin(context),
            onRegisterTap: () => _logic!.goToRegister(context),
            onLogoutTap: () => _logic!.showLogoutConfirmation(context),
          );
        }
      },
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
            children: [
              const Icon(Icons.person),
              if (_logic!.isLoggedIn)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
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
