import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/model/authmodel.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/service/authservice.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User user = User(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      final response = await ApiService.register(user);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: AppText('Registration successful!'),
            backgroundColor: context.appSurface(Colors.green),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText('Registration failed! ${response.body}'),
            backgroundColor: context.appSurface(Colors.red),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText('Error: $e'),
          backgroundColor: context.appSurface(Colors.red),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: context.appForeground(Colors.green.shade700),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: context.appSurface(Colors.grey.shade50),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: context.appBorder(Colors.grey.shade200),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: context.appBorder(Colors.grey.shade200),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: context.appBorder(Colors.green.shade600),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:  BorderSide(
          color: context.appBorder(Colors.red),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:  BorderSide(
          color: context.appBorder(Colors.red),
          width: 1.5,
        ),
      ),
      floatingLabelStyle: TextStyle(
        color: context.appForeground(Colors.green.shade700),
        fontWeight: FontWeight.w600,
      ),
    ).localized(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground(Colors.grey.shade100),
      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // TOP GREEN HEADER
            // =========================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                22,
                12,
                22,
                32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.appGradient([
                    Colors.green.shade800,
                    Colors.green.shade600,
                  ]),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: context.appSurface(Colors.white.withOpacity(0.16)),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child:  Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: context.appForeground(Colors.white),
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Logo
                  Container(
                    height: 92,
                    width: 92,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: context.appSurface(Colors.white),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/arounebg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                   AppText(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.appForeground(Colors.white),
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 7),

                  AppText(
                    'Join us and start shopping with ease',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.appForeground(Colors.white.withOpacity(0.88)),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // =========================================================
            // FORM AREA
            // =========================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  25,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // =================================================
                      // WELCOME CARD
                      // =================================================
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: context.appSurface(Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: context.appSurface(Colors.green.shade50),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                color: context.appForeground(Colors.green.shade700),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                   AppText(
                                    'Let’s get you started',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: context.appForeground(Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  AppText(
                                    'Create your account in a few simple steps.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: context.appForeground(Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // FULL NAME
                      // =================================================
                      AppText(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.appForeground(Colors.grey.shade800),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        errorBuilder: localizedFormError,
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 17),

                      // =================================================
                      // PHONE NUMBER
                      // =================================================
                      AppText(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.appForeground(Colors.grey.shade800),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        errorBuilder: localizedFormError,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          icon: Icons.phone_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your phone number';
                          } else if (val.trim().length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 17),

                      // =================================================
                      // PASSWORD
                      // =================================================
                      AppText(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.appForeground(Colors.grey.shade800),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        errorBuilder: localizedFormError,
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: _inputDecoration(
                          label: 'Password',
                          hint: 'Create a password',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: context.appForeground(Colors.grey.shade600),
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a password';
                          } else if (val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 9),

                      // =================================================
                      // PASSWORD REQUIREMENT
                      // =================================================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurface(Colors.green.shade50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 17,
                              color: context.appForeground(Colors.green.shade700),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppText(
                                'Password must contain at least 6 characters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.appForeground(Colors.green.shade800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =================================================
                      // REGISTER BUTTON
                      // =================================================
                      SizedBox(
                        height: 56,
                        child: _isLoading
                            ? Container(
                                decoration: BoxDecoration(
                                  color: context.appSurface(Colors.green.shade600),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.appSurface(Colors.green.shade700),
                                  foregroundColor: context.appForeground(Colors.white),
                                  elevation: 4,
                                  shadowColor:
                                      Colors.green.withOpacity(0.25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(17),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 21,
                                    ),
                                    SizedBox(width: 9),
                                    AppText(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 25),

                      // =================================================
                      // OR DIVIDER
                      // =================================================
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: context.appBorder(Colors.grey.shade300),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            child: AppText(
                              'OR',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.appForeground(Colors.grey.shade500),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: context.appBorder(Colors.grey.shade300),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // =================================================
                      // LOGIN CARD
                      // =================================================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurface(Colors.white),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: context.appBorder(Colors.grey.shade200),
                          ),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 4,
                          children: [
                            AppText(
                              'Already have an account?',
                              style: TextStyle(
                                color: context.appForeground(Colors.grey.shade600),
                                fontSize: 13.5,
                              ),
                            ),
                            TextButton(
                              onPressed: navigateToLogin,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: AppText(
                                'Sign In',
                                style: TextStyle(
                                  color: context.appForeground(Colors.green.shade700),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =================================================
                      // BOTTOM MESSAGE
                      // =================================================
                      Wrap(
                        alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 4,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 15,
                            color: context.appForeground(Colors.grey.shade500),
                          ),
                          const SizedBox(width: 6),
                          AppText(
                            'Your information is kept secure',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.appForeground(Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
