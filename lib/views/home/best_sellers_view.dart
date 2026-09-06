import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/shimmer_loader.dart';
import 'product_detail_view.dart';
import 'home_view.dart';
import 'search_view.dart';

class BestSellersView extends StatefulWidget {
  final String? initialBrand;
  const BestSellersView({super.key, this.initialBrand});

  @override
  State<BestSellersView> createState() => _BestSellersViewState();
}

class _BestSellersViewState extends State<BestSellersView> {
  bool _isLoading = true;
  late final RxString _selectedBrand;

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
    _selectedBrand = (widget.initialBrand ?? 'All').obs;

    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    controller.fetchAllProducts();

    Future.delayed(const Duration(milliseconds: 500), () {
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
                          AppToast.showInfo(
                            context: context,
                            title: 'Filter & Sort',
                            message: 'Select brands using the chips below',
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
                        onTap: () => Get.to(() => const SearchView()),
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

            const SizedBox(height: 14),

            // ── BRAND FILTER CHIPS (All Brands + Individual Companies) ──
            SizedBox(
              height: 38,
              child: Obx(() {
                final companyNames = <String>[];
                for (var c in controller.companies) {
                  final name = c['name']?.toString() ?? '';
                  if (name.isNotEmpty && !companyNames.contains(name)) {
                    companyNames.add(name);
                  }
                }
                final allChips = ['All', ...companyNames];

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  itemCount: allChips.length,
                  itemBuilder: (context, index) {
                    final chipLabel = allChips[index];
                    return Obx(() {
                      final isSelected =
                          _selectedBrand.value.toLowerCase() == chipLabel.toLowerCase();
                      return GestureDetector(
                        onTap: () => _selectedBrand.value = chipLabel,
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.onboardingTitle : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.onboardingTitle : Colors.black12,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              chipLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.onboardingTitle,
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── 2-COLUMN GRID VIEW OF BEST SELLERS SHOES ──────────────────────
            Expanded(
              child: _isLoading
                  ? const BestSellersGridSkeleton(itemCount: 6)
                  : Obx(() {
                      final sourceList = controller.allProducts.isNotEmpty
                          ? controller.allProducts
                          : controller.products;

                      final filteredList = _selectedBrand.value == 'All'
                          ? sourceList
                          : sourceList.where((p) {
                              return p.category.toLowerCase() ==
                                  _selectedBrand.value.toLowerCase();
                            }).toList();

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.do_not_disturb_alt_outlined,
                                size: 48,
                                color: AppColors.onboardingSub.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              ResponsiveText(
                                'No shoes found for ${_selectedBrand.value}',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onboardingSub,
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final product = filteredList[index];
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
                    child: product.image.startsWith('http')
                        ? Image.network(
                            product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                          )
                        : Image.asset(
                            product.image,
                            fit: BoxFit.contain,
                          ),
                  ),

                  // Out of Stock Overlay
                  if (product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
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
