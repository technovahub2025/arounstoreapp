import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'dart:convert';

import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/model/rolechoose.dart';
import 'package:arunstore/screen/app_home.dart';
import 'package:arunstore/screen/registerscreen.dart';
import 'package:arunstore/service/authservice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final AuthManager _authManager = AuthManager();

  bool _isLoading = false;
  String? _errorMessage;

  bool _isPasswordVisible = false;

  Future<void> _forgotPassword() async {
    final phoneController = TextEditingController(text: _phoneController.text.trim());
    final phone = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Reset password'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration:  InputDecoration(labelText: 'Phone number').localized(context),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const AppText('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, phoneController.text.trim()), child: const AppText('Send reset link')),
        ],
      ),
    );
    phoneController.dispose();
    if (phone == null || phone.isEmpty || !mounted) return;
    try {
      final response = await ApiService.forgotPassword(phone);
      final data = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      final message = data['message']?.toString() ?? (response.statusCode >= 200 && response.statusCode < 300
          ? 'Password reset instructions sent.'
          : 'Could not send reset instructions. Please try again.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText(message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AppText('Could not connect to reset your password.')));
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Format phone number
        String rawPhone = _phoneController.text.trim();

        String digitsOnly =
            rawPhone.replaceAll(RegExp(r'[^\d]'), '');

        String phoneWithCode = digitsOnly;

        if (digitsOnly.length == 10) {
          phoneWithCode = '+91$digitsOnly';
        } else if (digitsOnly.length == 12 &&
            digitsOnly.startsWith('91')) {
          phoneWithCode = '+$digitsOnly';
        } else if (digitsOnly.length == 13 &&
            digitsOnly.startsWith('+91')) {
          phoneWithCode = digitsOnly;
        }

        if (kDebugMode) {
          print(
            'Login attempt with phone: $phoneWithCode',
          );
        }

        // Use AuthManager
        final result = await _authManager.login(
          phoneWithCode,
          _passwordController.text,
        );

        // Handle response
        if (result['success'] == true) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(
                result['message']?.toString() ??
                    'Login successful',
              ),
              backgroundColor: context.appSurface(const Color(0xFF15803D)),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            const destination = AppHomeScreen();

            // Clear navigation stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => destination,
              ),
              (route) => false,
            );
          }
        } else {
          final errorMsg =
              result['message']?.toString() ??
                  'Login failed';

          setState(() {
            _errorMessage = errorMsg;
          });

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(errorMsg),
              backgroundColor: context.appSurface(Colors.red.shade700),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        final errorMsg = 'Error: $e';

        setState(() {
          _errorMessage = errorMsg;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(errorMsg),
            backgroundColor: context.appSurface(Colors.red.shade700),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (kDebugMode) {
          print('Login error: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  void navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: TextStyle(
        color: context.appForeground(Colors.grey.shade500),
        fontSize: 14,
      ),

      prefixIcon: Container(
        margin: const EdgeInsets.only(
          left: 12,
          right: 8,
        ),
        child: Icon(
          icon,
          color: context.appForeground(const Color(0xFF15803D)),
          size: 21,
        ),
      ),

      prefixIconConstraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: context.appSurface(const Color(0xFFF5F7F6)),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: context.appBorder(Colors.grey.shade200),
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide:  BorderSide(
          color: context.appBorder(Color(0xFF15803D)),
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: context.appBorder(Colors.red.shade300),
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: context.appBorder(Colors.red.shade400),
          width: 1.5,
        ),
      ),
    ).localized(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: context.appBackground(const Color(0xFFF5F7F6)),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Column(
            children: [

              // ====================================================
              // TOP GREEN SECTION
              // ====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  42,
                ),

                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: context.appGradient([
                      Color(0xFF15803D),
                      Color(0xFF16A34A),
                      Color(0xFF22C55E),
                    ]),
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(42),
                    bottomRight: Radius.circular(42),
                  ),
                ),

                child: Column(
                  children: [

                    // Logo
                    Container(
                      width: 135,
                      height: 135,

                      decoration: BoxDecoration(
                        color: context.appSurface(Colors.white),
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      padding: const EdgeInsets.all(10),

                      child: ClipOval(
                        child: Image.asset(
                          'assets/arounebg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                     AppText(
                      'Welcome Back!',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: context.appForeground(Colors.white),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 7),

                    AppText(
                      'Login to continue shopping with us',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: context.appForeground(Colors.white.withOpacity(0.90)),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // ====================================================
              // LOGIN CARD
              // ====================================================

              Transform.translate(
                offset: const Offset(0, -25),

                child: Container(
                  width: size.width - 32,

                  padding: const EdgeInsets.fromLTRB(
                    20,
                    25,
                    20,
                    20,
                  ),

                  decoration: BoxDecoration(
                    color: context.appSurface(Colors.white),

                    borderRadius: BorderRadius.circular(25),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [

                        // ==================================================
                        // TITLE
                        // ==================================================

                         AppText(
                          'Sign In',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: context.appForeground(Color(0xFF171717)),
                          ),
                        ),

                        const SizedBox(height: 6),

                        AppText(
                          'Enter your details to access your account',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 13,
                            color: context.appForeground(Colors.grey.shade600),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // ERROR MESSAGE
                        // ==================================================

                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,

                            margin: const EdgeInsets.only(
                              bottom: 18,
                            ),

                            padding: const EdgeInsets.all(13),

                            decoration: BoxDecoration(
                              color: context.appSurface(Colors.red.shade50),
                              borderRadius:
                                  BorderRadius.circular(13),

                              border: Border.all(
                                color: context.appBorder(Colors.red.shade100),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Icon(
                                  Icons.error_outline_rounded,
                                  color: context.appForeground(Colors.red.shade600),
                                  size: 21,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: AppText(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color:
                                          context.appForeground(Colors.red.shade700),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ==================================================
                        // PHONE LABEL
                        // ==================================================

                         AppText(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.appForeground(Color(0xFF333333)),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // PHONE FIELD
                        // ==================================================

                        TextFormField(
                          errorBuilder: localizedFormError,
                          controller: _phoneController,

                          keyboardType:
                              TextInputType.phone,

                          textInputAction:
                              TextInputAction.next,

                          decoration: _inputDecoration(
                            hintText:
                                'Enter your phone number',
                            icon: Icons.phone_outlined,
                          ),

                          validator: (val) {
                            if (val == null ||
                                val.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }

                            final digits =
                                val.replaceAll(
                              RegExp(r'[^\d]'),
                              '',
                            );

                            if (digits.length < 10) {
                              return 'Please enter a valid phone number';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // PASSWORD LABEL
                        // ==================================================

                         AppText(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.appForeground(Color(0xFF333333)),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // PASSWORD FIELD
                        // ==================================================

                        TextFormField(
                          errorBuilder: localizedFormError,
                          controller:
                              _passwordController,

                          obscureText:
                              !_isPasswordVisible,

                          textInputAction:
                              TextInputAction.done,

                          onFieldSubmitted: (_) {
                            if (!_isLoading) {
                              login();
                            }
                          },

                          decoration: _inputDecoration(
                            hintText:
                                'Enter your password',
                            icon: Icons.lock_outline_rounded,

                            suffixIcon: IconButton(
                              onPressed:
                                  _togglePasswordVisibility,

                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons
                                        .visibility_rounded
                                    : Icons
                                        .visibility_off_rounded,

                                color:
                                    context.appForeground(Colors.grey.shade600),
                              ),
                            ),
                          ),

                          validator: (val) {
                            if (val == null ||
                                val.isEmpty) {
                              return 'Please enter your password';
                            }

                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // FORGOT PASSWORD
                        // ==================================================

                        Align(
                          alignment:
                              Alignment.centerRight,

                          child: TextButton(
                            onPressed: _forgotPassword,

                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                            ),

                            child:  AppText(
                              'Forgot Password?',
                              style: TextStyle(
                                color: context.appForeground(Color(0xFF15803D)),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================

                        SizedBox(
                          height: 55,
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : login,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  context.appSurface(const Color(0xFF15803D)),

                              disabledBackgroundColor:
                                  context.appSurface(const Color(0xFF86B99A)),

                              foregroundColor: context.appForeground(Colors.white),

                              elevation: 0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),

                            child: _isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      AppText(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),

                                      SizedBox(width: 8),

                                      Icon(
                                        Icons
                                            .arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // OR DIVIDER
                        // ==================================================

                        Row(
                          children: [

                            Expanded(
                              child: Divider(
                                color: context.appBorder(Colors.grey.shade200),
                                thickness: 1,
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),

                              child: AppText(
                                'OR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      context.appForeground(Colors.grey.shade500),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Divider(
                                color: context.appBorder(Colors.grey.shade200),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // SIGN UP
                        // ==================================================

                        Wrap(
                          alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 4,

                          children: [

                            AppText(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    context.appForeground(Colors.grey.shade600),
                              ),
                            ),

                            TextButton(
                              onPressed:
                                  navigateToSignup,

                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.only(
                                  left: 5,
                                ),
                              ),

                              child:  AppText(
                                'Sign Up',
                                style: TextStyle(
                                  color:
                                      context.appForeground(Color(0xFF15803D)),
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w800,
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

              // ====================================================
              // BOTTOM TEXT
              // ====================================================

              Transform.translate(
                offset: const Offset(0, -10),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: AppText(
                    'Fresh products • Easy shopping • Delivered to you',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 11,
                      color: context.appForeground(Colors.grey.shade500),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
