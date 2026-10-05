import 'package:arunstore/l10n/app_localization.dart';
import 'package:arunstore/categories/productdetail.dart';
import 'package:arunstore/model/categoriesmodel.dart';
import 'package:arunstore/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryDetailsPage extends StatefulWidget {
  final String categoryName;
  final List<Product> products;
  final Map<String, List<Product>>? allCategories;

  const CategoryDetailsPage({
    super.key,
    required this.categoryName,
    required this.products,
    this.allCategories,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  late List<Product> _selectedProducts;
  late List<Product> _filteredProducts;
  late Map<String, List<Product>> _categories;
  final rupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryName;
    _selectedProducts = widget.products;

    if (widget.allCategories != null && widget.allCategories!.isNotEmpty) {
      _categories = widget.allCategories!;
    } else {
      _categories = {widget.categoryName: widget.products};
    }

    _filteredProducts = _selectedProducts;
  }

  void _filterProducts(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredProducts = _selectedProducts.where((product) {
        final name = product.name?.toLowerCase() ?? '';
        final description = product.description?.toLowerCase() ?? '';
        final category = product.category?.toLowerCase() ?? '';
        return name.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            category.contains(lowerQuery);
      }).toList();
    });
  }

  void _selectCategory(String categoryName, List<Product> products) {
    setState(() {
      _selectedCategory = categoryName;
      _selectedProducts = products;
      _filteredProducts = products;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  _buildCategorySidebar(),
                  Expanded(
                    child: _buildProductArea(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              'Shop by Category',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.grey500),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CategoryProductSearchDelegate(
                  products: _categories.values.expand((p) => p).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    final categoryNames = _categories.keys.toList();
    final screenWidth = AppTheme.screenWidth(context);
    final sidebarWidth = (screenWidth * 0.28).clamp(140.0, 200.0);

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppText(
              'Categories',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.grey600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categoryNames.length,
              itemBuilder: (context, index) {
                final categoryName = categoryNames[index];
                final products = _categories[categoryName] ?? [];
                final isSelected = _selectedCategory == categoryName;

                return _buildCategoryItem(
                  categoryName: categoryName,
                  productCount: products.length,
                  isSelected: isSelected,
                  onTap: () {
                    _selectCategory(categoryName, products);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String categoryName,
    required int productCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final products = _categories[categoryName] ?? [];
    String? imageUrl;
    if (products.isNotEmpty && products[0].images.isNotEmpty) {
      imageUrl = products[0].images[0];
    }

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? AppColors.green50 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: 36,
                          height: 36,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.category,
                              size: 20,
                              color: AppColors.grey400,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.category,
                            size: 20,
                            color: AppColors.grey400,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.darkText,
                      ),
                    ),
                    AppText(
                      '$productCount items',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? AppColors.primary : AppColors.grey600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: AppColors.grey500,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.grey500,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        color: AppColors.grey400,
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
              ).localized(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AppText(
            '${_filteredProducts.length} products found',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
            ),
          ),
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final screenWidth = AppTheme.screenWidth(context);
    final crossAxisCount = screenWidth < 700 ? 2 : (screenWidth < 1024 ? 3 : 4);
    final sidebarWidth = (AppTheme.screenWidth(context) * 0.28).clamp(140.0, 200.0);
    final availableWidth = screenWidth - sidebarWidth - 32;
    final columnWidth = (availableWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
    final aspectRatio = (columnWidth / 280).clamp(0.55, 0.85);

    if (_selectedProducts.isEmpty) {
      return _buildEmptyCategory();
    }

    if (_filteredProducts.isEmpty) {
      return _buildNoSearchResults();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final discount = product.discountPercent;
    final originalPrice = product.originalPrice;
    final hasDiscount = discount != null && discount > 0;

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                    ),
                    child: _buildProductImage(product),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDataText(
                    product.name, fallback: 'Unnamed Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText(
                        rupeeFormat.format(product.price ?? 0),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (hasDiscount && originalPrice != null)
                        AppText(
                          rupeeFormat.format(originalPrice),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey500,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.grey400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.category != null)
                    AppText(
                      product.category!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.images.isEmpty) {
      return const Center(
        child: Icon(
          Icons.shopping_bag,
          size: 40,
          color: AppColors.grey400,
        ),
      );
    }

    return Image.network(
      product.images[0],
      fit: BoxFit.contain,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) {
        return const Center(
          child: Icon(
            Icons.broken_image,
            size: 40,
            color: AppColors.grey400,
          ),
        );
      },
    );
  }

  Widget _buildEmptyCategory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 20),
            const AppText(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              'There are no products in $_selectedCategory',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            const AppText(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterProducts('');
              },
              child: const AppText(
                'Clear search',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  CategoryProductSearchDelegate({required this.products});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showResults(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final lowerQuery = query.toLowerCase();
    final results = products.where((product) {
      final name = product.name?.toLowerCase() ?? '';
      final description = product.description?.toLowerCase() ?? '';
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();

    if (query.isEmpty) {
      return Center(
        child: AppText(
          'Search for products',
          style: TextStyle(color: AppColors.grey600),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16),
            AppText('No products found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images[0],
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: AppColors.grey400,
                      ),
                    ),
                  )
                : const Icon(Icons.shopping_bag, color: AppColors.grey400),
          ),
          title: AppDataText(
            product.name, fallback: 'Unnamed Product',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: AppText(
              '₹${product.price?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(color: AppColors.primary),
          ),
          onTap: () {
            close(context, product);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
