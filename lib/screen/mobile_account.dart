import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/model/rolechoose.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileAccountScreen extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const MobileAccountScreen({
    super.key,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    final user = authManager.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: authManager.isLoggedIn && user != null
            ? _buildProfile(context, user)
            : const Center(
                child: Text(
                  'No profile data available',
                  style: TextStyle(color: AppColors.grey600),
                ),
              ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    final details = <(String, String)>[
      if (user.name.trim().isNotEmpty) ('Name', user.name.trim()),
      if ((user.phone ?? '').trim().isNotEmpty)
        ('Phone', user.phone!.trim()),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.green100,
                child: Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          detail.$1,
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detail.$2,
                          style: const TextStyle(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: onLogoutTap,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
