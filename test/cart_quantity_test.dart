import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cart = CartManager.instance;
  setUp(cart.clearCart);
  tearDown(cart.clearCart);

  testWidgets('quantity changes update totals and the cart used by checkout', (
    tester,
  ) async {
    final product = Product(id: 'tea', name: 'Tea', price: 10.75, images: []);
    cart.addProduct(product);
    await tester.pumpWidget(const MaterialApp(home: CartPage()));
    await tester.pumpAndSettle();
    expect(find.text('INR 10.75'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(cart.getProductQuantity(product), 2);
    expect(cart.total, 21.50);
    expect(find.text('INR 21.50'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(cart.getProductQuantity(product), 1);
    expect(find.text('INR 10.75'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(cart.items, isEmpty);
    expect(find.text('Cart is empty'), findsOneWidget);
    expect(find.text('INR 0.00'), findsNWidgets(3));
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('removing a row keeps remaining quantities and total in sync', (
    tester,
  ) async {
    final tea = Product(id: 'tea', name: 'Tea', price: 10.75, images: []);
    final rice = Product(id: 'rice', name: 'Rice', price: 20.25, images: []);
    cart.addProduct(tea);
    cart.addProduct(rice, quantity: 3);
    await tester.pumpWidget(const MaterialApp(home: CartPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(find.text('INR 60.75'), findsNWidgets(2));

    cart.increase(rice);
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('INR 81.00'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });
}
