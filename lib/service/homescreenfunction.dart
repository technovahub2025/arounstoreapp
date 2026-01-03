// home_logic.dart
import 'package:arunstore/adminscreen/dashboard.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/registerscreen.dart';
import 'package:arunstore/service/categoryservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class HomeScreenLogic {
  final ProductController controller = ProductController();
  final AuthManager authManager = AuthManager();
  
  Map<String, List<Product>> categoryMap = {};
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
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await logoutUser(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF15803D),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    userName ?? 'My Account',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(userName ?? ''),
                ),
              
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.green),
                  title: const Text('Admin Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    onDashboardTap();
                  },
                ),
              
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('My Orders'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Wishlist'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              
              const Divider(),
              
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    onLogoutTap();
                  },
                ),
              
              if (!isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.login, color: Color(0xFF15803D)),
                  title: const Text('Login', style: TextStyle(color: Color(0xFF15803D))),
                  onTap: () {
                    Navigator.pop(context);
                    onLoginTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.blue),
                  title: const Text('Register', style: TextStyle(color: Colors.blue)),
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
      loading = false;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error loading categories: $e');
        print('Stack trace: $stackTrace');
      }
      
      categoryMap = {};
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
        print('🔄 Auth state changed:');
        print('   isAdmin: $isAdmin');
        print('   isLoggedIn: $isLoggedIn');
      }
    });
  }

  // Cleanup
  void dispose() {
    scrollController.dispose();
  }
}