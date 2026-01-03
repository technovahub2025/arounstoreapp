import 'dart:async';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/screen/dashboard/homepage.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (kDebugMode) {
      print('SplashScreen: Starting app initialization...');
    }

    // Get AuthManager instance
    final authManager = Provider.of<AuthManager>(context, listen: false);
    
    // Initialize auth manager (loads stored data)
    await authManager.initialize();
    
    if (kDebugMode) {
      print('SplashScreen: AuthManager initialized');
      print('SplashScreen: isInitialized = ${authManager.isInitialized}');
      print('SplashScreen: isLoggedIn = ${authManager.isLoggedIn}');
      print('SplashScreen: User = ${authManager.currentUser?.name}');
    }

    // Add a small delay to show splash screen
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
      
      // Navigate based on login status
      _navigateBasedOnAuth();
    }
  }

  Future<void> _navigateBasedOnAuth() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    
    if (kDebugMode) {
      print('SplashScreen: Navigating...');
      print('SplashScreen: Final check - isLoggedIn = ${authManager.isLoggedIn}');
    }
    
    if (await authManager.isLoggedIn) {
      if (kDebugMode) print('SplashScreen: User is logged in, going to HomeScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      if (kDebugMode) print('SplashScreen: User not logged in, going to LoginScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo
            Image.asset('assets/arounebg.png'),
            
            const SizedBox(height: 30),
            
            // Loading indicator
            _isInitializing
                ? Column(
                    children: [
                      CircularProgressIndicator(
                        color: const Color(0xFF15803D).withOpacity(0.7),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}