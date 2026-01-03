import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/material.dart';

class orderscreen extends StatelessWidget {
  final Product product;
  final int quantity;


  const orderscreen({
    super.key,
    required this.product,
    required this.quantity,
    
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              product.imageUrl ?? '',
              width: 145,
              height: 145,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image, size: 45),
            ),
          ),

          const SizedBox(width: 8),

          /// Name & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'Unnamed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${product.price ?? 0}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// Quantity
        
        ],
      ),
    );
  }

 
}
