import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
// home_logic.dart
import 'package:arunstore/adminscreen/dashboard.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/allorder.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/screen/dashboard/wishlist.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/registerscreen.dart';
import 'package:arunstore/service/categoryservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class HomeScreenLogic {
  final ProductController controller = ProductController();
  final AuthManager authManager = AuthManager();
  
  Map<String, List<Product>> categoryMap = {};
  List<Product> allProducts = [];
  bool loading = true;
  String? error;
  bool authLoading = true;
  bool isAdmin = false;
  bool isLoggedIn = false;
  final ScrollController scrollController = ScrollController();

  // Navigation methods
  void openAllCategoriesFilter(BuildContext context, Map<String, List<Product>> categories) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFilterPage(
          categories: categories,
        ),
      ),
    );
  }

  void onCategoryImageTap(BuildContext context, String categoryName, Map<String, List<Product>> categories) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFilterPage(
          categories: categories,
          initialSelectedCategory: categoryName,
        ),
      ),
    );
  }

  void goToDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductDashboard(),
      ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      ),
    );
  }

  Future<void> logoutUser(BuildContext context) async {
    await authManager.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: AppText('Logged out successfully')),
    );
  }

  void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Logout'),
        content: const AppText('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await logoutUser(context);
            },
            child:  AppText('Logout', style: TextStyle(color: context.appForeground(Colors.red))),
          ),
        ],
      ),
    );
  }

  // User menu methods
  void showUserMenu(BuildContext context, {
    required bool isLoggedIn,
    required bool isAdmin,
    required String? userName,
    required VoidCallback onDashboardTap,
    required VoidCallback onLoginTap,
    required VoidCallback onRegisterTap,
    required VoidCallback onLogoutTap,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoggedIn)
                ListTile(
                  leading:  CircleAvatar(
                    backgroundColor: context.appSurface(Color(0xFF15803D)),
                    child: Icon(Icons.person, color: context.appForeground(Colors.white)),
                  ),
                  title: AppText(
                    userName ?? 'My Account',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: AppText(userName ?? ''),
                ),
              
              if (isAdmin)
                ListTile(
                  leading:  Icon(Icons.dashboard, color: context.appForeground(Colors.green)),
                  title: const AppText('Admin Dashboard'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDashboard()));
                  },
                ),
              
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const AppText('My Orders'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Allorder()));
                  },
                ),
              
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const AppText('Wishlist'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
                  },
                ),
              
              const Divider(),
              
              if (isLoggedIn)
                ListTile(
                  leading:  Icon(Icons.logout, color: context.appForeground(Colors.red)),
                  title:  AppText('Logout', style: TextStyle(color: context.appForeground(Colors.red))),
                  onTap: () {
                    Navigator.pop(context);
                    onLogoutTap();
                  },
                ),
              
              if (!isLoggedIn) ...[
                ListTile(
                  leading:  Icon(Icons.login, color: context.appForeground(Color(0xFF15803D))),
                  title:  AppText('Login', style: TextStyle(color: context.appForeground(Color(0xFF15803D)))),
                  onTap: () {
                    Navigator.pop(context);
                    onLoginTap();
                  },
                ),
                ListTile(
                  leading:  Icon(Icons.person_add, color: context.appForeground(Colors.blue)),
                  title:  AppText('Register', style: TextStyle(color: context.appForeground(Colors.blue))),
                  onTap: () {
                    Navigator.pop(context);
                    onRegisterTap();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Data loading methods
  Future<void> initializeAuthAndData() async {
    try {
      if (kDebugMode) {
        print('🚀 === INITIALIZING AUTH ===');
      }
      
      if (kDebugMode) {
        print('✅ Auth initialized');
        print('📱 Current user: ${authManager.currentUser?.name}');
        print('👤 User role: ${authManager.currentUser?.role}');
        print('🔍 isAdmin from authManager: ${authManager.isAdmin}');
        print('🔐 isLoggedIn from authManager: ${authManager.isLoggedIn}');
      }
      
      isAdmin = authManager.isAdmin;
      isLoggedIn = authManager.isLoggedIn;
      authLoading = false;
      
      if (kDebugMode) {
        print('📊 Local variables updated:');
        print('   isAdmin: $isAdmin');
        print('   isLoggedIn: $isLoggedIn');
        print('🚀 === AUTH INIT COMPLETE ===\n');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _initializeAuthAndData: $e');
      }
      error = 'Failed to initialize app';
      authLoading = false;
    }
  }

  Future<void> loadCategories() async {
    if (kDebugMode) {
      print('Starting to load categories...');
    }
    
    try {
      loading = true;
      error = null;
      
       final data = await controller.fetchProductsByCategory();
       categoryMap = data;
       allProducts = data.values.expand((products) => products).toList();
       loading = false;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error loading categories: $e');
        print('Stack trace: $stackTrace');
      }
      
      categoryMap = {};
      allProducts = [];
      loading = false;
      error = 'Failed to load categories. Please check your internet connection.';
    }
  }

  void setupAuthListener(VoidCallback onStateChanged) {
    authManager.addListener(() {
      isAdmin = authManager.isAdmin;
      isLoggedIn = authManager.isLoggedIn;
      onStateChanged();
      
      if (kDebugMode) {
        print('Auth state changed:');
        print('   isAdmin: $isAdmin');
        print('   isLoggedIn: $isLoggedIn');
      }
    });
  }

  List<Product> get dealProducts => allProducts.where((p) {
    final discount = p.discountPercent;
    return discount != null && discount > 0;
  }).toList();

  

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return allProducts;
    final lowerQuery = query.toLowerCase();
    return allProducts.where((product) {
      final name = product.name?.toLowerCase() ?? '';
      final category = product.category?.toLowerCase() ?? '';
      final description = product.description?.toLowerCase() ?? '';
      return name.contains(lowerQuery) ||
          category.contains(lowerQuery) ||
          description.contains(lowerQuery);
    }).toList();
  }

  void navigateToSearchResults(BuildContext context, String query) {
    final results = searchProducts(query);
    final categoryMap = <String, List<Product>>{};
    if (results.isNotEmpty) {
      categoryMap['Search Results'] = results;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFilterPage(
          categories: categoryMap,
        ),
      ),
    );
  }

  // Cleanup
  void dispose() {
    scrollController.dispose();
  }
}
