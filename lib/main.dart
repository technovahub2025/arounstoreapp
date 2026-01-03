
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arunstore/authmanager.dart';


void main()  async {

    WidgetsFlutterBinding.ensureInitialized();

    final authManager = AuthManager();
  await authManager.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => CartManager.instance),
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
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF15803D),
      ),
      home: const SplashScreen(), // Start with SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}