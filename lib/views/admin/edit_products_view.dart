import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/company_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';
import 'add_edit_product_view.dart';

class EditProductsView extends StatefulWidget {
  const EditProductsView({super.key});

  @override
  State<EditProductsView> createState() => _EditProductsViewState();
}

class _EditProductsViewState extends State<EditProductsView> {
  final HomeController homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  final CompanyController companyController = Get.isRegistered<CompanyController>()
      ? Get.find<CompanyController>()
      : Get.put(CompanyController());

  final TextEditingController _searchController = TextEditingController();
  final RxString _selectedBrandFilter = 'All'.obs;
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter products based on search query & brand filter chip
  List<Product> get _filteredProducts {
    return homeController.products.where((p) {
      final matchesSearch = _searchQuery.value.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.value.toLowerCase());

      final matchesBrand = _selectedBrandFilter.value == 'All' ||
          p.category.toLowerCase() == _selectedBrandFilter.value.toLowerCase();

      return matchesSearch && matchesBrand;
    }).toList();
  }

  // Helper Image Widget for rendering both File paths & Asset paths
  Widget _buildProductImage(String path, {double width = 80, double height = 80}) {
    if (path.startsWith('/') || path.contains(':\\') || path.contains('/data/')) {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
    } else {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
    }
  }

  Color _parseColorHex(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF5B9EE1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 1. HEADER ROW ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1A2530),
                      ),
                    ),
                  ),

                  // Title
                  const ResponsiveText(
                    'Products (Shoes)',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2530),
                  ),

                  // Add Shoe Button -> Opens Full Screen AddEditProductView
                  GestureDetector(
                    onTap: () => Get.to(() => const AddEditProductView()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9EE1), // #5B9EE1 Accent
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x335B9EE1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          ResponsiveText(
                            'Add Shoe',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 2. SEARCH BAR ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _searchQuery.value = val,
                  style: const TextStyle(
                    color: Color(0xFF1A2530),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search shoes by name or category...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF707B81),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF707B81),
                    ),
                    suffixIcon: Obx(() {
                      if (_searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Color(0xFF707B81), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery.value = '';
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── 3. BRAND FILTER CHIPS ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Nike'),
                  _buildFilterChip('Puma'),
                  _buildFilterChip('Adidas'),
                  _buildFilterChip('Converse'),
                  _buildFilterChip('UA'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 4. PRODUCTS LIST ──
            Expanded(
              child: Obx(() {
                final list = _filteredProducts;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: Color(0xFF5B9EE1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ResponsiveText(
                          'No Shoe Products Found',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2530),
                        ),
                        const SizedBox(height: 6),
                        const ResponsiveText(
                          'Tap + Add Shoe button to create a new product',
                          fontSize: 14,
                          color: Color(0xFF707B81),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final product = list[index];
                    return _buildProductCard(context, product);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── BRAND FILTER CHIP WIDGET ──
  Widget _buildFilterChip(String label) {
    return Obx(() {
      final isSelected = _selectedBrandFilter.value == label;
      return GestureDetector(
        onTap: () => _selectedBrandFilter.value = label,
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A2530) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1A2530)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFF1A2530).withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF707B81),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ── PRODUCT CARD WIDGET (OVERFLOW FIXED WITH WRAP) ──
  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Box
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _buildProductImage(product.image, width: 68, height: 68),
                ),
              ),

              const SizedBox(width: 14),

              // Product Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Badge & Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5B9EE1),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            size: 15, color: Color(0xFFFFB800)),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2530),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2530),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // PRICE & BADGES WRAP (Overflow Fix for 1.2px Issue!)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2530),
                          ),
                        ),
                        if (product.isBestSeller)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Best Seller',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ),
                        if (product.isNewArrival)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'New',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Buttons (Edit -> Opens Full Screen & Delete)
              Column(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => AddEditProductView(product: product)),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF5B9EE1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context, product),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFFF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),

          // Stock & Pricing Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 14, color: Color(0xFF5B9EE1)),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${product.totalStock} Pairs',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2530),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Pur: \$${product.latestPurchasePrice.toStringAsFixed(2)}  |  Sale: \$${product.latestSalePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF707B81),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Multi-Sizes & Colors Preview Row
          Row(
            children: [
              const Text(
                'Sizes: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF707B81),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: product.sizes
                        .map(
                          (s) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Text(
                              '$s',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A2530),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Colors: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF707B81),
                ),
              ),
              Row(
                children: product.colors.map((hexStr) {
                  Color c = _parseColorHex(hexStr);
                  return Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── DELETE DIALOG ──
  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFFF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const ResponsiveText(
                'Delete Shoe Product?',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2530),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${product.name}"? It will be removed from both Admin and User views.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF707B81),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF707B81)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF707B81),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        homeController.deleteProduct(product.id);
                        Get.back();
                        Get.snackbar(
                          'Shoe Product Deleted',
                          '${product.name} was removed from catalog',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFFF4444),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
