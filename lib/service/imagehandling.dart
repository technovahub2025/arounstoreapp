import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's an AVIF image
    final isAvif = imageUrl.toLowerCase().endsWith('.avif');
    
    if (kIsWeb && isAvif) {
      // For AVIF images on web, use HTML image element workaround
      return _buildAvifFallback(context);
    }
    
    // For normal images, use Image.network
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        // Try to load with a different format
        if (isAvif) {
          final jpgUrl = imageUrl.replaceAll('.avif', '.jpg');
          return Image.network(
            jpgUrl,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) {
              return errorWidget ?? _buildDefaultErrorWidget();
            },
          );
        }
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  Widget _buildAvifFallback(BuildContext context) {
    // Create an HTML image element workaround for web
    return HtmlElementView(
      viewType: 'avif-image-$imageUrl',
      onPlatformViewCreated: (id) {
        // This would require custom JavaScript to create an img element
        // For now, use a network image with error handling
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }
}