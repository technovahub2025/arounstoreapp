
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/model/rolechoose.dart';
import 'package:arunstore/screen/dashboard/homepage.dart';
import 'package:arunstore/screen/registerscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthManager _authManager = AuthManager();
  
  // For showing loading indicator
  bool _isLoading = false;
  String? _errorMessage;
  
  // ADD THIS: Password visibility toggle
  bool _isPasswordVisible = false;

  void login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Format phone number
      String rawPhone = _phoneController.text;
      String digitsOnly = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
      String phoneWithCode = digitsOnly;
      
      if (digitsOnly.length == 10) {
        phoneWithCode = '+91$digitsOnly';
      } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
        phoneWithCode = '+$digitsOnly';
      } else if (digitsOnly.length == 13 && digitsOnly.startsWith('+91')) {
        phoneWithCode = digitsOnly;
      }
      
      if (kDebugMode) {
        print('Login attempt with phone: $phoneWithCode');
      }
      
      // Use AuthManager
      final result = await _authManager.login(
        phoneWithCode,
        _passwordController.text,
      );
      
      // Handle response
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Login successful'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Get user from result
        final user = result['user'] as User?;
        
        if (user != null) {
          if (kDebugMode) {
            print('Login successful!');
            print('User: ${user.name}');
            print('Role: ${user.role}');
            print('Is Admin: ${user.isAdmin}');
          }
          
          // Navigate based on role
          Widget destination;
          if (user.isAdmin) {
            destination = HomeScreen();
          } else {
            destination = HomeScreen();
          }
          
          // Clear navigation stack and go to appropriate screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => destination),
            (route) => false,
          );
        }
      } else {
        final errorMsg = result['message']?.toString() ?? 'Login failed';
        setState(() {
          _errorMessage = errorMsg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final errorMsg = 'Error: $e';
      setState(() {
        _errorMessage = errorMsg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
      if (kDebugMode) {
        print('Login error: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  // ADD THIS: Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void navigateToSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFF15803D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                
                // Logo or App Title
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
Image.asset('assets/arounebg.png',height: 300,width: 300,)
                    ],
                  ),
                ),
                
                SizedBox(height: 10),
                Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40),
                
                // Error Message Display
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Phone field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixText: '+91',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF15803D)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF15803D)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (val.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
                // Password field with visibility toggle - UPDATED
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF15803D)),
                    // ADD THIS: suffixIcon for visibility toggle
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF15803D),
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF15803D)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  // UPDATED: Use the visibility state
                  obscureText: !_isPasswordVisible,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please enter your password';
                    } else if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 8),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                      // Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF15803D)),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Login button
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF15803D),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: login,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF15803D), // Changed to green
                          foregroundColor: Colors.white, // White text
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                
                SizedBox(height: 20),
                
                // OR divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Sign up option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: navigateToSignup,
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}