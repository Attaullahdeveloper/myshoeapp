import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/bottom_bar_clipper.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/fluid_pop_nav_item.dart';
import '../../models/product.dart';
import 'product_detail_view.dart';
import 'best_sellers_view.dart';
import '../cart/cart_view.dart';
import '../favorites/favorite_view.dart';
import '../notifications/notifications_view.dart';
import 'search_view.dart';
import '../profile/profile_view.dart';
import '../profile/account_settings_view.dart';
import '../orders/my_orders_view.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_shimmer.dart';

class HomeView extends StatelessWidget {
  final ZoomDrawerController? zoomDrawerController;
  const HomeView({super.key, this.zoomDrawerController});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barHeight = 84.0 + bottomPadding;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background color
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ── Background container ──
            Container(
              color: AppColors.onboardingBg,
            ),

            // ── Switchable Page Content based on selected index ──
            SafeArea(
              bottom: false,
              child: Obx(() {
                switch (controller.selectedIndex.value) {
                  case 0:
                    return _buildHomeTab(context, controller);
                  case 1:
                    return _buildFavoritesTab(context, controller);
                  case 2:
                    return _buildNotificationsTab(context, controller);
                  case 3:
                    return _buildProfileTab(context, controller);
                  default:
                    return _buildHomeTab(context, controller);
                }
              }),
            ),

            // ── Curved Bottom Navigation Bar (Hidden when keyboard is open) ──
            if (!isKeyboardOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Curved bar background container with shadow
                  PhysicalShape(
                    clipper: BottomBarClipper(),
                    elevation: 15,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    color: Colors.white, // White bar background
                    child: SizedBox(
                      height: barHeight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding + 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Obx(() => FluidPopNavItem(
                                  index: 0,
                                  iconPath: 'assets/icons/home.png',
                                  isSelected: controller.selectedIndex.value == 0,
                                  onTap: () => controller.changeIndex(0),
                                )),
                            Obx(() => FluidPopNavItem(
                                  index: 1,
                                  iconPath: 'assets/icons/favorite.png',
                                  isSelected: controller.selectedIndex.value == 1,
                                  onTap: () => controller.changeIndex(1),
                                )),
                            const SizedBox(width: 44), // Symmetrical gap for center FAB scoop
                            Obx(() => FluidPopNavItem(
                                  index: 2,
                                  iconData: Icons.notifications_none_outlined,
                                  isSelected: controller.selectedIndex.value == 2,
                                  onTap: () => controller.changeIndex(2),
                                )),
                            Obx(() => FluidPopNavItem(
                                  index: 3,
                                  iconPath: 'assets/icons/profile.png',
                                  isSelected: controller.selectedIndex.value == 3,
                                  onTap: () => controller.changeIndex(3),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Action Button (FAB) inside center scoop (standard no animation)
                  Positioned(
                    bottom: 34 + bottomPadding,
                    child: GestureDetector(
                      onTap: () => Get.to(() => const CartView()),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.onboardingBtn,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onboardingBtn.withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/shopping_bag.png',
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                        ),
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

  // ── Helper Widget for Menu & Cart Buttons in Header ──
  Widget _buildHeaderButton(String assetPath, {required VoidCallback onTap, int? badgeCount, double? width, double? height}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: width ?? (assetPath.contains('menu_dots') ? 30.0 : 38.0),
            height: height ?? (assetPath.contains('menu_dots') ? 32.0 : 38.0),
          ),
        ),
      ),
    );
  }

  // ── TAB 0: HOME CONTENT ──
  Widget _buildHomeTab(BuildContext context, HomeController controller) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 105), // extra space to not clip behind bottom bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // ── Header Row ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderButton('assets/icons/menu_dots.png', onTap: () {
                  ZoomDrawer.of(context)?.toggle();
                  zoomDrawerController?.toggle?.call();
                }),
                Column(
                  children: [
                    ResponsiveText(
                      'Store Location',
                      fontSize: 12,
                      color: AppColors.onboardingSub,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                         ResponsiveText(
                          'Ashiyana Plaza DIK',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onboardingTitle,
                        ),
                      ],
                    ),
                  ],
                ),
                _buildHeaderButton('assets/icons/cart_header.png', onTap: () {
                  Get.to(() => const CartView());
                }, badgeCount: 2),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Search Row (Full Width) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: GestureDetector(
              onTap: () => Get.to(() => const SearchView()),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const AbsorbPointer(
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.onboardingSub,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          style: TextStyle(
                            fontFamily: 'Airbnb Cereal App',
                            fontSize: 15,
                            color: AppColors.onboardingTitle,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Looking for shoes',
                            hintStyle: TextStyle(
                              fontFamily: 'Airbnb Cereal App',
                              fontSize: 14,
                              color: AppColors.onboardingSub,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.024),

          // ── BRANDS Section Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'BRANDS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.selectCompany(null),
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B9EE1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Category List (Horizontal Brand Chips - Dynamic from Supabase) ──
          SizedBox(
            height: 40,
            child: Obx(() {
              if (controller.isLoadingCompanies.value && controller.companies.isEmpty) {
                return const HomeBrandLogosShimmer();
              }

              final totalCount = 1 + controller.companies.length;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final bool isAllShoes = index == 0;
                    final bool isSelected = isAllShoes
                        ? controller.selectedCompanyId.value == null
                        : controller.selectedCompanyId.value ==
                            controller.companies[index - 1]['id']?.toString();

                    final String name = isAllShoes
                        ? 'All Shoes'
                        : (controller.companies[index - 1]['name']?.toString() ?? 'Brand');

                    final String? logoUrl = isAllShoes
                        ? null
                        : controller.companies[index - 1]['image_url']?.toString();

                    final String? companyId = isAllShoes
                        ? null
                        : controller.companies[index - 1]['id']?.toString();

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          if (isAllShoes) {
                            controller.selectCompany(null);
                          } else {
                            if (isSelected) {
                              controller.selectCompany(null);
                            } else {
                              controller.selectCompany(companyId);
                            }
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (logoUrl != null && logoUrl.isNotEmpty) ...[
                                SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: logoUrl.startsWith('http')
                                      ? Image.network(
                                          logoUrl,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                        )
                                      : Image.asset(
                                          logoUrl,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                        ),
                                ),
                                const SizedBox(width: 7),
                              ],
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),

          SizedBox(height: size.height * 0.032),

          // ── Popular Shoes Section Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ResponsiveText(
                  'Popular Shoes',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
                GestureDetector(
                  onTap: () => Get.to(() => BestSellersView(
                        initialBrand: controller.selectedCategory.value,
                      )),
                  child: const ResponsiveText(
                    'See all',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onboardingBtn,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Popular Shoes Cards horizontal list ──
          SizedBox(
            height: 215,
            child: Obx(() {
              if (controller.isLoadingProducts.value) {
                return const HomePopularShoesShimmer(count: 3);
              }

              final list = controller.products;
              final activeKey = controller.selectedCompanyId.value ?? 'all';

              if (list.isEmpty) {
                return Center(
                  key: ValueKey('empty_$activeKey'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.do_not_disturb_alt_outlined,
                        size: 38,
                        color: AppColors.onboardingSub.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      const ResponsiveText(
                        'No shoes found for this brand',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onboardingSub,
                      ),
                    ],
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: ListView.builder(
                  key: ValueKey(activeKey),
                  controller: controller.getScrollController(activeKey),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ScaleFadeShuffleWidget(
                      index: index,
                      child: _buildProductCard(context, list[index], controller, index, activeKey),
                    );
                  },
                ),
              );
            }),
          ),

          SizedBox(height: size.height * 0.035),

          // ── New Arrivals Section Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ResponsiveText(
                  'New Arrivals',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const BestSellersView(initialBrand: 'All')),
                  child: const ResponsiveText(
                    'See all',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onboardingBtn,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── New Arrivals Cards horizontal list ──
          SizedBox(
            height: 125,
            child: Obx(() {
              if (controller.isLoadingNewArrivals.value && controller.newArrivalProducts.isEmpty) {
                return const HomeNewArrivalsShimmer();
              }
              final newArrivals = controller.newArrivalProducts;
              if (newArrivals.isEmpty) {
                return Center(
                  child: ResponsiveText(
                    'No new arrivals found',
                    fontSize: 14,
                    color: AppColors.onboardingSub,
                  ),
                );
              }
              return PageView.builder(
                controller: controller.newArrivalsPageController,
                physics: const BouncingScrollPhysics(),
                itemCount: 10000,
                itemBuilder: (context, index) {
                  final product = newArrivals[index % newArrivals.length];
                  return AnimatedBuilder(
                    animation: controller.newArrivalsPageController,
                    builder: (context, child) {
                      double pageOffset = 0.0;
                      if (controller.newArrivalsPageController.position.haveDimensions) {
                        pageOffset = controller.newArrivalsPageController.page! - index;
                      } else {
                        pageOffset = (index % newArrivals.length == 0) ? 0.0 : 1.0;
                      }
                      return _buildNewArrivalCard(size, product, pageOffset);
                    },
                  );
                },
              );
            }),
          ),
          SizedBox(height: size.height * 0.035),

          // ── Special Offers / Discount Deals Section Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ResponsiveText(
                  'Special Offers',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ResponsiveText(
                    'HOT DEALS',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Special Offers Cards horizontal list (Same style as New Arrivals) ──
          SizedBox(
            height: 125,
            child: Obx(() {
              if (controller.isLoadingDiscountProducts.value) {
                return const HomeNewArrivalsShimmer();
              }

              final discounts = controller.discountProducts;

              if (discounts.isEmpty) {
                return Center(
                  child: ResponsiveText(
                    'No special discount deals right now',
                    fontSize: 13,
                    color: AppColors.onboardingSub,
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                itemCount: discounts.length,
                itemBuilder: (context, index) {
                  return ScaleFadeShuffleWidget(
                    index: index,
                    child: _buildNewArrivalCard(size, discounts[index], 0.0),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Product Card Builder ──
  Widget _buildProductCard(BuildContext context, Product product, HomeController controller, [int index = 0, String category = '']) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailView(product: product, heroTag: 'popular_${product.id}_$category'), transition: Transition.fadeIn, duration: const Duration(milliseconds: 300)),
      child: Container(
      width: 157,
      height: 201,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1a. Heart Favorite Button (Top Left)
          Positioned(
            top: 10,
            left: 10,
            child: Obx(() => GestureDetector(
                  onTap: () => controller.toggleFavorite(product.id),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: product.isFavorite.value
                          ? const Color(0xFFFFE8EC)
                          : const Color(0xFFF9F9F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/favorite.png',
                        width: 13,
                        height: 13,
                        color: product.isFavorite.value
                            ? Colors.redAccent
                            : AppColors.onboardingSub,
                      ),
                    ),
                  ),
                )),
          ),

          // 1b. Availability Indicator Badge (Top Right)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: product.isAvailableStatus
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: product.isAvailableStatus
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    product.isAvailableStatus ? 'In Stock' : 'Sold Out',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: product.isAvailableStatus
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 1c. Floating Discount Tag Pill (if product hasDiscount)
          if (product.hasDiscount && product.discountPercentage > 0)
            Positioned(
              top: 40,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${product.discountPercentage.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          // 2. Centered & Scaled Shoe Image with "The Parallax Depth Shift"
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            bottom: 74,
            child: IgnorePointer(
              child: category.isEmpty 
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ground shadow under shoe
                      Positioned(
                        bottom: 2,
                        child: Transform.scale(
                          scaleX: 1.1,
                          scaleY: 0.18,
                          child: Container(
                            width: 80,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Rotating and scaling product image
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(-0.08)
                          ..scale(_getShoeScaleFactor(product.image, false)),
                        child: Hero(
                          tag: 'popular_${product.id}_$category',
                          child: _buildProductImage(product.image),
                        ),
                      ),
                    ],
                  )
                : AnimatedBuilder(
                    animation: controller.getScrollController(category),
                    builder: (context, child) {
                      double parallaxShift = 0.0;
                      double shadowShift = 0.0;
                      
                      final scrollController = controller.getScrollController(category);
                      if (scrollController.hasClients) {
                        final scrollOffset = scrollController.offset;
                        final size = MediaQuery.of(context).size;
                        final double startPadding = size.width * 0.05;
                        final double cardWidth = 157.0;
                        final double cardMargin = 16.0;
                        
                        final double cardX = (index * (cardWidth + cardMargin)) + startPadding - scrollOffset;
                        final double cardCenter = cardX + (cardWidth / 2.0);
                        final double screenCenter = size.width / 2.0;
                        
                        final double normalizedDistance = ((cardCenter - screenCenter) / (size.width / 2.0)).clamp(-1.0, 1.0);
                        
                        parallaxShift = normalizedDistance * -20.0;
                        shadowShift = normalizedDistance * -10.0;
                      }
                      
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ground shadow under shoe
                          Positioned(
                            bottom: 2,
                            child: Transform.translate(
                              offset: Offset(shadowShift, 0),
                              child: Transform.scale(
                                scaleX: 1.1,
                                scaleY: 0.18,
                                child: Container(
                                  width: 80,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Rotating and scaling product image
                          Transform.translate(
                            offset: Offset(parallaxShift, 0),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateZ(-0.08)
                                ..scale(_getShoeScaleFactor(product.image, false)),
                              child: Hero(
                                tag: 'popular_${product.id}_$category',
                                child: _buildProductImage(product.image),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),

          // 3. Info Text column (Bottom Left area, padded to avoid overlapping button)
          Positioned(
            left: 10,
            bottom: 8,
            right: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product.isBestSeller) ...[
                      const ResponsiveText(
                        'BEST SELLER',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingBtn,
                      ),
                      const SizedBox(width: 4),
                    ],
                    // ── Company Badge Chip ──
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.onboardingBtn.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ResponsiveText(
                          product.category,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingBtn,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                ResponsiveText(
                  product.name,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onboardingTitle,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (product.hasDiscount && product.discountedPrice > 0) ...[
                  Row(
                    children: [
                      ResponsiveText(
                        '\$${product.discountedPrice.toStringAsFixed(2)}',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE74C3C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF707B81),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ResponsiveText(
                    '\$${product.price.toStringAsFixed(2)}',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),
                ],
              ],
            ),
          ),

          // ── Semi-transparent dark grey overlay with OUT OF STOCK red badge ──
          if (product.isOutOfStock)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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

          // 4. Add Button (Positioned at exact bottom right corner)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: product.isOutOfStock
                  ? null
                  : () {
                      final isNew =
                          CartController.to.addToCart(product, selectedSize: 40);
                      if (isNew) {
                        AppToast.showSuccess(
                          context: context,
                          title: 'Added to Cart',
                          message: '${product.name} added to your cart (Qty: 1)!',
                        );
                      } else {
                        AppToast.showSuccess(
                          context: context,
                          title: 'Already in Cart',
                          message:
                              '${product.name} is already in your cart (Qty: 1)!',
                        );
                      }
                    },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: product.isOutOfStock
                      ? const Color(0xFFCBD5E1)
                      : AppColors.onboardingBtn,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: product.isOutOfStock
                      ? const Color(0xFF94A3B8)
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── New Arrival Card Builder ──
  Widget _buildNewArrivalCard(Size size, Product product, double pageOffset) {
    // 1. Card level transformations
    final double cardScale = (1.0 - (pageOffset.abs() * 0.05)).clamp(0.95, 1.0);
    final double cardOpacity = (1.0 - (pageOffset.abs() * 0.3)).clamp(0.7, 1.0);

    // 2. Staggered Slide & Fade for Text
    final double pageOffsetFactor = pageOffset.clamp(-1.0, 1.0);
    final double tagX = pageOffsetFactor * 25.0;
    final double nameX = pageOffsetFactor * 45.0;
    final double priceX = pageOffsetFactor * 65.0;
    final double textOpacity = (1.0 - pageOffset.abs()).clamp(0.0, 1.0);

    // 3. Scale-Pop & Slight Tilt for Shoe
    final double baseScale = _getShoeScaleFactor(product.image, true);
    final double shoeScale = (1.15 - (pageOffset.abs() * 0.15)).clamp(0.95, 1.15);
    final double shoeTilt = -0.08 - (pageOffsetFactor * 0.08);

    return Transform.scale(
      scale: cardScale,
      child: Opacity(
        opacity: cardOpacity,
        child: GestureDetector(
          onTap: () => Get.to(() => ProductDetailView(product: product, heroTag: 'new_arrival_${product.id}'), transition: Transition.fadeIn, duration: const Duration(milliseconds: 300)),
          child: Container(
          width: size.width * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Banner text details (Staggered Slide & Fade)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(tagX, 0),
                      child: Opacity(
                        opacity: textOpacity,
                        child: ResponsiveText(
                          product.hasDiscount && product.discountPercentage > 0
                              ? '${product.discountPercentage.toInt()}% OFF DEAL'
                              : 'Best Choice',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: product.hasDiscount ? const Color(0xFFE74C3C) : AppColors.onboardingBtn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Transform.translate(
                      offset: Offset(nameX, 0),
                      child: Opacity(
                        opacity: textOpacity,
                        child: SizedBox(
                          width: size.width * 0.46,
                          child: ResponsiveText(
                            product.name,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onboardingTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Transform.translate(
                      offset: Offset(priceX, 0),
                      child: Opacity(
                        opacity: textOpacity,
                        child: product.hasDiscount && product.discountedPrice > 0
                            ? Row(
                                children: [
                                  ResponsiveText(
                                    '\$${product.discountedPrice.toStringAsFixed(2)}',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFE74C3C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF707B81),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              )
                            : ResponsiveText(
                                '\$${product.price.toStringAsFixed(2)}',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onboardingTitle,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Shoe image centered on the right (Scale-Pop + Slight Tilt)
              Positioned(
                right: 20,
                top: 10,
                bottom: 10,
                child: IgnorePointer(
                  child: SizedBox(
                    width: size.width * 0.35,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ground shadow
                        Positioned(
                          bottom: 4,
                          child: Transform.scale(
                            scaleX: 1.1,
                            scaleY: 0.18,
                            child: Container(
                              width: 70,
                              height: 15,
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
                        // shoe image
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateZ(shoeTilt)
                            ..scale(baseScale * shoeScale),
                          child: Hero(
                            tag: 'new_arrival_${product.id}',
                            child: _buildProductImage(product.image),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Small tag badge decoration
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE8EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.redAccent,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ── Helper widget for product image (Image.network, Image.file, or Image.asset) ──
  Widget _buildProductImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: ShimmerImageLoader(
              width: 100,
              height: 70,
              borderRadius: 12,
            ),
          );
        },
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/shoe_nike_1.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.style, size: 50, color: Colors.grey),
        ),
      );
    } else if (imagePath.startsWith('/') || imagePath.contains(':\\') || imagePath.contains('/data/')) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/shoe_nike_1.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.style, size: 50, color: Colors.grey),
        ),
      );
    } else if (imagePath.isNotEmpty && imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.style, size: 50, color: Colors.grey),
      );
    } else {
      return const Icon(Icons.style, size: 50, color: Colors.grey);
    }
  }

  // ── TAB 1: FAVORITES SCREEN ──
  Widget _buildFavoritesTab(BuildContext context, HomeController controller) {
    return const FavoriteView();
  }

  // ── TAB 2: NOTIFICATIONS TAB ──
  Widget _buildNotificationsTab(BuildContext context, HomeController controller) {
    return const NotificationsView();
  }

  // ── TAB 3: PROFILE TAB ──
  Widget _buildProfileTab(BuildContext context, HomeController controller) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 105),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderButton('assets/icons/menu_dots.png', onTap: () {
                  ZoomDrawer.of(context)?.toggle();
                  zoomDrawerController?.toggle?.call();
                }),
                ResponsiveText(
                  'Profile',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                  usePlayfair: true,
                ),
                _buildHeaderButton('assets/icons/cart_header.png', onTap: () {}, badgeCount: 2),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // User Card
          Center(
            child: Column(
              children: [
                // Avatar image with shadow
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: Container(
                        color: AppColors.onboardingBtn.withValues(alpha: 0.15),
                        width: 82,
                        height: 82,
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.onboardingBtn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ResponsiveText(
                  'Alisson Becker',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onboardingTitle,
                ),
                const SizedBox(height: 4),
                ResponsiveText(
                  'alissonbecker@gmail.com',
                  fontSize: 13,
                  color: AppColors.onboardingSub,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Profile List Options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              children: [
                _buildProfileOption(Icons.person_outline_rounded, 'Account Details', () {
                  Get.to(() => const ProfileView());
                }),
                _buildProfileOption(Icons.shopping_bag_outlined, 'My Orders', () {
                  Get.to(() => const MyOrdersView());
                }),
                _buildProfileOption(Icons.favorite_border_rounded, 'Favorites', () {
                  controller.changeIndex(1); // navigate to favorites tab
                }),
                _buildProfileOption(Icons.credit_card_rounded, 'Payment Details', () {}),
                _buildProfileOption(Icons.settings_outlined, 'App Settings', () {
                  Get.to(() => const AccountSettingsView());
                }),
                const Divider(height: 32, color: Colors.black12),
                _buildProfileOption(
                  Icons.power_settings_new_rounded,
                  'Log Out',
                  () {
                    Get.defaultDialog(
                      title: 'Logout',
                      middleText: 'Are you sure you want to logout?',
                      textConfirm: 'Yes',
                      textCancel: 'No',
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      onConfirm: () {
                        Get.back();
                        AppToast.showInfo(
                          title: 'Logged Out',
                          message: 'Successfully logged out.',
                        );
                      },
                    );
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.005),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : AppColors.onboardingBtn,
        ),
        title: ResponsiveText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.redAccent : AppColors.onboardingTitle,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.black26,
        ),
      ),
    );
  }

  // ── Bottom Sheet for Filters ──
  // ignore: unused_element
  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const ResponsiveText(
            'Filters',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onboardingTitle,
            usePlayfair: true,
          ),
          const SizedBox(height: 16),
          const ResponsiveText(
            'Gender',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onboardingTitle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterOption('Men', true),
              const SizedBox(width: 12),
              _buildFilterOption('Women', false),
              const SizedBox(width: 12),
              _buildFilterOption('Kids', false),
            ],
          ),
          const SizedBox(height: 24),
          const ResponsiveText(
            'Price Range',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onboardingTitle,
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: const RangeValues(100, 300),
            min: 50,
            max: 500,
            divisions: 9,
            activeColor: AppColors.onboardingBtn,
            labels: const RangeLabels('\$100', '\$300'),
            onChanged: (RangeValues values) {},
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onboardingBtn,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const ResponsiveText(
              'Apply Filters',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.onboardingBtn : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ResponsiveText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.onboardingSub,
      ),
    );
  }

  double _getShoeScaleFactor(String imagePath, bool isNewArrival) {
    if (isNewArrival) {
      // All New Arrival cards use uniform 1.0 scale factor matching the first shoe
      return 1.0;
    } else {
      // All Best Seller / Popular cards use uniform slightly smaller 0.92 scale factor
      return 0.92;
    }
  }
}

// ── Bouncing Shopping Cart Floating Action Button ──
class BouncingCartFAB extends StatefulWidget {
  final VoidCallback onTap;
  const BouncingCartFAB({super.key, required this.onTap});

  @override
  State<BouncingCartFAB> createState() => _BouncingCartFABState();
}

class _BouncingCartFABState extends State<BouncingCartFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Drops from y=-60.0 to y=0.0 with a bouncing effect
    _dropAnimation = Tween<double>(begin: -60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    // Trigger the animation on startup with a tiny delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _dropAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          // Tap triggers another drop and bounce feedback animation
          _controller.forward(from: 0.0);
          widget.onTap();
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.onboardingBtn,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.onboardingBtn.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/shopping_bag.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Scale-Fade Shuffle Entrance Widget ──
class ScaleFadeShuffleWidget extends StatefulWidget {
  final int index;
  final Widget child;
  const ScaleFadeShuffleWidget({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<ScaleFadeShuffleWidget> createState() => _ScaleFadeShuffleWidgetState();
}

class _ScaleFadeShuffleWidgetState extends State<ScaleFadeShuffleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Staggered pop delay
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
