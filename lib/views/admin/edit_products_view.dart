import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/company_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_animated_dropdown.dart';
import '../../widgets/app_delete_dialog.dart';
import '../../widgets/app_shimmer.dart';
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
  void initState() {
    super.initState();
    _selectedBrandFilter.value = 'All';
    homeController.fetchAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter products based on search query & brand filter chip
  List<Product> get _filteredProducts {
    return homeController.allProducts.where((p) {
      final matchesSearch = _searchQuery.value.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.value.toLowerCase());

      final matchesBrand = _selectedBrandFilter.value == 'All' ||
          p.category.toLowerCase() == _selectedBrandFilter.value.toLowerCase();

      return matchesSearch && matchesBrand;
    }).toList();
  }

  // Helper Image Widget for rendering Network URLs, File paths & Asset paths
  Widget _buildProductImage(String path, {double width = 80, double height = 80}) {
    if (path.trim().isEmpty) {
      return const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerImageLoader(
            width: width,
            height: height,
            borderRadius: 14,
          );
        },
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
    } else if (path.startsWith('/') || path.contains(':\\') || path.contains('/data/')) {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
    } else {
      return const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
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

      // ── FLOATING ADD SHOE BUTTON AT THE BOTTOM ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddEditProductView()),
        backgroundColor: const Color(0xFF5B9EE1),
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Add Shoe',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 1. HEADER ROW ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
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

                  const SizedBox(width: 16),

                  // Title
                  const Expanded(
                    child: ResponsiveText(
                      'Products (Shoes)',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2530),
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

            // ── 3. BRAND / COMPANY DROPDOWN FILTER ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Obx(() {
                final companyNames = <String>[];
                for (var c in homeController.companies) {
                  final name = c['name']?.toString() ?? '';
                  if (name.isNotEmpty && !companyNames.contains(name)) {
                    companyNames.add(name);
                  }
                }
                if (companyNames.isEmpty) {
                  for (var c in companyController.companies) {
                    if (!companyNames.contains(c.name)) {
                      companyNames.add(c.name);
                    }
                  }
                }
                final allChips = ['All', ...companyNames];

                return AppAnimatedDropdown<String>(
                  label: 'Brand / Company Filter',
                  hint: 'Filter by Brand',
                  value: _selectedBrandFilter.value,
                  items: allChips,
                  itemLabel: (brand) =>
                      brand == 'All' ? 'All Brands & Companies' : brand,
                  prefixIcon: Icons.business_rounded,
                  onChanged: (val) {
                    if (val != null) _selectedBrandFilter.value = val;
                  },
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── 4. PRODUCTS LIST ──
            Expanded(
              child: Obx(() {
                if (homeController.isLoadingAllProducts.value && homeController.allProducts.isEmpty) {
                  return const AdminProductsShimmer(count: 4);
                }

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
                  padding: EdgeInsets.only(
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    top: 8,
                    bottom: 80,
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
    AppDeleteDialog.show(
      context,
      title: 'Delete Shoe Product',
      description:
          'Are you sure you want to delete "${product.name}"? It will be permanently removed from both store and catalog.',
      confirmText: 'Delete',
      onConfirm: () async {
        try {
          final pId = int.tryParse(product.id);
          if (pId != null) {
            await Supabase.instance.client
                .from('products')
                .delete()
                .eq('prod_id', pId);
          } else {
            await Supabase.instance.client
                .from('products')
                .delete()
                .eq('id', product.id);
          }
        } catch (e) {
          debugPrint('⚠️ Supabase product deletion note: $e');
        }

        homeController.deleteProduct(product.id);
        AppToast.showSuccess(
          title: 'Shoe Product Deleted',
          message: '${product.name} was removed from catalog',
        );
      },
    );
  }
}
