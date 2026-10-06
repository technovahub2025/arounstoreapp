import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_env.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundPush(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Android displays the notification payload. Never mark an order paid here:
  // payment and order state must come from the authenticated backend.
}

/// Android receiver with authenticated backend device registration.
class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();
  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Current installation token, also available for Firebase Console test sends.
  /// Do not use a shared topic for private customer/order notifications.
  final token = ValueNotifier<String?>(null);
  bool _started = false;
  StreamSubscription<RemoteMessage>? _foreground;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<String>? _refresh;
  String? _authToken;
  String? _registeredToken;
  String? _registeredAuth;
  Future<void> _pending = Future<void>.value();
  Timer? _retry;
  bool _loggingOut = false;

  Future<void> _request(String method, String deviceToken, String auth) async {
    final client = http.Client();
    try {
      final request =
          http.Request(method, Uri.parse('${AppEnv.pushBaseUrl}/devices'))
            ..headers.addAll({
              'Authorization': 'Bearer $auth',
              'Content-Type': 'application/json',
            })
            ..body = jsonEncode({'token': deviceToken});
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 10));
      await response.stream.drain<void>().timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Device registration returned ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<void> syncSession(String? auth) {
    _authToken = auth;
    _pending = _pending
        .then((_) async {
          final currentAuth = _authToken;
          final currentToken = token.value;
          if (currentAuth == null || currentToken == null) return;
          if (currentAuth == _registeredAuth &&
              currentToken == _registeredToken) {
            return;
          }
          await _request('POST', currentToken, currentAuth);
          if (_registeredToken != null &&
              _registeredToken != currentToken &&
              _registeredAuth != null) {
            await _request('DELETE', _registeredToken!, _registeredAuth!);
          }
          _registeredAuth = currentAuth;
          _registeredToken = currentToken;
        })
        .catchError((Object error) {
          debugPrint('Push registration will retry: $error');
        });
    return _pending;
  }

  /// Called before clearing login credentials; also invalidates the FCM token.
  Future<void> unregister(String? auth) async {
    if (!isSupported || Firebase.apps.isEmpty) return;
    _loggingOut = true;
    _authToken = null;
    await _pending;
    try {
      if (auth != null && token.value != null) {
        await _request('DELETE', token.value!, auth);
      }
    } catch (error) {
      debugPrint('Push unregister failed: $error');
    }
    try {
      await FirebaseMessaging.instance.deleteToken().timeout(
        const Duration(seconds: 10),
      );
    } catch (error) {
      debugPrint('Push token invalidation failed: $error');
    }
    token.value = null;
    _registeredAuth = null;
    _registeredToken = null;
    _loggingOut = false;
  }

  Future<void> refreshSession(String? auth) async {
    if (!isSupported || !_started || _loggingOut) return;
    _authToken = auth;
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final value = await FirebaseMessaging.instance.getToken();
        if (_started) token.value = value;
      }
      await syncSession(_authToken);
    } catch (error) {
      debugPrint('Push token unavailable: $error');
    }
  }

  Future<void> start(void Function(RemoteMessage) onNotification) async {
    if (!isSupported || _started || Firebase.apps.isEmpty) return;
    _started = true;
    final messaging = FirebaseMessaging.instance;
    _foreground = FirebaseMessaging.onMessage.listen(onNotification);
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(onNotification);
    _refresh = messaging.onTokenRefresh.listen(
      (value) {
        if (_loggingOut) return;
        token.value = value;
        unawaited(syncSession(_authToken));
      },
      onError: (Object error) =>
          debugPrint('Push token refresh failed: $error'),
    );
    _retry = Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(refreshSession(_authToken));
    });

    try {
      final initialMessage = await messaging.getInitialMessage();
      if (!_started) return;
      if (initialMessage != null) onNotification(initialMessage);
      final permission = await messaging.requestPermission();
      if (!_started) return;
      if (permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional) {
        final value = await messaging.getToken();
        if (_started) token.value = value;
      }
    } catch (error) {
      // Notification/network failures must not prevent shopping or checkout.
      debugPrint('Push notification setup failed: $error');
    }
  }

  Future<void> stop() async {
    _started = false;
    _retry?.cancel();
    await _foreground?.cancel();
    await _opened?.cancel();
    await _refresh?.cancel();
    token.value = null;
  }
}
