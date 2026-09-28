class AppEnv {
  const AppEnv._();

  /// Public Razorpay key ID used by the client checkout flow.
  static const String razorpayKeyId = String.fromEnvironment('RAZORPAY_KEY_ID');

  /// Public backend base URL for Razorpay order creation and verification.
  static const String paymentBaseUrl = String.fromEnvironment(
    'PAYMENT_BASE_URL',
    defaultValue: 'https://aroun-shopping-website-a2he.onrender.com/api/payment',
  );
}
