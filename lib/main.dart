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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<AppPreferences>();
    return MaterialApp(
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

