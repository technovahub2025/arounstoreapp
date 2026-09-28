
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
  runApp(
    MultiProvider(
      providers: [
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
    return MaterialApp(
      title: 'Aroun Stores',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
