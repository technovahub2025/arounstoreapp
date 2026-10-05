import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground(const Color(0xFF0B3D2E)), // Dark Green
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(
                Icons.eco,
                color: context.appForeground(Colors.white),
                size: 90,
              ),
              const SizedBox(height: 30),

               AppText(
                'Welcome',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: context.appForeground(Colors.white),
                ),
              ),

              const SizedBox(height: 10),

               AppText(
                'Let’s get started',
                style: TextStyle(
                  fontSize: 16,
                  color: context.appForeground(Colors.white70),
                ),
              ),

              const SizedBox(height: 50),

              // OUTLINED LOGIN BUTTON
              OutlinedButton(
                onPressed: () {
                  // Navigate to Login Page
                },
                style: OutlinedButton.styleFrom(
                  side:  BorderSide(color: context.appBorder(Colors.white), width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child:  AppText(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: context.appForeground(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
