# Push notification integration

Android receiving code is in `lib/service/push_notification_service.dart`.
Firebase is initialized in `main.dart`; registration follows login, token refresh,
and app resume, with periodic retries. The authenticated endpoint defaults to
`https://aroun-shopping-website-ysi0.onrender.com/api/push`; override with
`--dart-define=PUSH_BASE_URL=https://your-server/api/push` for staging.

The separate Node.js repository is checked out at `.work/backend` (ignored by this
Flutter repository). Its changes have not been pushed or deployed. Review
`.work/backend/backend/PUSH_SETUP.md` for Render secrets, Razorpay webhook setup,
testing, and delivery limitations. Do not add Firebase Admin credentials to this app.

Run the Android app on a device/emulator with Google Play services, allow the
notification prompt, and log in after the backend is deployed. Background messages
appear in the system tray; foreground messages and opened alerts appear as banners.
Use Razorpay test mode to verify both order confirmation and payment received.
Web, iOS, and desktop push require separate platform setup and are not enabled.
