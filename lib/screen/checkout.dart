import 'package:arunstore/cart/allorder.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = 'cod';

  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when not needed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= DELIVERY INFO =================
            const Text(
              'DELIVERY INFORMATION',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _card(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            'First Name',
                            controller: _firstNameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _input(
                            'Last Name',
                            controller: _lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _input(
                      'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      'Street Address',
                      controller: _streetController,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            'City',
                            controller: _cityController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _input(
                            'State',
                            controller: _stateController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            'Zip Code',
                            controller: _zipCodeController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _input(
                            'Country',
                            enabled: false,
                            initialValue: 'India',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _input(
                      'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= PAYMENT =================
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _card(
              child: Column(
                children: [
                  _paymentTile(
                    title: 'UPI Payment',
                    subtitle: 'Pay using UPI apps like GPay, PhonePe, Paytm',
                    value: 'upi',
                  ),
                  const Divider(),
                  _paymentTile(
                    title: 'Credit/Debit Card',
                    subtitle: 'Pay securely using your card',
                    value: 'card',
                  ),
                  const Divider(),
                  _paymentTile(
                    title: 'Cash on Delivery',
                    subtitle: 'Pay when your order is delivered',
                    value: 'cod',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= PLACE ORDER =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Show loading or process payment here
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Allorder()),
                    );
                  }
                },
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= WIDGETS =================

  Widget _input(
    String hint, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? initialValue,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'Required';
        }
        
        // Email validation
        if (keyboardType == TextInputType.emailAddress && value!.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Enter a valid email';
          }
        }
        
        // Phone number validation
        if (keyboardType == TextInputType.phone && value!.isNotEmpty) {
          final phoneRegex = RegExp(r'^[0-9]{10}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'Enter a valid 10-digit phone number';
          }
        }
        
        // Zip code validation
        if (keyboardType == TextInputType.number && hint == 'Zip Code') {
          if (value!.isNotEmpty && value.length < 6) {
            return 'Enter a valid 6-digit zip code';
          }
        }
        
        return null;
      },
    );
  }

  Widget _paymentTile({
    required String title,
    required String subtitle,
    required String value,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: paymentMethod,
      onChanged: (val) {
        setState(() {
          paymentMethod = val!;
        });
      },
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}