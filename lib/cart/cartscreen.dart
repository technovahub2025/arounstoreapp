import 'package:arunstore/theme/theme_colors.dart';
import 'package:arunstore/l10n/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:arunstore/model/categoriesmodel.dart';

class Cartscreen extends StatelessWidget {
  final Product product;
  final int initialQuantity;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const Cartscreen({
    super.key,
    required this.product,
    required this.initialQuantity,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  void increase() {
    onQuantityChanged(initialQuantity + 1);
  }

  void decrease() {
    if (initialQuantity <= 0) return;
    onQuantityChanged(initialQuantity - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.appSurface(Colors.white),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              product.imageUrl ?? '',
              width: 45,
              height: 45,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 45),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDataText(
                  product.name,
                  fallback: 'Unnamed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                AppText(
                  '₹${(product.price ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appForeground(Colors.red),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyButton(context, Icons.remove, decrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppText(
                  initialQuantity.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              _qtyButton(context, Icons.add, increase),
              const SizedBox(width: 9),
              _qtyButton(context, Icons.delete, onRemove),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: context.appBorder(Colors.black)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12),
      ),
    );
  }
}
