import 'package:arunstore/adminscreen/form.dart';
import 'package:arunstore/authmanager.dart';
import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/categories/productdetail.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/screen/dashboard/categorypage.dart';
import 'package:arunstore/screen/mobile_home.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final screens = <String, Widget>{
    'home': const MobileHomeScreen(
      categoryMap: {},
      allProducts: [],
      loading: false,
    ),
    'categories': const CategoryDetailsPage(
      categoryName: 'Groceries',
      products: [],
    ),
    'product detail': ProductDetailScreen(
      product: Product(
        name: 'Green Tea',
        images: [],
        price: 10,
        stock: 4,
        category: 'Groceries',
      ),
    ),
    'cart': const CartPage(),
    'admin product form': const ProductForm(),
  };
  for (final dark in [false, true]) {
    for (final entry in screens.entries) {
      testWidgets(
        '${entry.key} renders Tamil on a phone without overflow (dark: $dark)',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          SharedPreferences.setMockInitialValues({'app_language': 'ta'});
          final prefs = AppPreferences(await SharedPreferences.getInstance());
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: prefs),
                ChangeNotifierProvider.value(value: CartManager.instance),
                ChangeNotifierProvider.value(value: AuthManager()),
              ],
              child: MaterialApp(
                theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
                locale: const Locale('ta'),
                supportedLocales: const [Locale('en'), Locale('ta')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                home: entry.value,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (dark) {
            for (final element in find.byType(Scaffold).evaluate()) {
              final color =
                  (element.widget as Scaffold).backgroundColor ??
                  Theme.of(element).scaffoldBackgroundColor;
              expect(color.computeLuminance(), lessThan(0.2));
            }
          }
          if (entry.key == 'product detail') {
            expect(find.text('Green Tea'), findsWidgets);
            expect(find.text('4 பொருட்கள் இருப்பில் உள்ளன'), findsOneWidget);
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
        },
      );
    }
  }
}
