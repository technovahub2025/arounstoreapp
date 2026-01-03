import 'package:flutter/material.dart';
import 'package:arunstore/model/categoriesmodel.dart';

class Cartscreen extends StatefulWidget {
  final Product product;
  final int initialQuantity;
  final VoidCallback onRemove;
  final Function(double delta) onQuantityChanged;

  const Cartscreen({
    super.key,
    required this.product,
    required this.initialQuantity,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  State<Cartscreen> createState() => _CartscreenState();
}

class _CartscreenState extends State<Cartscreen> {
  late int localQuantity;

  @override
  void initState() {
    super.initState();
    localQuantity = widget.initialQuantity;
  }

  void increase() {
    setState(() {
      localQuantity++;
    });
    widget.onQuantityChanged(widget.product.price ?? 0.0);
  }

  void decrease() {
    if (localQuantity <= 0) return;
    setState(() {
      localQuantity--;
    });
    widget.onQuantityChanged(-(widget.product.price ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              widget.product.imageUrl ?? '',
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
                Text(
                  widget.product.name ?? 'Unnamed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${(widget.product.price ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyButton(Icons.remove, decrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(localQuantity.toString(), style: const TextStyle(fontSize: 14)),
              ),
              _qtyButton(Icons.add, increase),
              const SizedBox(width: 9),
              _qtyButton(Icons.delete, widget.onRemove),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, size: 12),
      ),
    );
  }
}
