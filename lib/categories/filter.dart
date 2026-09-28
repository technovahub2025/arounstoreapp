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
  final VoidCallback? onProfileTap;

  const CategoryFilterPage({
    Key? key,
    required this.categories,
    this.initialSelectedCategory,
    this.onProfileTap,
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

    if (mounted) {
      setState(() {});
    }
  }

  void _onCategorySelected(String category, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedCategories.contains(category)) {
          _selectedCategories.add(category);
        }
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

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Sort Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _buildSortOption(
                  title: 'Price: Low to High',
                  icon: Icons.arrow_upward_rounded,
                  sortType: PriceSortType.lowToHigh,
                ),

                _buildSortOption(
                  title: 'Price: High to Low',
                  icon: Icons.arrow_downward_rounded,
                  sortType: PriceSortType.highToLow,
                ),

                _buildSortOption(
                  title: 'Default',
                  icon: Icons.sort_rounded,
                  sortType: PriceSortType.none,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required IconData icon,
    required PriceSortType sortType,
  }) {
    final bool selected = _priceSortType == sortType;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _priceSortType = sortType;
        });

        _updateFilteredProducts();

        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.green.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.green.withOpacity(0.12)
                    : Colors.grey.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Colors.green.shade700
                      : Colors.black87,
                ),
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? Colors.green
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = widget.categories.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                size: 28,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        actions: [
          if (widget.onProfileTap != null)
            IconButton(
              tooltip: 'My Profile',
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: widget.onProfileTap,
            ),
          IconButton(
            tooltip: 'Sort',
            icon: const Icon(
              Icons.tune_rounded,
              size: 24,
            ),
            onPressed: _showSortBottomSheet,
          ),
        ],
      ),

      // ============================================================
      // LEFT SIDEBAR / DRAWER
      // ============================================================
      drawer: Drawer(
        width: 300,
        backgroundColor: Colors.white,

        child: SafeArea(
          child: Column(
            children: [
              // ======================================================
              // DRAWER HEADER
              // ======================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  10,
                  18,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEAEAEA),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: Colors.green.shade700,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // SELECT ALL / CLEAR ALL
              // ======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _selectAllCategories();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(
                            color: Colors.green.shade600,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Select All',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _clearAllCategories();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // SELECTED COUNT
              // ======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${_selectedCategories.length}/${categoryNames.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // DYNAMIC CATEGORY LIST
              // ======================================================
              Expanded(
                child: categoryNames.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No categories available',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          4,
                          10,
                          20,
                        ),
                        itemCount: categoryNames.length,
                        itemBuilder: (context, index) {
                          final category = categoryNames[index];

                          final bool isSelected =
                              _selectedCategories.contains(category);

                          final int productCount =
                              widget.categories[category]?.length ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(12),
                                onTap: () {
                                  _onCategorySelected(
                                    category,
                                    !isSelected,
                                  );

                                  // Close drawer after selection.
                                  Navigator.pop(context);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 180,
                                  ),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green.withOpacity(0.09)
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      // ==================================================
                                      // SELECTED INDICATOR
                                      // ==================================================
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        width: 4,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green.shade600
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // ==================================================
                                      // CATEGORY ICON
                                      // ==================================================
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green
                                                  .withOpacity(0.10)
                                              : Colors.grey
                                                  .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons
                                              .shopping_basket_outlined,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.green.shade700
                                              : Colors.grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // ==================================================
                                      // CATEGORY NAME
                                      // ==================================================
                                      Expanded(
                                        child: Text(
                                          category,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.green.shade700
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // ==================================================
                                      // PRODUCT COUNT
                                      // ==================================================
                                      Container(
                                        constraints:
                                            const BoxConstraints(
                                          minWidth: 28,
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green
                                                  .withOpacity(0.10)
                                              : Colors.grey
                                                  .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$productCount',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: isSelected
                                                ? Colors.green.shade700
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 6),

                                      // ==================================================
                                      // CHECK ICON
                                      // ==================================================
                                      Icon(
                                        isSelected
                                            ? Icons
                                                .check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked,
                                        size: 20,
                                        color: isSelected
                                            ? Colors.green.shade600
                                            : Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // MAIN PRODUCT AREA
      // ============================================================
      body: Column(
        children: [
          // ==========================================================
          // PRODUCT SUMMARY BAR
          // ==========================================================
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${_filteredProducts.length} products found',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ====================================================
                // CURRENT SORT
                // ====================================================
                GestureDetector(
                  onTap: _showSortBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 17,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _getSortLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // PRODUCT LIST / EMPTY STATE
          // ==========================================================
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_priceSortType) {
      case PriceSortType.lowToHigh:
        return 'Low to High';

      case PriceSortType.highToLow:
        return 'High to Low';

      case PriceSortType.none:
        return 'Default';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No products found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Try selecting different categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _selectAllCategories,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text(
                'Show All Products',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(
                  color: Colors.green.shade600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _viewProductDetails(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // PRODUCT IMAGE
            // ========================================================
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF7F7F7),
                child: product.images.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.network(
                          product.images.first,
                          width: double.infinity,
                          height: double.infinity,

                          // IMPORTANT:
                          // Contain prevents the product image from
                          // being unnecessarily cropped.
                          fit: BoxFit.contain,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },

                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return Center(
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
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
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 42,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),

            // ========================================================
            // PRODUCT INFORMATION
            // ========================================================
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name ?? 'Unnamed Product',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const Spacer(),

                    // Category
                    if (product.category != null &&
                        product.category!.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 4),
                        child: Text(
                          product.category!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                    // Price
                    Text(
                      rupeeFormat.format(product.price ?? 0),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
