import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/responsive_text.dart';
import '../home/product_detail_view.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── TOP BAR ────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Circle Button (Functional both as Route pop and Tab switch)
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        controller.changeIndex(0);
                      }
                    },
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
                    'Favourite',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),

                  // Right Heart Header Icon Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.onboardingTitle,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── FAVORITES GRID (With Smooth Entrance Animation) ────────────────
            Expanded(
              child: Obx(() {
                final favorites = controller.favoriteProducts;

                if (favorites.isEmpty) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Clean Vector Heart Illustration (No surrounding box container)
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Image.asset(
                                AppImages.emptyFavorite,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ResponsiveText(
                              'No Favorites Yet',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onboardingTitle,
                            ),
                            const SizedBox(height: 8),
                            const ResponsiveText(
                              'Tap the heart icon on any shoe to save your favorites here.',
                              fontSize: 14,
                              color: AppColors.onboardingSub,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: 10,
                      ),
                      itemCount: favorites.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 156 / 203,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return _buildFavoriteCard(context, product, controller, index);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── 156x203 Favorite Product Card ──
  Widget _buildFavoriteCard(
    BuildContext context,
    Product product,
    HomeController controller,
    int index,
  ) {
    // Dynamic color dots for card design
    final colorDots = _getCardColorDots(index);

    return GestureDetector(
      onTap: () => Get.to(
        () => ProductDetailView(
          product: product,
          heroTag: 'fav_${product.id}',
        ),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Heart Icon (Top Left)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => controller.toggleFavorite(product.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE8EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),

            // Middle: Shoe Image (Scaled at 0.92 to match Best Seller card scaling)
            Expanded(
              child: Center(
                child: Transform.scale(
                  scale: 0.92,
                  child: Hero(
                    tag: 'fav_${product.id}',
                    child: Image.asset(
                      product.image,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),

            // BEST SELLER tag (light blue text)
            const ResponsiveText(
              'BEST SELLER',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF70B9E8),
            ),
            const SizedBox(height: 3),

            // Product Name
            ResponsiveText(
              product.name,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.onboardingTitle,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Bottom Row: Price + Color Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ResponsiveText(
                  '\$${product.price.toStringAsFixed(1)}',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorDots[0],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 10,
                      height: 10,
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

  List<Color> _getCardColorDots(int index) {
    switch (index % 4) {
      case 0:
        return const [Color(0xFFE8F88E), Color(0xFF6EE7CE)];
      case 1:
        return const [Color(0xFF60A5FA), Color(0xFF475569)];
      case 2:
        return const [Color(0xFF3B82F6), Color(0xFFF59E0B)];
      default:
        return const [Color(0xFF6EE7CE), Color(0xFF6366F1)];
    }
  }
}
