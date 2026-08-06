import 'package:arunstore/authmanager.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/cartmodel.dart';
import 'package:arunstore/service/order_history_service.dart';
import 'package:arunstore/service/razorpay_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:razorpay_web/razorpay_web.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.createOrderUrl = RazorpayService.defaultCreateOrderUrl,
    this.verifyUrl = RazorpayService.defaultVerifyUrl,
    this.authToken,
    this.razorpayKeyId = const String.fromEnvironment('RAZORPAY_KEY_ID'),
    this.clearCartOnSuccess = true,
  });

  final String createOrderUrl;
  final String verifyUrl;
  final String? authToken;
  final String razorpayKeyId;
  final bool clearCartOnSuccess;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final CartManager _cart = CartManager.instance;
  final Razorpay _razorpay = Razorpay();
  final NumberFormat _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'INR ',
    decimalDigits: 0,
  );

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'India');

  bool _isProcessing = false;
  bool _isPreparingOrder = false;
  String? _errorMessage;
  RazorpayPaymentVerification? _verification;
  RazorpayOrderResult? _preparedOrder;
  String? _preparedOrderSignature;
  Timer? _prepareDebounce;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fullNameController.addListener(_scheduleOrderPreparation);
    _emailController.addListener(_scheduleOrderPreparation);
    _phoneController.addListener(_scheduleOrderPreparation);
    _address1Controller.addListener(_scheduleOrderPreparation);
    _address2Controller.addListener(_scheduleOrderPreparation);
    _cityController.addListener(_scheduleOrderPreparation);
    _stateController.addListener(_scheduleOrderPreparation);
    _pincodeController.addListener(_scheduleOrderPreparation);
    _countryController.addListener(_scheduleOrderPreparation);
    _cart.addListener(_scheduleOrderPreparation);
    _scheduleOrderPreparation();
  }

  @override
  void dispose() {
    _prepareDebounce?.cancel();
    _cart.removeListener(_scheduleOrderPreparation);
    _fullNameController.removeListener(_scheduleOrderPreparation);
    _emailController.removeListener(_scheduleOrderPreparation);
    _phoneController.removeListener(_scheduleOrderPreparation);
    _address1Controller.removeListener(_scheduleOrderPreparation);
    _address2Controller.removeListener(_scheduleOrderPreparation);
    _cityController.removeListener(_scheduleOrderPreparation);
    _stateController.removeListener(_scheduleOrderPreparation);
    _pincodeController.removeListener(_scheduleOrderPreparation);
    _countryController.removeListener(_scheduleOrderPreparation);
    _razorpay.clear();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.subTotal.toDouble();
  double get _shipping => _cart.total.toDouble() - _subtotal;
  double get _total => _cart.total.toDouble();
  String? get _effectiveAuthToken => widget.authToken ?? AuthManager().token;

  Future<String?> _resolveAuthToken() async {
    final managerToken = widget.authToken ?? AuthManager().token;
    if (managerToken != null && managerToken.isNotEmpty) {
      return managerToken;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token')?.trim();
    if (storedToken != null && storedToken.isNotEmpty) {
      return storedToken;
    }

    final altToken = prefs.getString('auth_token')?.trim();
    if (altToken != null && altToken.isNotEmpty) {
      return altToken;
    }

    return null;
  }

  List<Map<String, dynamic>> get _cartItemsPayload {
    return _cart.items
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
  }

  Map<String, dynamic> get _shippingPayload {
    return buildShippingPayload(
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
  }

  String _buildOrderSignature() {
    final authToken = _effectiveAuthToken ?? '';
    final payload = [
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
      authToken,
    ];
    return payload.join('|');
  }

  bool _isReadyToPrepareOrder() {
    return _cart.items.isNotEmpty &&
        widget.razorpayKeyId.trim().isNotEmpty &&
        (_effectiveAuthToken != null && _effectiveAuthToken!.isNotEmpty) &&
        _fullNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _address1Controller.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _pincodeController.text.trim().isNotEmpty &&
        _countryController.text.trim().isNotEmpty;
  }

  void _scheduleOrderPreparation() {
    _prepareDebounce?.cancel();
    _prepareDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _prepareOrderIfNeeded();
    });
  }

  Future<void> _prepareOrderIfNeeded() async {
    if (!_isReadyToPrepareOrder()) {
      if (mounted) {
        setState(() {
          _preparedOrder = null;
          _preparedOrderSignature = null;
        });
      }
      return;
    }

    final signature = _buildOrderSignature();
    if (_preparedOrder != null && _preparedOrderSignature == signature) {
      return;
    }

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    setState(() {
      _errorMessage = null;
    });

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

      if (verification.success) {
        final orderSnapshot = _cart.items
            .map(
              (item) => CartItem(
                product: item.product,
                quantity: item.quantity,
              ),
            )
            .toList();

        OrderHistoryService.instance.addOrder(
          CompletedOrder(
            orderId: response.orderId ?? response.paymentId ?? '',
            paymentId: response.paymentId ?? '',
            signature: response.signature,
            customerName: _fullNameController.text.trim(),
            items: orderSnapshot,
            subtotal: _subtotal,
            shipping: _shipping,
            total: _total,
            createdAt: DateTime.now(),
          ),
        );

        if (widget.clearCartOnSuccess) {
          _cart.clearCart();
        }

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
      _errorMessage = 'External wallet selected: ${response.walletName}.';
      _isProcessing = false;
    });
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email address is required.';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required.';
    final phoneRegex = RegExp(r'^[0-9+\-\s]{8,15}$');
    if (!phoneRegex.hasMatch(text)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  String? _pincodeValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'PIN code is required.';
    if (!RegExp(r'^[0-9]{4,10}$').hasMatch(text)) {
      return 'Enter a valid PIN code.';
    }
    return null;
  }

  Future<void> _startPayment() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _verification = null;
    });

    if (_cart.items.isEmpty) {
      setState(() {
        _errorMessage = 'Your cart is empty.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please fix the highlighted fields.';
      });
      return;
    }

    try {
      if (widget.razorpayKeyId.trim().isEmpty) {
        throw Exception(
          'Missing Razorpay key id. Pass RAZORPAY_KEY_ID with --dart-define.',
        );
      }

      final effectiveAuthToken = await _resolveAuthToken();
      if (effectiveAuthToken == null || effectiveAuthToken.isEmpty) {
        throw Exception('Not authenticated. Please log in again before paying.');
      }

      final signature = _buildOrderSignature();
      if (_preparedOrder == null || _preparedOrderSignature != signature) {
        await _prepareOrderIfNeeded();
      }

      if (_preparedOrder == null) {
        throw Exception('Payment order is still being prepared. Please try again.');
      }

      setState(() {
        _isProcessing = true;
      });

      final options = <String, dynamic>{
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
      };

      _razorpay.open(options);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
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
                        _buildHeader(),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _buildBanner(
                            color: const Color(0xFFFFE4E6),
                            textColor: const Color(0xFF9F1239),
                            borderColor: const Color(0xFFFDA4AF),
                            message: _errorMessage!,
                          ),
                        ],
                        if (_verification != null && _verification!.success) ...[
                          const SizedBox(height: 16),
                          _buildBanner(
                            color: const Color(0xFFDCFCE7),
                            textColor: const Color(0xFF166534),
                            borderColor: const Color(0xFF86EFAC),
                            message: _verification!.message,
                          ),
                        ],
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 960;
                            final children = [
                              Expanded(flex: 3, child: _buildShippingCard()),
                              const SizedBox(width: 20, height: 20),
                              Expanded(flex: 2, child: _buildSummaryCard()),
                            ];

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: children,
                              );
                            }

                            return Column(
                              children: [
                                _buildShippingCard(),
                                const SizedBox(height: 20),
                                _buildSummaryCard(),
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

  Widget _buildHeader() {
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

  Widget _buildBanner({
    required Color color,
    required Color textColor,
    required Color borderColor,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildShippingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Shipping details', 'Enter the address where we should deliver your order.'),
            const SizedBox(height: 18),
            _buildGridFields(),
            const SizedBox(height: 16),
            _buildPaymentNote(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isProcessing || _isPreparingOrder || _preparedOrder == null) ? null : _startPayment,
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
                                'Pay now • ${_money.format(_total)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final children = [
          Expanded(
            child: _inputField(
              controller: _fullNameController,
              label: 'Full name *',
              hintText: 'Aarav Sharma',
              validator: (value) => _requiredValidator(value, 'Full name'),
            ),
          ),
          const SizedBox(width: 14, height: 14),
          Expanded(
            child: _inputField(
              controller: _emailController,
              label: 'Email *',
              hintText: 'aarav@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
          ),
        ];

        final phoneAndAddress = [
          Expanded(
            child: _inputField(
              controller: _phoneController,
              label: 'Phone *',
              hintText: '+91 98765 43210',
              keyboardType: TextInputType.phone,
              validator: _phoneValidator,
            ),
          ),
          const SizedBox(width: 14, height: 14),
          Expanded(
            child: _inputField(
              controller: _pincodeController,
              label: 'PIN code *',
              hintText: '560001',
              keyboardType: TextInputType.number,
              validator: _pincodeValidator,
            ),
          ),
        ];

        final cityState = [
          Expanded(
            child: _inputField(
              controller: _cityController,
              label: 'City *',
              hintText: 'Bengaluru',
              validator: (value) => _requiredValidator(value, 'City'),
            ),
          ),
          const SizedBox(width: 14, height: 14),
          Expanded(
            child: _inputField(
              controller: _stateController,
              label: 'State *',
              hintText: 'Karnataka',
              validator: (value) => _requiredValidator(value, 'State'),
            ),
          ),
        ];

        final addressRows = [
          _inputField(
            controller: _address1Controller,
            label: 'Address line 1 *',
            hintText: 'House number, street name',
            validator: (value) => _requiredValidator(value, 'Address line 1'),
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _address2Controller,
            label: 'Address line 2',
            hintText: 'Apartment, landmark, etc.',
          ),
        ];

        final countryField = _inputField(
          controller: _countryController,
          label: 'Country *',
          hintText: 'India',
          validator: (value) => _requiredValidator(value, 'Country'),
        );

        if (isWide) {
          return Column(
            children: [
              Row(children: children),
              const SizedBox(height: 14),
              ...addressRows,
              const SizedBox(height: 14),
              Row(children: cityState),
              const SizedBox(height: 14),
              Row(children: [...phoneAndAddress]),
              const SizedBox(height: 14),
              countryField,
            ],
          );
        }

        return Column(
          children: [
            _inputField(
              controller: _fullNameController,
              label: 'Full name *',
              hintText: 'Aarav Sharma',
              validator: (value) => _requiredValidator(value, 'Full name'),
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _emailController,
              label: 'Email *',
              hintText: 'aarav@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _phoneController,
              label: 'Phone *',
              hintText: '+91 98765 43210',
              keyboardType: TextInputType.phone,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _address1Controller,
              label: 'Address line 1 *',
              hintText: 'House number, street name',
              validator: (value) => _requiredValidator(value, 'Address line 1'),
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _address2Controller,
              label: 'Address line 2',
              hintText: 'Apartment, landmark, etc.',
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _cityController,
              label: 'City *',
              hintText: 'Bengaluru',
              validator: (value) => _requiredValidator(value, 'City'),
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _stateController,
              label: 'State *',
              hintText: 'Karnataka',
              validator: (value) => _requiredValidator(value, 'State'),
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _pincodeController,
              label: 'PIN code *',
              hintText: '560001',
              keyboardType: TextInputType.number,
              validator: _pincodeValidator,
            ),
            const SizedBox(height: 14),
            _inputField(
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Order summary', 'Review the items and totals before paying.'),
          const SizedBox(height: 18),
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
                            errorBuilder: (_, _, _) => Container(
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
                              Text(
                                'Qty ${item.quantity}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
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
          _totalRow('Subtotal', _subtotal),
          _totalRow('Shipping', _shipping),
          const Divider(height: 28),
          _totalRow('Total', _total, bold: true),
          const SizedBox(height: 18),
          _supportCard(),
        ],
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
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '1. Create order on backend\n2. Open Razorpay checkout\n3. Verify payment signature\n4. Clear cart and continue',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      fontSize: bold ? 18 : 15,
      color: const Color(0xFF0F172A),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(_money.format(value), style: style),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentNote() {
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}


