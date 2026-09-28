import 'package:arunstore/screen/dashboard/homepage.dart';
import 'package:arunstore/screen/mobile_main.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Chooses the same app layout for both fresh logins and restored sessions.
class AppHomeScreen extends StatelessWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.isDesktop(context)
        ? const HomeScreen()
        : const MobileMainScreen();
  }
}
