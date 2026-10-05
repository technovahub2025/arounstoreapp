import 'package:arunstore/l10n/app_localization.dart';


import 'package:arunstore/model/model/productmodel.dart';
import 'package:flutter/material.dart';
import '../adminservice/productapiservice.dart';
import 'form.dart';

class ProductDashboard extends StatefulWidget {
  const ProductDashboard({super.key});

  @override
  State<ProductDashboard> createState() => _ProductDashboardState();
}

class _ProductDashboardState extends State<ProductDashboard> {
  List<Product> products = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // ================= FETCH =================
  Future<void> fetchProducts() async {
    setState(() => loading = true);
    try {
      products = await ApiService.getProducts();

    
    } catch (e) {
      _showError('Failed to load products: ${e.toString()}');
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= DELETE =================
  Future<void> deleteProduct(String id) async {
    bool confirmDelete = await _showDeleteConfirmation(context);
    if (!confirmDelete) return;

    try {
      await ApiService.deleteProduct(id);
      await fetchProducts();
      _showSuccess('Product deleted successfully');
    } catch (e) {
      _showError('Failed to delete: ${e.toString()}');
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Product Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchProducts,
            tooltip: context.tr('Refresh'),
          )
        ],
      ),

      // ---------- BODY ----------
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      AppText(
                        'No products found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      AppText(
                        'Tap + to add a product',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchProducts,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final hasImages = product.images.isNotEmpty; // Changed to images
                      final imageUrl = hasImages ? product.images[0] : null; // Changed to images

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          // ---------- IMAGE ----------
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: hasImages && imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image,
                                              color: Colors.grey),
                                        );
                                      },
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.image,
                                        size: 30, color: Colors.grey),
                                  ),
                          ),

                          // ---------- TITLE ----------
                          title: Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // ---------- SUBTITLE ----------
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  AppText(
                                    '₹${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                'Stock: ${product.stock}',
                                style: TextStyle(
                                  color: product.stock > 10
                                      ? Colors.grey[600]
                                      : Colors.orange,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppText(
                                'Category: ${product.category}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // ---------- ACTIONS ----------
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: Colors.blue),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) =>
                                        ProductForm(product: product),
                                  );
                                  fetchProducts();
                                },
                                tooltip: context.tr('Edit'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                onPressed: () => deleteProduct(product.id!),
                                tooltip: context.tr('Delete'),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      );
                    },
                  ),
                ),

      // ---------- FAB ----------
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const AppText('Add Product'),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => const ProductForm(),
          );
          fetchProducts();
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  // ================= DIALOGS =================
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Confirm Delete'),
        content: const AppText('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const AppText('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const AppText(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ================= SNACKBARS =================
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
