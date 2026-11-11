import 'package:arunstore/service/categoryservice.dart';
import 'package:arunstore/theme/theme_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _legacyImageHosts = {
  'aroun-shopping-website-ysi0.onrender.com',
  'aroun-shopping-website-fekt.onrender.com',
  'arounstorebackend-fdpa.onrender.com',
  'aroun-shopping-website-5nnj.onrender.com',
};

String resolveProductImageUrl(String? value) {
  if (value == null || value.trim().isEmpty) return '';
  final source = value.trim();
  final api = Uri.parse(ProductController.apiUrl);
  final parsed = Uri.tryParse(source);
  if (parsed == null) return source;
  if (!parsed.hasScheme && parsed.path.startsWith('/api/drive-images/')) {
    return api.replace(path: parsed.path, query: parsed.hasQuery ? parsed.query : null).toString();
  }
  if (_legacyImageHosts.contains(parsed.host.toLowerCase()) &&
      parsed.path.startsWith('/api/drive-images/')) {
    return parsed.replace(scheme: api.scheme, host: api.host, port: api.hasPort ? api.port : null).toString();
  }
  return source;
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.fallbackImageUrl,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? fallbackImageUrl;

  @override
  Widget build(BuildContext context) {
    final url = resolveProductImageUrl(imageUrl);
    if (url.isEmpty) return errorWidget ?? _fallback(context);
    if (kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : (placeholder ?? _loading(context)),
        errorBuilder: (_, _, _) => _errorState(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        int? cacheDimension(double? requested, double available) {
          final logicalSize = requested != null && requested.isFinite
              ? requested
              : (available.isFinite ? available : double.nan);
          if (!logicalSize.isFinite || logicalSize <= 0) return null;
          return (logicalSize * pixelRatio).ceil().clamp(1, 1600).toInt();
        }

        return CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          maxWidthDiskCache: cacheDimension(width, constraints.maxWidth),
          maxHeightDiskCache: cacheDimension(height, constraints.maxHeight),
          httpHeaders: const {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
          },
          placeholder: (_, _) => placeholder ?? _loading(context),
          errorWidget: (_, _, _) => _errorState(context),
        );
      },
    );
  }

  Widget _errorState(BuildContext context) {
    final fallbackUrl = resolveProductImageUrl(fallbackImageUrl);
    if (fallbackUrl.isNotEmpty && fallbackUrl != resolveProductImageUrl(imageUrl)) {
      return ProductImage(
        imageUrl: fallbackUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget ?? _fallback(context),
      );
    }
    return errorWidget ?? _fallback(context);
  }

  Widget _loading(BuildContext context) => Container(
        width: width,
        height: height,
        color: context.appSurface(Colors.grey.shade100),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget _fallback(BuildContext context) => Container(
        width: width,
        height: height,
        color: context.appSurface(Colors.grey.shade100),
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, color: context.appForeground(Colors.grey.shade400)),
      );
}
