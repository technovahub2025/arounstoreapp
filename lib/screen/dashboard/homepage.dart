
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/dashboard/categories.dart';
import 'package:arunstore/screen/dashboard/categoriesimage.dart';
import 'package:arunstore/screen/dashboard/hero.dart';
import 'package:arunstore/service/homescreenfunction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeScreenLogic? _logic;
  bool _isInitializing = true;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isInitializing || _logic == null) {
      return _buildLoadingScaffold();
    }

    
    if (_logic!.authLoading) {
      return _buildLoadingScaffold();
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF15803D),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTopBar(),
            _buildMainAppBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 30,
      width: double.infinity,
      color: const Color(0xFF15803D),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLocationInfo(),
         
          if (_logic != null && _logic!.isLoggedIn && _logic!.isAdmin) 
            _buildAdminBadge(), 
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'PUDUCHERRY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user, size: 12, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAppBar(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildLogo(),
          const Spacer(),
          if (MediaQuery.of(context).size.width > 768) _buildDesktopMenu(),
          _buildIconsSection(context),
          if (MediaQuery.of(context).size.width <= 768) _buildMobileMenuButton(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return const Text(
      'AROUN STORES',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF15803D),
      ),
    );
  }

  Widget _buildDesktopMenu() {
    // Add null check at the beginning of method
    if (_logic == null) return Container();
    
    return Row(
      children: [
        _buildNavItem('Home', isActive: true),
        _buildNavItem('Filter Products', onTap: () {
          _logic!.openAllCategoriesFilter(context, _logic!.categoryMap);
        }),
        if (_logic!.isAdmin) 
          _buildNavItem('Dashboard', onTap: () => _logic!.goToDashboard(context)),
        _buildNavItem('Contact'),
      ],
    );
  }

  Widget _buildNavItem(String title, {bool isActive = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isActive ? const Color(0xFF15803D) : Colors.grey[700],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildIconsSection(BuildContext context) {
    return Row(
      children: [
        _buildCartIcon(context),
        _buildUserIcon(context),
      ],
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cartManager, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
            if (cartManager.totalItems > 0)
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    cartManager.totalItems.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserIcon(BuildContext context) {
    
    if (_logic == null) return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.person_outline, color: Colors.grey),
    );
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
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
          },
          icon: Icon(
            Icons.person_outline,
            color: _logic!.isLoggedIn ? const Color(0xFF15803D) : Colors.grey[700],
          ),
        ),
        if (_logic!.isLoggedIn)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileMenuButton(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu),
        );
      },
    );
  }

  Widget? _buildDrawer(BuildContext context) {
    if (MediaQuery.of(context).size.width > 768) return null;
    if (_logic == null) return null; 

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          if (_logic!.isLoggedIn) _buildUserInfoSection(),
          ..._buildDrawerItems(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    if (_logic == null) return const DrawerHeader(
      decoration: BoxDecoration(color: Color(0xFF15803D)),
      child: Center(
        child: Text(
          'Loading...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    return DrawerHeader(
      decoration: const BoxDecoration(color: Color(0xFF15803D)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'aroun stores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_logic!.authManager.currentUser != null)
            Text(
              _logic!.authManager.currentUser!.phone ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    if (_logic == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome,',
            style: TextStyle(
              fontSize: 25,
              color: Colors.grey[600],
            ),
          ),
          Text(
            _logic!.authManager.currentUser?.name ?? 'User',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Color(0xFF15803D),
            ),
          ),
          if (_logic!.isAdmin)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    if (_logic == null) return []; 

    return [
      if (_logic!.isLoggedIn)
        _buildDrawerItem('My Profile', Icons.person),
      
      _buildDrawerItem('Contact', Icons.contact_phone),
      
      _buildDrawerItem('Filter', Icons.filter, onTap: () {
        Navigator.pop(context);
        _logic!.openAllCategoriesFilter(context, _logic!.categoryMap);
      }),

      if (_logic!.isAdmin)
        _buildDrawerItem('Dashboard', Icons.dashboard, onTap: () {
          Navigator.pop(context);
          _logic!.goToDashboard(context);
        }),
      
      if (_logic!.isLoggedIn)
        _buildDrawerItem('My Orders', Icons.shopping_cart),
      
      if (_logic!.isLoggedIn)
        _buildDrawerItem('Wishlist', Icons.favorite_border),
      
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
    ];
  }

  Widget _buildDrawerItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF15803D)),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_logic == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      controller: _logic!.scrollController,
      child: Column(
        children: [
          const HeroSection(),
          const SizedBox(height: 20),
          _buildCategoriesHeader(),
          const SizedBox(height: 10),
          _buildCategoriesCarousel(),
          const SizedBox(height: 10),
          _buildCategoryImagesHorizontal(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoriesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Shop by Categories",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCarousel() {
    if (_logic == null) return _buildLoadingState();
    if (_logic!.loading) return _buildLoadingState();
    if (_logic!.error != null) return _buildErrorState();
    if (_logic!.categoryMap.isEmpty) return _buildEmptyState();

    return CategoriesCarousel(
      categories: _logic!.categoryMap,
      onCategoryTap: (categoryName) {
        _logic!.onCategoryImageTap(context, categoryName, _logic!.categoryMap);
      },
    );
  }

  Widget _buildCategoryImagesHorizontal() {
    if (_logic == null) return _buildLoadingState();
    if (_logic!.loading) return _buildLoadingState();
    if (_logic!.error != null) return _buildErrorState();
    if (_logic!.categoryMap.isEmpty) return _buildEmptyState();

    return CategoryImagesHorizontal(
      categories: _logic!.categoryMap,
      onCategoryTap: (categoryName) {
        _logic!.onCategoryImageTap(context, categoryName, _logic!.categoryMap);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF15803D)),
          SizedBox(height: 10),
          Text('Loading categories...'),
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
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(_logic?.error ?? 'An error occurred', textAlign: TextAlign.center), 
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
              backgroundColor: const Color(0xFF15803D),
            ),
            child: const Text('Retry'),
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
          Icon(Icons.category_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text('No categories found'),
        ],
      ),
    );
  }

  Widget? _buildBottomNavigationBar(BuildContext context) {
    if (MediaQuery.of(context).size.width > 768) return null;
    if (_logic == null) return null;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          _logic!.openAllCategoriesFilter(context, _logic!.categoryMap);
        } else if (index == 3) {
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
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.filter_list),
          label: 'Filter',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
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
                      color: Colors.green,
                      shape: BoxShape.circle,
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

