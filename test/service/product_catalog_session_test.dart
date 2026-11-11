import 'dart:async';

import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/service/categoryservice.dart';
import 'package:flutter_test/flutter_test.dart';

class _PageRequest {
  _PageRequest(this.cursor, this.search, this.categories);
  final String? cursor;
  final String search;
  final List<String>? categories;
}

class _FakeProductController extends ProductController {
  final requests = <_PageRequest>[];
  final Map<String, Completer<ProductPage>> pending = {};
  final Map<String, ProductPage> pages = {};

  @override
  Future<ProductPage> fetchProductPage({
    String? cursor,
    String search = '',
    String? category,
    List<String>? categories,
    int limit = ProductController.pageSize,
    bool forceRefresh = false,
  }) {
    requests.add(_PageRequest(cursor, search, categories));
    final completer = pending[search];
    if (completer != null) return completer.future;
    return Future.value(pages['${search}_$cursor'] ?? pages[search]!);
  }
}

Product _product(String id, String category) => Product(
      id: id,
      name: id,
      images: const [],
      category: category,
      price: 1,
    );

void main() {
  group('ProductCatalogSession', () {
    test('uses query-specific cursors and suppresses duplicate products', () async {
      final controller = _FakeProductController()
        ..pages['SUNSILK_null'] = ProductPage(
          products: [_product('1', 'HAIR PRODUCTS')],
          hasMore: true,
          nextCursor: 'next-token',
        )
        ..pages['SUNSILK_next-token'] = ProductPage(
          products: [_product('1', 'HAIR PRODUCTS'), _product('2', 'HAIR PRODUCTS')],
          hasMore: false,
        );
      final session = ProductCatalogSession(controller);

      await session.loadFirst(search: 'SUNSILK', categories: const ['HAIR PRODUCTS']);
      await session.loadMore();

      expect(session.products.map((product) => product.id), ['1', '2']);
      expect(controller.requests.map((request) => request.cursor), [null, 'next-token']);
      expect(controller.requests.every((request) => request.search == 'SUNSILK'), isTrue);
      expect(controller.requests.every((request) => request.categories!.single == 'HAIR PRODUCTS'), isTrue);
    });

    test('ignores a stale query response after a newer search starts', () async {
      final controller = _FakeProductController()
        ..pending['old'] = Completer<ProductPage>()
        ..pending['new'] = Completer<ProductPage>();
      final session = ProductCatalogSession(controller);

      final oldRequest = session.loadFirst(search: 'old');
      session.invalidatePending();
      final newRequest = session.loadFirst(search: 'new');
      controller.pending['new']!.complete(ProductPage(
        products: [_product('new-id', 'HAIR PRODUCTS')],
        hasMore: false,
      ));
      await newRequest;
      controller.pending['old']!.complete(ProductPage(
        products: [_product('old-id', 'HAIR PRODUCTS')],
        hasMore: false,
      ));
      await oldRequest;

      expect(session.products.map((product) => product.id), ['new-id']);
    });
  });
}
