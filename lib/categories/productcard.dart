import 'package:arunstore/cart/cartservice.dart';
import 'package:arunstore/model/cartmanager.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final int? quantity;
  
  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
    this.quantity = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rupeeFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    
    final cartManager = Provider.of<CartManager>(context, listen: true);
    final quantityInCart = cartManager.getProductQuantity(product);
    final isInCart = cartManager.isProductInCart(product);

    void _addToCart() {
      
      if (product.stock != null && product.stock! > 0) {
      
        if (isInCart) {
         
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} is already in cart'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View Cart',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
            ),
          );
        } else {
          // Add the product to cart with the specified quantity
          cartManager.addProductWithQuantity(product, quantity ?? 1);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${product.name} to cart'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () {
                  cartManager.remove(product);
                },
              ),
            ),
          );
        }
        
        // Call the external callback if provided
        if (onAddToCart != null) {
          onAddToCart!();
        }
      } else {
        // Show out of stock message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product is out of stock'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    void _showImagePreview() {
      print('Image preview triggered'); // Debug print
      
      if (product.images.isEmpty) {
        print('No images available'); // Debug print
        return;
      }
      
      // First, check if the image URL is valid
      print('Image URL: ${product.images[0]}'); // Debug print
      
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black87,
                    child: Stack(
                      children: [
                        // Center the image
                        Center(
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.network(
                              product.images[0],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  print('Image loaded successfully'); // Debug print
                                  return child;
                                }
                                print('Image loading: ${loadingProgress.cumulativeBytesLoaded} / ${loadingProgress.expectedTotalBytes}'); // Debug print
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Image error: $error'); // Debug print
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Close button at top right
                        Positioned(
                          top: 40,
                          right: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ).then((value) {
        print('Image preview closed'); // Debug print
      });
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Cart Badge - Make ONLY the image tappable
            Stack(
              children: [
                // Image with preview on tap
                GestureDetector(
                  onTap: () {
                    print('Image tapped for preview'); // Debug print
                    _showImagePreview();
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: _buildProductImage(),
                      ),
                    ),
                  ),
                ),
                
                // Out of Stock Overlay
                if (product.stock == null || product.stock! <= 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Cart Quantity Badge
                if (quantityInCart > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        quantityInCart.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Add a small preview hint icon
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category ?? 'Uncategorized',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price and Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        rupeeFormat.format(product.price ?? 0),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      
                      // Rating
                      if (product.rating != null && product.rating! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (product.stock != null && product.stock! > 0)
                          ? _addToCart
                          : null,
                      icon: Icon(
                        isInCart ? Icons.shopping_cart_checkout : Icons.add_shopping_cart,
                        size: 20,
                      ),
                      label: Text(
                        isInCart ? 'In Cart ($quantityInCart)' : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart 
                            ? Colors.blue[50] 
                            : Theme.of(context).primaryColor,
                        foregroundColor: isInCart 
                            ? Theme.of(context).primaryColor 
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isInCart 
                                ? Theme.of(context).primaryColor 
                                : Colors.transparent,
                            width: isInCart ? 1 : 0,
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.images.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
    
    return Image.network(
      product.images[0],
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
              SizedBox(height: 4),
              Text(
                'Image failed to load',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}