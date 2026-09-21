import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import 'web_auth_modal.dart';
import 'web_brand_bar.dart';
import 'web_cart_drawer.dart';
import 'web_checkout_modal.dart';
import 'web_colors.dart';
import 'web_header.dart';
import 'web_hero_carousel.dart';
import 'web_product_card.dart';
import 'web_product_detail_modal.dart';

class WebShoeApp extends StatefulWidget {
  const WebShoeApp({super.key});

  @override
  State<WebShoeApp> createState() => _WebShoeAppState();
}

class _WebShoeAppState extends State<WebShoeApp> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _activeSection = 'all'; // 'all' | 'new' | 'best' | 'deals'

  Product? _activeDetailProduct;
  bool _isCartOpen = false;
  bool _isCheckoutOpen = false;
  bool _isAuthOpen = false;
  bool _isFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCatalog() {
    _scrollController.animateTo(
      480,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  List<Product> _getFilteredProducts(HomeController homeCtrl) {
    List<Product> list;

    // 1. Base list according to active section & company filter
    if (_activeSection == 'new') {
      list = homeCtrl.newArrivalProducts.isNotEmpty
          ? homeCtrl.newArrivalProducts
          : homeCtrl.allProducts.where((p) => p.isNewArrival).toList();
    } else if (_activeSection == 'best') {
      list = homeCtrl.allProducts.where((p) => p.isBestSeller).toList();
    } else if (_activeSection == 'deals') {
      list = homeCtrl.discountProducts.isNotEmpty
          ? homeCtrl.discountProducts
          : homeCtrl.allProducts.where((p) => p.hasDiscount).toList();
    } else {
      // 'all' section
      if (homeCtrl.selectedCompanyId.value != null &&
          homeCtrl.selectedCompanyId.value != 'all') {
        list = homeCtrl.brandProducts;
      } else {
        list = homeCtrl.allProducts;
      }
    }

    // 2. Favorites filter if active
    if (_isFavoritesOnly) {
      list = list.where((p) => p.isFavorite.value).toList();
    }

    // 3. Live search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;

    // Responsive columns calculation
    int gridCrossAxisCount;
    if (size.width >= 1300) {
      gridCrossAxisCount = 4;
    } else if (size.width >= 960) {
      gridCrossAxisCount = 3;
    } else if (size.width >= 620) {
      gridCrossAxisCount = 2;
    } else {
      gridCrossAxisCount = 1;
    }

    return Scaffold(
      backgroundColor: WebColors.bg,
      body: Stack(
        children: [
          // ── Main Page Scroll Area ─────────────────────────────────
          Column(
            children: [
              // Sticky Glassmorphic Header
              WebHeader(
                searchController: _searchController,
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                activeSection: _activeSection,
                onSectionSelected: (section) {
                  setState(() {
                    _activeSection = section;
                    _isFavoritesOnly = false;
                  });
                  _scrollToCatalog();
                },
                onCartTap: () => setState(() => _isCartOpen = true),
                onAuthTap: () => setState(() => _isAuthOpen = true),
                onAdminTap: () => Get.toNamed('/AdminDashboardView'),
                onFavoritesTap: () {
                  setState(() {
                    _isFavoritesOnly = !_isFavoritesOnly;
                  });
                  _scrollToCatalog();
                },
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Carousel (Only shown when not searching)
                      if (_searchQuery.isEmpty && !_isFavoritesOnly) ...[
                        WebHeroCarousel(
                          onProductTap: (prod) {
                            setState(() => _activeDetailProduct = prod);
                          },
                          onShopNowTap: _scrollToCatalog,
                        ),
                      ],

                      // Brand Selection Bar (Nike, Adidas, etc.)
                      if (!_isFavoritesOnly) ...[
                        WebBrandBar(
                          onBrandSelected: (id, name) {
                            setState(() {
                              _activeSection = 'all';
                            });
                          },
                        ),
                      ],

                      // ── Section Title & Filter Summary ──────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isFavoritesOnly
                                      ? 'WISHLIST & FAVORITES'
                                      : (_searchQuery.isNotEmpty
                                          ? 'SEARCH RESULTS FOR "$_searchQuery"'
                                          : _getSectionTitle(homeCtrl)),
                                  style: const TextStyle(
                                    color: WebColors.textMain,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(() {
                                  final count = _getFilteredProducts(homeCtrl).length;
                                  return Text(
                                    '$count Sneaker${count == 1 ? '' : 's'} available in vault',
                                    style: const TextStyle(
                                      color: WebColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  );
                                }),
                              ],
                            ),

                            if (_isFavoritesOnly)
                              TextButton.icon(
                                onPressed: () => setState(() => _isFavoritesOnly = false),
                                icon: const Icon(CupertinoIcons.clear, size: 14),
                                label: const Text('Clear Wishlist Filter'),
                                style: TextButton.styleFrom(
                                  foregroundColor: WebColors.gold,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Product Grid ────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Obx(() {
                          final products = _getFilteredProducts(homeCtrl);

                          if (products.isEmpty) {
                            return _buildEmptyState();
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCrossAxisCount,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 24,
                              mainAxisExtent: 380,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return WebProductCard(
                                product: product,
                                onTap: () {
                                  setState(() => _activeDetailProduct = product);
                                },
                              );
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 60),

                      // ── Footer ──────────────────────────────────────────
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Backdrop Overlay when any modal is open ───────────────
          if (_activeDetailProduct != null ||
              _isCartOpen ||
              _isCheckoutOpen ||
              _isAuthOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeDetailProduct = null;
                    _isCartOpen = false;
                    _isCheckoutOpen = false;
                    _isAuthOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
            ),

          // ── Product Detail Modal ──────────────────────────────────
          if (_activeDetailProduct != null)
            WebProductDetailModal(
              product: _activeDetailProduct!,
              onClose: () => setState(() => _activeDetailProduct = null),
              onBuyNow: () {
                setState(() {
                  _activeDetailProduct = null;
                  _isCheckoutOpen = true;
                });
              },
            ),

          // ── Slide-Over Cart Drawer ────────────────────────────────
          if (_isCartOpen)
            WebCartDrawer(
              onClose: () => setState(() => _isCartOpen = false),
              onCheckout: () {
                setState(() {
                  _isCartOpen = false;
                  _isCheckoutOpen = true;
                });
              },
            ),

          // ── Checkout Modal ────────────────────────────────────────
          if (_isCheckoutOpen)
            WebCheckoutModal(
              onClose: () => setState(() => _isCheckoutOpen = false),
              onOrderSuccess: () {
                // Keep success screen visible inside modal until user clicks continue shopping
              },
            ),

          // ── Auth Modal ────────────────────────────────────────────
          if (_isAuthOpen)
            WebAuthModal(
              onClose: () => setState(() => _isAuthOpen = false),
              onAuthSuccess: () => setState(() {}),
            ),
        ],
      ),
    );
  }

  String _getSectionTitle(HomeController homeCtrl) {
    if (_activeSection == 'new') return 'NEW ARRIVALS';
    if (_activeSection == 'best') return 'BEST SELLERS';
    if (_activeSection == 'deals') return 'EXCLUSIVE SPECIAL DEALS';
    final brand = homeCtrl.selectedCategory.value;
    return brand.isNotEmpty ? brand.toUpperCase() : 'ALL SNEAKERS';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: WebColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: WebColors.border),
              ),
              child: const Icon(
                CupertinoIcons.search,
                size: 36,
                color: WebColors.textDim,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Sneakers Found',
              style: TextStyle(
                color: WebColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing your brand filter or search terms.',
              style: TextStyle(
                color: WebColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _activeSection = 'all';
                  _isFavoritesOnly = false;
                });
                Get.find<HomeController>().selectCompany(null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WebColors.gold,
                foregroundColor: const Color(0xFF090C10),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'RESET FILTERS',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
      decoration: const BoxDecoration(
        color: WebColors.surface,
        border: Border(top: BorderSide(color: WebColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Col 1: Brand & Tagline
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: WebColors.goldGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports_basketball_rounded,
                              color: Color(0xFF090C10),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'MM AMERICAN SHOES',
                          style: TextStyle(
                            color: WebColors.textMain,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Curated high-performance sneakers, limited edition drops, and original streetwear luxury.',
                      style: TextStyle(
                        color: WebColors.textMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Col 2: Fast perks
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GUARANTEE & SERVICE',
                      style: TextStyle(
                        color: WebColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFooterFeature(
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      text: '100% Verified Authentic Sneakers',
                    ),
                    const SizedBox(height: 8),
                    _buildFooterFeature(
                      icon: CupertinoIcons.airplane,
                      text: 'Fast Doorstep Delivery Nationwide',
                    ),
                    const SizedBox(height: 8),
                    _buildFooterFeature(
                      icon: CupertinoIcons.arrow_2_squarepath,
                      text: 'Hassle-Free 7-Day Exchange Policy',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: WebColors.border, height: 48),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2026 MM American Shoes. All rights reserved.',
                style: TextStyle(color: WebColors.textDim, fontSize: 12),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Get.toNamed('/AdminDashboardView'),
                    child: const Text(
                      'Admin Vault',
                      style: TextStyle(color: WebColors.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterFeature({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: WebColors.gold),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: WebColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}
