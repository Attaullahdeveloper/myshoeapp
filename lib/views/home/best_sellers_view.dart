import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/shimmer_loader.dart';
import 'product_detail_view.dart';
import 'home_view.dart';

class BestSellersView extends StatefulWidget {
  const BestSellersView({super.key});

  @override
  State<BestSellersView> createState() => _BestSellersViewState();
}

class _BestSellersViewState extends State<BestSellersView> {
  bool _isLoading = true;

  // Preset color dot pairs for shoe cards matching design mockup
  final List<List<Color>> _colorPairs = const [
    [Color(0xFF38EF7D), Color(0xFF6DD5FA)], // Cyan & Blue
    [Color(0xFF1E88E5), Color(0xFFFF7043)], // Blue & Orange
    [Color(0xFF29B6F6), Color(0xFF43A047)], // Cyan & Green
    [Color(0xFFEC407A), Color(0xFF3F51B5)], // Pink & Purple
    [Color(0xFF4CAF50), Color(0xFF7E57C2)], // Green & Purple
    [Color(0xFFAB47BC), Color(0xFF42A5F5)], // Purple & Blue
  ];

  @override
  void initState() {
    super.initState();
    // Simulate high-end shimmer skeleton loading on view load
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── TOP HEADER ROW ────────────────────────────────────────────────
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
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.onboardingTitle,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Center Title
                  ResponsiveText(
                    'Best Sellers',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                    usePlayfair: true,
                  ),

                  // Right Action Icons (Filter & Search)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            'Filter & Sort',
                            'Opening filter options...',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.tune_rounded,
                              color: AppColors.onboardingTitle,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            'Search',
                            'Search functionality coming soon...',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.search_rounded,
                              color: AppColors.onboardingTitle,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 2-COLUMN GRID VIEW OF BEST SELLERS SHOES ──────────────────────
            Expanded(
              child: _isLoading
                  ? const BestSellersGridSkeleton(itemCount: 6)
                  : Obx(() {
                      final allProducts = controller.products;
                      // Prefer best seller shoes first, or show all shoes
                      final bestSellers = allProducts.where((p) => p.isBestSeller).toList();
                      final displayList = bestSellers.isNotEmpty ? bestSellers : allProducts;

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final product = displayList[index];
                          final colors = _colorPairs[index % _colorPairs.length];
                          return ScaleFadeShuffleWidget(
                            index: index,
                            child: _buildBestSellerCard(context, product, colors),
                          );
                        },
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellerCard(BuildContext context, Product product, List<Color> colorDots) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailView(
            product: product,
            heroTag: 'best_seller_grid_${product.id}',
          )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center Shoe Image with subtle ground shadow
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ground shadow
                  Positioned(
                    bottom: 4,
                    child: Transform.scale(
                      scaleX: 1.1,
                      scaleY: 0.2,
                      child: Container(
                        width: 70,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Product Shoe Image
                  Hero(
                    tag: 'best_seller_grid_${product.id}',
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // BEST SELLER Subtitle
            ResponsiveText(
              'BEST SELLER',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.onboardingBtn,
            ),
            const SizedBox(height: 4),

            // Shoe Name
            ResponsiveText(
              product.name,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.onboardingTitle,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Shoe Category / Gender
            ResponsiveText(
              "Men's Shoes",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.onboardingSub,
            ),
            const SizedBox(height: 10),

            // Bottom Row: Price & Color Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveText(
                  '\$${product.price.toStringAsFixed(2)}',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onboardingTitle,
                ),
                Row(
                  children: [
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: colorDots[0],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: colorDots[1],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
