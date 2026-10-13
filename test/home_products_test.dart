import 'package:arunstore/categories/filter.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/screen/mobile_home.dart';
import 'package:arunstore/screen/settings/app_preferences.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:arunstore/widgets/home_product_sections.dart';
import 'package:arunstore/widgets/product_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final groceries = List.generate(
    6,
    (index) => Product(
      id: 'grocery-$index',
      name: 'Rice $index',
      category: 'Groceries',
      description: 'Daily essentials',
      images: [],
      price: 20,
      stock: 10,
    ),
  );
  final fruit = Product(
    id: 'fruit',
    name: 'Apple',
    category: 'Fruit',
    images: [],
    price: 30,
  );
  final categories = {
    'Groceries': groceries,
    'Fruit': [fruit],
  };
  final products = [...groceries, fruit];

  Future<void> mount(WidgetTester tester, Widget home, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: prefs),
          ChangeNotifierProvider.value(value: CartManager.instance),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('category previews open the full selected category', (
    tester,
  ) async {
    await mount(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: HomeProductSections(
            categories: categories,
            allProducts: products,
          ),
        ),
      ),
      const Size(1280, 1000),
    );
    final previews = tester
        .widgetList<ProductCarousel>(find.byType(ProductCarousel))
        .toList();
    expect(previews.map((preview) => preview.products.length), [4, 1]);
    expect(find.text('View All'), findsNWidgets(2));
    await tester.tap(find.text('View All').first);
    await tester.pumpAndSettle();
    final page = tester.widget<CategoryFilterPage>(
      find.byType(CategoryFilterPage),
    );
    expect(page.initialSelectedCategory, 'Groceries');
    expect(page.categories['Groceries'], hasLength(6));
    expect(find.text('Rice 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home searches live and clearing restores category previews', (
    tester,
  ) async {
    await mount(
      tester,
      MobileHomeScreen(
        categoryMap: categories,
        allProducts: products,
        loading: false,
      ),
      const Size(390, 844),
    );

    await tester.enterText(find.byType(TextField), '  RICE 5  ');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ProductCarousel>(find.byType(ProductCarousel))
          .products
          .single,
      groceries.last,
    );
    await tester.enterText(find.byType(TextField), 'ESSENTIALS');
    await tester.pumpAndSettle();
    expect(
      tester.widget<ProductCarousel>(find.byType(ProductCarousel)).products,
      hasLength(6),
    );
    await tester.enterText(find.byType(TextField), 'fruit');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ProductCarousel>(find.byType(ProductCarousel))
          .products
          .single,
      fruit,
    );
    await tester.enterText(find.byType(TextField), 'missing product');
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('View All'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
