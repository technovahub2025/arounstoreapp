class AppEnv {
  const AppEnv._();

  /// Public Razorpay key ID used by the client checkout flow.
  /// For production, pass `-dRAZORPAY_KEY_ID=rzp_live_...` at build time.
  /// The test key works on localhost for development.
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_5H8kXnV2mY9pQ3',
  );

  /// Public backend base URL for Razorpay order creation and verification.
  static const String paymentBaseUrl = String.fromEnvironment(
    'PAYMENT_BASE_URL',
    defaultValue: 'https://aroun-shopping-website-ysi0.onrender.com/api/payment',
  );
}
