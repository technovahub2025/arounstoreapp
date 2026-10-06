class AppEnv {
  static const pushBaseUrl = String.fromEnvironment(
    'PUSH_BASE_URL',
    defaultValue: 'https://aroun-shopping-website-ysi0.onrender.com/api/push',
  );
  const AppEnv._();

  /// Public Razorpay key ID used by the client checkout flow.
  /// It must belong to the same Razorpay account as the backend key secret.
  /// Pass `-dRAZORPAY_KEY_ID=rzp_test_...` or `rzp_live_...` at build time.
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_live_TGQ0tqCuQsVTlk',
  );

  /// Public backend base URL for Razorpay order creation and verification.
  static const String paymentBaseUrl = String.fromEnvironment(
    'PAYMENT_BASE_URL',
    defaultValue:
        'https://aroun-shopping-website-ysi0.onrender.com/api/payment',
  );
}
