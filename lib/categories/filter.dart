import 'package:arunstore/categories/productdetail.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PriceSortType {
  none,
  lowToHigh,
  highToLow,
}

class CategoryFilterPage extends StatefulWidget {
  final Map<String, List<Product>> categories;
  final String? initialSelectedCategory;

  const CategoryFilterPage({
    Key? key,
    required this.categories,
    this.initialSelectedCategory,
  }) : super(key: key);

  @override
  _CategoryFilterPageState createState() => _CategoryFilterPageState();
}

class _CategoryFilterPageState extends State<CategoryFilterPage> {
  List<String> _selectedCategories = [];
  List<Product> _filteredProducts = [];

  PriceSortType _priceSortType = PriceSortType.none;

  final rupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();

    final categoryNames = widget.categories.keys.toList();

    if (widget.initialSelectedCategory != null &&
        categoryNames.contains(widget.initialSelectedCategory)) {
      _selectedCategories = [widget.initialSelectedCategory!];
    } else {
      _selectedCategories = categoryNames;
    }

    _updateFilteredProducts();
  }

 
  void _updateFilteredProducts() {
    _filteredProducts = [];

    for (var category in _selectedCategories) {
      final products = widget.categories[category] ?? [];
      _filteredProducts.addAll(products);
    }

    if (_priceSortType == PriceSortType.lowToHigh) {
      _filteredProducts.sort(
        (a, b) => (a.price ?? 0).compareTo(b.price ?? 0),
      );
    } else if (_priceSortType == PriceSortType.highToLow) {
      _filteredProducts.sort(
        (a, b) => (b.price ?? 0).compareTo(a.price ?? 0),
      );
    }

    setState(() {});
  }

  void _onCategorySelected(String category, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
    });
    _updateFilteredProducts();
  }

  void _selectAllCategories() {
    setState(() {
      _selectedCategories = widget.categories.keys.toList();
    });
    _updateFilteredProducts();
  }

  void _clearAllCategories() {
    setState(() {
      _selectedCategories.clear();
    });
    _updateFilteredProducts();
  }

  void _viewProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = widget.categories.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Products'),
      ),
      body: CustomScrollView(
        slivers: [
          
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter by Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categoryNames.map((category) {
                            final isSelected =
                                _selectedCategories.contains(category);
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                _onCategorySelected(category, selected);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _selectAllCategories,
                              child: const Text('Select All'),
                            ),
                            TextButton(
                              onPressed: _clearAllCategories,
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                 
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sort by Price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Low to High'),
                              selected: _priceSortType == PriceSortType.lowToHigh,
                              onSelected: (selected) {
                                setState(() {
                                  _priceSortType = selected
                                      ? PriceSortType.lowToHigh
                                      : PriceSortType.none;
                                });
                                _updateFilteredProducts();
                              },
                            ),
                            ChoiceChip(
                              label: const Text('High to Low'),
                              selected: _priceSortType == PriceSortType.highToLow,
                              onSelected: (selected) {
                                setState(() {
                                  _priceSortType = selected
                                      ? PriceSortType.highToLow
                                      : PriceSortType.none;
                                });
                                _updateFilteredProducts();
                              },
                            ),
                            ChoiceChip(
                              label: const Text('None'),
                              selected: _priceSortType == PriceSortType.none,
                              onSelected: (selected) {
                                setState(() {
                                  _priceSortType = PriceSortType.none;
                                });
                                _updateFilteredProducts();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  
                  if (_filteredProducts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '${_filteredProducts.length} products found',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

         
          if (_filteredProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try selecting different categories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 768 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                  childCount: _filteredProducts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: product.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, size: 40),
                          );
                        },
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
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Unnamed Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rupeeFormat.format(product.price ?? 0),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (product.category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        product.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
}