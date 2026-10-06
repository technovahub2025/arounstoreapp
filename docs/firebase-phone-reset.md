# Firebase SMS password recovery

The login screen's Forgot Password link opens Firebase phone verification on
Android or web. After SMS verification, the app sends a Firebase ID token and
new password to POST /api/auth/reset-password. Node verifies the token with
Firebase Admin (including revocation), requires the phone sign-in provider and
authentication within five minutes, then chooses the account exclusively from
the signed phone_number claim. MongoDB stores a bcrypt hash, consumes that
authentication timestamp atomically, and increments sessionVersion to invalidate
existing app JWTs. Normal phone/password login remains on the Node backend.
Firebase phone authentication creates a Firebase user if needed; it does not
create a store account. Phone numbers must already match an existing store user.

## Firebase Console setup

1. Select arounstore-2b00e > Authentication > Get started > Sign-in method > Phone;
   enable and save. Real verification SMS requires the Blaze billing plan.
   For development, configure a fictional phone number and fixed six-digit code
   under Phone numbers for testing; this does not send a real SMS. Never configure
   a real customer's phone as a testing number.
2. Authentication > Settings > SMS region policy: allow India (and only other
   countries you serve). Configure billing alerts and monitor SMS usage.
3. Project settings > Your apps: choose Android com.example.arunstore (not the
   similarly named com.example.arounstore). Add these development fingerprints:

   SHA-1: 18:5B:27:C9:26:52:0F:93:D2:33:9B:F9:CD:92:FA:34:05:77:36:3D

   SHA-256: 44:2F:C9:C2:84:5D:D8:A7:3F:E6:62:BA:E9:A7:B0:70:EF:B6:67:40:1D:6F:81:39:FF:FD:E1:D7:8A:F4:78:74

   These are from this machine's debug keystore. Add your production/Play App
   Signing certificate fingerprints separately for distributed builds.
4. Download the updated google-services.json into android/app/ and fully rebuild.
5. For web, add your website domain under Authentication > Settings > Authorized
   domains. Firebase's reCAPTCHA flow verifies the SMS request.

## Backend deployment and testing

Deploy the changes in .work/backend. Render's FIREBASE_SERVICE_ACCOUNT_JSON must
contain valid replacement credentials for this Firebase project. Do not reuse the
previously exposed private key. The Firebase Admin Auth token-verification API
needs access to Firebase Authentication; no Twilio or PUSH_ENABLED is required
for this reset flow. The former /forgot-password custom-token API now returns 410.

Run `flutter test test/forgot_password_test.dart test/widget_test.dart` and
`node --test tests/*.test.js` in the backend. Use a Firebase fictional test number
that also has a store test account. Verify that the new password logs in, the old
password fails, and old app JWTs are rejected. Test wrong/expired codes, resend,
automatic Android verification, and a phone without a store account. SMS delivery
and the complete Firebase-to-backend flow require configured Firebase and a device;
unit tests alone do not prove delivery. iOS/desktop are not enabled for this flow.

References:
- https://firebase.google.com/docs/auth/flutter/phone-auth
- https://firebase.google.com/docs/auth/limits
- https://firebase.google.com/docs/auth/admin/verify-id-tokens
