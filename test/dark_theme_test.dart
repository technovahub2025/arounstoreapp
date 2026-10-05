import 'package:arunstore/adminscreen/login.dart' as admin;
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/allorder.dart';
import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/screen/checkout.dart';
import 'package:arunstore/screen/dashboard/wishlist.dart';
import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/screen/mobile_account.dart';
import 'package:arunstore/screen/registerscreen.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/screen/settings/settings_screen.dart';
import 'package:arunstore/screen/settings/policy_screen.dart';
import 'package:arunstore/screen/widgets/checkout_widgets.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:arunstore/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget harness(AppPreferences prefs, Widget screen) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: prefs),
    ChangeNotifierProvider.value(value: CartManager.instance),
    ChangeNotifierProvider.value(value: AuthManager()),
  ],
  child: Consumer<AppPreferences>(
    builder: (_, prefs, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: prefs.isDark ? ThemeMode.dark : ThemeMode.light,
      home: screen,
    ),
  ),
);

void main() {
  final screens = <String, Widget Function()>{
    'login': () => const LoginScreen(),
    'register': () => const RegisterScreen(),
    'admin login': () => admin.LoginScreen(),
    'checkout': () => const CheckoutScreen(),
    'orders': () => const Allorder(),
    'wishlist': () => const WishlistPage(),
    'account': () => MobileAccountScreen(onLogoutTap: () {}),
    'filters': () => const CategoryFilterPage(categories: {}),
    'settings': () => const SettingsScreen(),
    'privacy': () => const PolicyScreen(policy: StorePolicy.privacy),
    'terms': () => const PolicyScreen(policy: StorePolicy.terms),
  };
  for (final entry in screens.entries) {
    testWidgets('${entry.key} uses dark surfaces', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'dark_theme': true});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      await tester.pumpWidget(harness(prefs, entry.value()));
      await tester.pumpAndSettle();
      for (final element in find.byType(Scaffold).evaluate()) {
        final scaffold = element.widget as Scaffold;
        final color =
            scaffold.backgroundColor ??
            Theme.of(element).scaffoldBackgroundColor;
        expect(color.computeLuminance(), lessThan(0.2), reason: entry.key);
      }
      for (final element in find.byType(AppBar).evaluate()) {
        final appBar = element.widget as AppBar;
        final color =
            appBar.backgroundColor ??
            Theme.of(element).appBarTheme.backgroundColor!;
        expect(
          color.computeLuminance(),
          lessThan(0.3),
          reason: '${entry.key} app bar',
        );
      }
      for (final element in find.byType(TextField).evaluate()) {
        final field = element.widget as TextField;
        final fill = field.decoration?.fillColor;
        if (fill != null) expect(fill.computeLuminance(), lessThan(0.3));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }

  testWidgets(
    'switching themes updates an open form without losing its input',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SharedPreferences.getInstance();
      final prefs = AppPreferences(storage);
      final controller = TextEditingController(text: 'Kumar');
      await tester.pumpWidget(
        harness(
          prefs,
          Scaffold(
            body: CheckoutSectionCard(
              title: 'Shipping details',
              subtitle: 'Enter your details',
              child: CheckoutTextField(
                controller: controller,
                label: 'Full Name',
                hintText: 'Enter your full name',
              ),
            ),
          ),
        ),
      );
      final field = find.byType(TextField);
      final originalFill = tester
          .widget<TextField>(field)
          .decoration!
          .fillColor!;
      await prefs.setDark(true);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(field)
            .decoration!
            .fillColor!
            .computeLuminance(),
        lessThan(0.2),
      );
      expect(controller.text, 'Kumar');
      expect(AppPreferences(storage).isDark, isTrue);
      await prefs.setDark(false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field).decoration!.fillColor,
        originalFill,
      );
      expect(controller.text, 'Kumar');
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets('dark palette preserves contrast and light colors', (
    tester,
  ) async {
    late BuildContext palette;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) {
            palette = context;
            return const SizedBox();
          },
        ),
      ),
    );
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return ((x > y ? x : y) + 0.05) / ((x < y ? x : y) + 0.05);
    }

    for (final pair in [
      (Colors.white, AppColors.darkText),
      (AppColors.green50, AppColors.green700),
      (Colors.red.shade50, Colors.red.shade700),
    ]) {
      expect(
        contrast(palette.appSurface(pair.$1), palette.appForeground(pair.$2)),
        greaterThan(4.5),
      );
    }
    expect(palette.appForeground(Colors.white), Colors.white);
    expect(palette.appSurface(AppColors.primary), AppColors.primary);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            palette = context;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(palette.appSurface(Colors.white), Colors.white);
    expect(palette.appForeground(AppColors.darkText), AppColors.darkText);
  });
}
