import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/model/rolechoose.dart';
import 'package:arunstore/screen/settings/settings_screen.dart';
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
      backgroundColor: context.appBackground(AppColors.background),
      appBar: AppBar(
        title: const AppText('My Profile'),
        backgroundColor: context.appSurface(AppColors.white),
        foregroundColor: context.appForeground(AppColors.darkText),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: context.tr('Settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: authManager.isLoggedIn && user != null
            ? _buildProfile(context, user)
            :  Center(
                child: AppText(
                  'No profile data available',
                  style: TextStyle(color: context.appForeground(AppColors.grey600)),
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
            color: context.appSurface(AppColors.white),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
               CircleAvatar(
                radius: 38,
                backgroundColor: context.appSurface(AppColors.green100),
                child: Icon(
                  Icons.person_outline,
                  size: 40,
                  color: context.appForeground(AppColors.primary),
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
                        child: AppText(
                          detail.$1,
                          style:  TextStyle(
                            color: context.appForeground(AppColors.grey600),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detail.$2,
                          style:  TextStyle(
                            color: context.appForeground(AppColors.darkText),
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
            label: const AppText('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.appForeground(AppColors.red),
              side:  BorderSide(color: context.appBorder(AppColors.red)),
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
