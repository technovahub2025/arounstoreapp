import 'package:arunstore/service/categoryservice.dart';
import 'package:arunstore/widgets/product_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveProductImageUrl', () {
    const signature = 'd1657727fc83f61603b0aa0478384200e72556c31274a24a45cdb4e016e76fd9';

    test('maps legacy Drive proxy hosts and retains the signed query', () {
      final resolved = resolveProductImageUrl(
        'https://aroun-shopping-website-ysi0.onrender.com/api/drive-images/file_id?signature=$signature&v=1',
      );
      expect(resolved, '${ProductController.apiUrl.replaceFirst('/api/products', '')}/api/drive-images/file_id?signature=$signature&v=1');
    });

    test('maps relative Drive proxy paths to the configured backend origin', () {
      final resolved = resolveProductImageUrl('/api/drive-images/file_id?signature=$signature');
      expect(resolved, '${ProductController.apiUrl.replaceFirst('/api/products', '')}/api/drive-images/file_id?signature=$signature');
    });

    test('preserves signed image query strings byte for byte', () {
      const jpegSignature = 'd1657727fc83f61603b0aa0478384200e72556c31274a24a45cdb4e016e76fd9';
      const pngSignature = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final jpeg = resolveProductImageUrl(
        'https://aroun-shopping-website-fekt.onrender.com/api/drive-images/jpeg_id?signature=$jpegSignature&download=0',
      );
      final png = resolveProductImageUrl(
        '/api/drive-images/png_id?signature=$pngSignature&variant=small%2Fpreview',
      );

      expect(jpeg, contains('?signature=$jpegSignature&download=0'));
      expect(png, endsWith('?signature=$pngSignature&variant=small%2Fpreview'));
    });

    test('preserves non-legacy URLs and handles empty or invalid values', () {
      expect(resolveProductImageUrl(''), isEmpty);
      expect(resolveProductImageUrl(null), isEmpty);
      expect(resolveProductImageUrl('https://cdn.example.com/item.jpg'), 'https://cdn.example.com/item.jpg');
      expect(resolveProductImageUrl('not a url'), 'not a url');
    });
  });

  testWidgets('uses native network rendering on Web and disk caching on mobile', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SizedBox(
        width: 120,
        height: 120,
        child: ProductImage(
          imageUrl: 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=',
        ),
      ),
    ));

    if (kIsWeb) {
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    } else {
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    }
  });

  testWidgets('shows a fallback for an empty image URL', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ProductImage(imageUrl: ''),
    ));

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}
