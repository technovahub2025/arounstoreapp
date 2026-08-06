import 'dart:async';

import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/cartmodel.dart';
import 'package:arunstore/screen/widgets/checkout_widgets.dart';
import 'package:arunstore/service/order_history_service.dart';
import 'package:arunstore/service/razorpay_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.createOrderUrl = RazorpayService.defaultCreateOrderUrl,
    this.verifyUrl = RazorpayService.defaultVerifyUrl,
    this.authToken,
    this.razorpayKeyId = const String.fromEnvironment('RAZORPAY_KEY_ID'),
    this.clearCartOnSuccess = true,
    this.successRedirectTo = '',
    this.onSuccess,
  });

  final String createOrderUrl;
  final String verifyUrl;
  final String? authToken;
  final String razorpayKeyId;
  final bool clearCartOnSuccess;
  final String successRedirectTo;
  final void Function(RazorpayPaymentVerification verification)? onSuccess;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cart = CartManager.instance;
  final _razorpay = Razorpay();
  final _money = NumberFormat.currency(locale: 'en_IN', symbol: 'INR ', decimalDigits: 0);

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  bool _isProcessing = false;
  bool _isPreparingOrder = false;
  String? _errorMessage;
  RazorpayPaymentVerification? _verification;
  RazorpayOrderResult? _preparedOrder;
  String? _preparedOrderSignature;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    for (final controller in _controllers) {
      controller.addListener(_schedulePreparation);
    }
    _cart.addListener(_schedulePreparation);
    _schedulePreparation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cart.removeListener(_schedulePreparation);
    for (final controller in _controllers) {
      controller.removeListener(_schedulePreparation);
      controller.dispose();
    }
    _razorpay.clear();
    super.dispose();
  }

  List<TextEditingController> get _controllers => [
        _fullNameController,
        _emailController,
        _phoneController,
        _address1Controller,
        _address2Controller,
        _cityController,
        _stateController,
        _pincodeController,
        _countryController,
      ];

  double get _subtotal => _cart.subTotal.toDouble();
  double get _shipping => _cart.total.toDouble() - _subtotal;
  double get _total => _cart.total.toDouble();

  String? get _effectiveAuthToken => widget.authToken ?? AuthManager().token;

  List<Map<String, dynamic>> get _cartItemsPayload => _cart.items
      .map(
        (item) => {
          'id': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
          'image': item.product.imageUrl,
          'category': item.product.category,
        },
      )
      .toList();

  Map<String, dynamic> get _shippingPayload => buildShippingPayload(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine1: _address1Controller.text.trim(),
        addressLine2: _address2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        country: _countryController.text.trim(),
      );

  Future<String?> _resolveAuthToken() async {
    final token = _effectiveAuthToken;
    if (token != null && token.isNotEmpty) return token;

    final prefs = await SharedPreferences.getInstance();
    final values = [prefs.getString('token'), prefs.getString('auth_token')];
    for (final value in values) {
      final clean = value?.trim();
      if (clean != null && clean.isNotEmpty) return clean;
    }
    return null;
  }

  bool _readyToPrepare() {
    return _cart.items.isNotEmpty &&
        widget.razorpayKeyId.trim().isNotEmpty &&
        (_effectiveAuthToken?.isNotEmpty ?? false) &&
        _fullNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _address1Controller.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _pincodeController.text.trim().isNotEmpty &&
        _countryController.text.trim().isNotEmpty;
  }

  String _signature() => [
        _total.toStringAsFixed(2),
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _address1Controller.text.trim(),
        _address2Controller.text.trim(),
        _cityController.text.trim(),
        _stateController.text.trim(),
        _pincodeController.text.trim(),
        _countryController.text.trim(),
        _effectiveAuthToken ?? '',
      ].join('|');

  void _schedulePreparation() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _prepareOrderIfNeeded();
    });
  }

  Future<void> _prepareOrderIfNeeded() async {
    if (!_readyToPrepare()) {
      if (!mounted) return;
      setState(() {
        _preparedOrder = null;
        _preparedOrderSignature = null;
      });
      return;
    }

    final signature = _signature();
    if (_preparedOrder != null && _preparedOrderSignature == signature) return;
    if (_isPreparingOrder) return;

    setState(() {
      _isPreparingOrder = true;
      _errorMessage = null;
    });

    try {
      final token = await _resolveAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please log in again before paying.');
      }

      final order = await RazorpayService.createOrder(
        endpoint: widget.createOrderUrl,
        amount: (_total * 100).round(),
        currency: 'INR',
        cartItems: _cartItemsPayload,
        shippingDetails: _shippingPayload,
        authToken: token,
      );

      if (!mounted) return;
      setState(() {
        _preparedOrder = order;
        _preparedOrderSignature = signature;
        _isPreparingOrder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _preparedOrder = null;
        _preparedOrderSignature = null;
        _isPreparingOrder = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _startPayment() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _verification = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please fix the highlighted fields.');
      return;
    }

    final token = await _resolveAuthToken();
    if (token == null || token.isEmpty) {
      setState(() => _errorMessage = 'Not authenticated. Please log in again before paying.');
      return;
    }

    if (_preparedOrder == null || _preparedOrderSignature != _signature()) {
      await _prepareOrderIfNeeded();
    }
    if (_preparedOrder == null) {
      setState(() => _errorMessage = 'Payment order is still being prepared. Please try again.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      _razorpay.open({
        'key': widget.razorpayKeyId,
        'amount': _preparedOrder!.amount,
        'currency': _preparedOrder!.currency,
        'name': 'Arun Store',
        'description': 'E-commerce checkout',
        'order_id': _preparedOrder!.orderId,
        'prefill': {
          'name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'contact': _phoneController.text.trim(),
        },
        'notes': {
          'customer_name': _fullNameController.text.trim(),
          'shipping_city': _cityController.text.trim(),
          'shipping_state': _stateController.text.trim(),
          'shipping_pincode': _pincodeController.text.trim(),
        },
        'theme': {'color': '#0f172a'},
        'retry': {'enabled': true, 'max_count': 2},
        'modal': {
          'ondismiss': () {
            if (!mounted) return;
            setState(() {
              _isProcessing = false;
              _errorMessage = 'Payment cancelled before completion.';
            });
          }
        },
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    try {
      final verification = await RazorpayService.verifyPayment(
        endpoint: widget.verifyUrl,
        authToken: await _resolveAuthToken(),
        payload: {
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'amount': (_total * 100).round(),
          'currency': 'INR',
          'customer': _shippingPayload['customer'],
          'shippingAddress': _shippingPayload['shippingAddress'],
          'cartItems': _cartItemsPayload,
        },
      );

      if (!mounted) return;
      setState(() {
        _verification = verification;
        _isProcessing = false;
        _errorMessage = verification.success ? null : verification.message;
      });

      if (!verification.success) return;

      OrderHistoryService.instance.addOrder(
        CompletedOrder(
          orderId: response.orderId ?? response.paymentId ?? '',
          paymentId: response.paymentId ?? '',
          signature: response.signature,
          customerName: _fullNameController.text.trim(),
          items: _cart.items
              .map((item) => CartItem(product: item.product, quantity: item.quantity))
              .toList(),
          subtotal: _subtotal,
          shipping: _shipping,
          total: _total,
          createdAt: DateTime.now(),
        ),
      );

      if (widget.clearCartOnSuccess) {
        _cart.clearCart();
      }

      widget.onSuccess?.call(verification);

      if (widget.successRedirectTo.isNotEmpty && mounted) {
        Navigator.of(context).pushReplacementNamed(widget.successRedirectTo);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verified successfully.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Payment succeeded, but verification failed: $error';
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _errorMessage = (response.message ?? '').isNotEmpty
          ? response.message
          : 'Payment failed. Please try again.';
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _errorMessage = 'External wallet selected: ${response.walletName}.';
    });
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email address is required.';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)
        ? null
        : 'Enter a valid email address.';
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required.';
    return RegExp(r'^[0-9+\-\s]{8,15}$').hasMatch(text)
        ? null
        : 'Enter a valid phone number.';
  }

  String? _pincodeValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'PIN code is required.';
    return RegExp(r'^[0-9]{4,10}$').hasMatch(text)
        ? null
        : 'Enter a valid PIN code.';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4F7FB), Color(0xFFE8EEF7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          CheckoutNoticeBanner(
                            message: _errorMessage!,
                            color: const Color(0xFFFFE4E6),
                            textColor: const Color(0xFF9F1239),
                            borderColor: const Color(0xFFFDA4AF),
                          ),
                        ],
                        if (_verification != null && _verification!.success) ...[
                          const SizedBox(height: 16),
                          CheckoutNoticeBanner(
                            message: _verification!.message,
                            color: const Color(0xFFDCFCE7),
                            textColor: const Color(0xFF166534),
                            borderColor: const Color(0xFF86EFAC),
                          ),
                        ],
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 960;
                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: _shippingCard()),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 2, child: _summaryCard()),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _shippingCard(),
                                const SizedBox(height: 20),
                                _summaryCard(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Secure checkout',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your order with Razorpay',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Order creation happens on your backend, and payment verification happens after the checkout modal returns.',
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shippingCard() {
    return CheckoutSectionCard(
      title: 'Shipping details',
      subtitle: 'Enter the address where we should deliver your order.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _responsiveFields(),
            const SizedBox(height: 16),
            _paymentNote(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isProcessing || _isPreparingOrder || _preparedOrder == null)
                    ? null
                    : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : _isPreparingOrder
                        ? const Text(
                            'Preparing payment...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          )
                        : _preparedOrder == null
                            ? const Text(
                                'Fill details to continue',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              )
                            : Text(
                                'Pay now - ${_money.format(_total)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsiveFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 680;
        if (wide) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CheckoutTextField(
                      controller: _fullNameController,
                      label: 'Full name *',
                      hintText: 'Aarav Sharma',
                      validator: (value) => _requiredValidator(value, 'Full name'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CheckoutTextField(
                      controller: _emailController,
                      label: 'Email *',
                      hintText: 'aarav@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CheckoutTextField(
                      controller: _phoneController,
                      label: 'Phone *',
                      hintText: '+91 98765 43210',
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CheckoutTextField(
                      controller: _pincodeController,
                      label: 'PIN code *',
                      hintText: '560001',
                      keyboardType: TextInputType.number,
                      validator: _pincodeValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CheckoutTextField(
                      controller: _cityController,
                      label: 'City *',
                      hintText: 'Bengaluru',
                      validator: (value) => _requiredValidator(value, 'City'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CheckoutTextField(
                      controller: _stateController,
                      label: 'State *',
                      hintText: 'Karnataka',
                      validator: (value) => _requiredValidator(value, 'State'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CheckoutTextField(
                controller: _address1Controller,
                label: 'Address line 1 *',
                hintText: 'House number, street name',
                validator: (value) => _requiredValidator(value, 'Address line 1'),
              ),
              const SizedBox(height: 14),
              CheckoutTextField(
                controller: _address2Controller,
                label: 'Address line 2',
                hintText: 'Apartment, landmark, etc.',
              ),
              const SizedBox(height: 14),
              CheckoutTextField(
                controller: _countryController,
                label: 'Country *',
                hintText: 'India',
                validator: (value) => _requiredValidator(value, 'Country'),
              ),
            ],
          );
        }

        return Column(
          children: [
            CheckoutTextField(
              controller: _fullNameController,
              label: 'Full name *',
              hintText: 'Aarav Sharma',
              validator: (value) => _requiredValidator(value, 'Full name'),
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _emailController,
              label: 'Email *',
              hintText: 'aarav@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _phoneController,
              label: 'Phone *',
              hintText: '+91 98765 43210',
              keyboardType: TextInputType.phone,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _address1Controller,
              label: 'Address line 1 *',
              hintText: 'House number, street name',
              validator: (value) => _requiredValidator(value, 'Address line 1'),
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _address2Controller,
              label: 'Address line 2',
              hintText: 'Apartment, landmark, etc.',
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _cityController,
              label: 'City *',
              hintText: 'Bengaluru',
              validator: (value) => _requiredValidator(value, 'City'),
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _stateController,
              label: 'State *',
              hintText: 'Karnataka',
              validator: (value) => _requiredValidator(value, 'State'),
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _pincodeController,
              label: 'PIN code *',
              hintText: '560001',
              keyboardType: TextInputType.number,
              validator: _pincodeValidator,
            ),
            const SizedBox(height: 14),
            CheckoutTextField(
              controller: _countryController,
              label: 'Country *',
              hintText: 'India',
              validator: (value) => _requiredValidator(value, 'Country'),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard() {
    return CheckoutSectionCard(
      title: 'Order summary',
      subtitle: 'Review the items and totals before paying.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cart.items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text('Your cart is empty. Add products to continue.'),
            )
          else
            Column(
              children: _cart.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.product.imageUrl ?? '',
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: const Color(0xFFE2E8F0),
                              alignment: Alignment.center,
                              child: const Icon(Icons.shopping_bag_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name ?? 'Unnamed product',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Qty ${item.quantity}', style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 6),
                              Text(
                                _money.format((item.product.price ?? 0) * item.quantity),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          PriceRow(label: 'Subtotal', value: _subtotal, formatter: _formatMoney),
          PriceRow(label: 'Shipping', value: _shipping, formatter: _formatMoney),
          const Divider(height: 28),
          PriceRow(label: 'Total', value: _total, formatter: _formatMoney, bold: true),
          const SizedBox(height: 18),
          _supportCard(),
        ],
      ),
    );
  }

  Widget _paymentNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Text(
        'Only the Razorpay Key ID is used on the client. The secret key stays on your backend.',
        style: TextStyle(
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _supportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secure payment flow',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            '1. Create order on backend\n2. Open Razorpay checkout\n3. Verify payment signature\n4. Clear cart and continue',
            style: TextStyle(color: Color(0xFFCBD5E1), height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatMoney(num value) => _money.format(value);
}

