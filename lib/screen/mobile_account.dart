import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/allorder.dart';
import 'package:arunstore/screen/dashboard/wishlist.dart';
import 'package:arunstore/model/model/rolechoose.dart';

class MobileAccountScreen extends StatefulWidget {
  final VoidCallback onLogoutTap;
  final VoidCallback onDashboardTap;
  final bool showLoginPrompt;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;

  const MobileAccountScreen({
    super.key,
    required this.onLogoutTap,
    required this.onDashboardTap,
    this.showLoginPrompt = false,
    this.onLoginTap,
    this.onRegisterTap,
  });

  @override
  State<MobileAccountScreen> createState() => _MobileAccountScreenState();
}

class _MobileAccountScreenState extends State<MobileAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    final user = authManager.currentUser;
    final isLoggedIn = authManager.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoggedIn && !widget.showLoginPrompt
            ? _buildLoggedInView(user)
            : _buildLoggedOutView(),
      ),
    );
  }

  Widget _buildLoggedInView(User? user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserHeader(user),
          const SizedBox(height: 24),
          _buildAccountSection(),
          const SizedBox(height: 24),
          _buildOrdersPreview(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.green100,
              child: Icon(Icons.person, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign in to your account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Access your orders, wishlist, and preferences',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onLoginTap,
                child: const Text('Login'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onRegisterTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(User? user) {
    final name = user?.name ?? 'User';
    final phone = user?.phone ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.white,
            child: Icon(Icons.person, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: const TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 4),
                Text(
                  user?.role == 'admin' ? 'Admin User' : 'Standard User',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildListSection('Account', [
      _buildListTile(Icons.person_outline, 'My Profile', onTap: () {}),
      _buildListTile(Icons.location_on_outlined, 'My Addresses', onTap: () {}),
      _buildListTile(Icons.payment_outlined, 'Payment Methods', onTap: () {}),
      _buildListTile(Icons.notifications_outlined, 'Notifications', onTap: () {}),
      _buildListTile(Icons.help_outline, 'Help & Support', onTap: () {}),
    ]);
  }

  Widget _buildOrdersPreview() {
    return _buildListSection('Orders', [
      _buildListTile(Icons.shopping_bag_outlined, 'My Orders', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const Allorder()));
      }),
      _buildListTile(Icons.favorite_border, 'Wishlist', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()));
      }),
      _buildListTile(Icons.local_shipping_outlined, 'Track Order', onTap: () {}),
    ]);
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          _buildListTile(Icons.settings_outlined, 'App Settings', onTap: () {}),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
          _buildListTile(Icons.description_outlined, 'Terms & Conditions', onTap: () {}),
          const Divider(height: 1),
          _buildListTile(
            Icons.logout,
            'Logout',
            textColor: AppColors.red,
            iconColor: AppColors.red,
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
            onPressed: () {
              Navigator.pop(context);
              widget.onLogoutTap();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.darkText,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.grey400),
      onTap: onTap,
    );
  }
}
