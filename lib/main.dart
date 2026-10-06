import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:arunstore/firebase_options.dart';
import 'package:arunstore/service/push_notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/splash.dart';
import 'package:arunstore/service/order_history_service.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arunstore/authmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PushNotificationService.isSupported) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(handleBackgroundPush);
  }

  final authManager = AuthManager();
  await authManager.initialize();
  final preferences = AppPreferences(await SharedPreferences.getInstance());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: preferences),
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => CartManager.instance),
        ChangeNotifierProvider.value(value: OrderHistoryService.instance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthManager().addListener(_syncPushSession);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await PushNotificationService.instance.start(_showNotification);
      if (mounted) _syncPushSession();
    });
  }

  void _syncPushSession() {
    unawaited(
      PushNotificationService.instance.refreshSession(AuthManager().token),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _syncPushSession();
  }

  void _showNotification(RemoteMessage message) {
    if (!mounted) return;
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    final text = [
      title,
      body,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join('\n');
    if (text.isEmpty) return;
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 8)),
    );
  }

  @override
  void dispose() {
    AuthManager().removeListener(_syncPushSession);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(PushNotificationService.instance.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppPreferences>();
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      title: preferences.text('Aroun Stores', 'அருண் ஸ்டோர்ஸ்'),
      locale: Locale(preferences.isTamil ? 'ta' : 'en'),
      supportedLocales: const [Locale('en'), Locale('ta')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferences.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
