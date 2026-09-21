import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import 'web_colors.dart';
import 'web_product_image_helper.dart';

class WebHeroCarousel extends StatefulWidget {
  final Function(Product product) onProductTap;
  final VoidCallback onShopNowTap;

  const WebHeroCarousel({
    super.key,
    required this.onProductTap,
    required this.onShopNowTap,
  });

  @override
  State<WebHeroCarousel> createState() => _WebHeroCarouselState();
}

class _WebHeroCarouselState extends State<WebHeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      final homeCtrl = Get.find<HomeController>();
      final count = _getHeroItems(homeCtrl).length;
      if (count <= 1) return;
      final nextPage = (_currentPage + 1) % count;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<Product> _getHeroItems(HomeController homeCtrl) {
    if (homeCtrl.newArrivalProducts.isNotEmpty) {
      return homeCtrl.newArrivalProducts.take(4).toList();
    }
    if (homeCtrl.discountProducts.isNotEmpty) {
      return homeCtrl.discountProducts.take(4).toList();
    }
    if (homeCtrl.allProducts.isNotEmpty) {
      return homeCtrl.allProducts.take(4).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();

    return Obx(() {
      final items = _getHeroItems(homeCtrl);
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      final isWide = MediaQuery.of(context).size.width >= 900;
      final heroHeight = isWide ? 440.0 : 540.0;

      return Container(
        height: heroHeight,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: WebColors.heroGradient,
          border: Border.all(color: WebColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background ambient glow circles
            Positioned(
              right: isWide ? 140 : 20,
              top: 40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WebColors.gold.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: WebColors.gold.withOpacity(0.12),
                      blurRadius: 90,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            // Page View
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return _buildHeroSlide(product, isWide);
              },
            ),

            // Carousel Indicators (Bottom Center/Left)
            Positioned(
              bottom: 24,
              left: 36,
              child: Row(
                children: List.generate(items.length, (index) {
                  final isSelected = index == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 5,
                      width: isSelected ? 32 : 12,
                      decoration: BoxDecoration(
                        color: isSelected ? WebColors.gold : WebColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Previous / Next arrow buttons for Desktop
            if (isWide && items.length > 1) ...[
              Positioned(
                right: 24,
                bottom: 24,
                child: Row(
                  children: [
                    _buildArrowButton(
                      icon: CupertinoIcons.chevron_left,
                      onTap: () {
                        final prev = (_currentPage - 1 + items.length) % items.length;
                        _pageController.animateToPage(
                          prev,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildArrowButton(
                      icon: CupertinoIcons.chevron_right,
                      onTap: () {
                        final next = (_currentPage + 1) % items.length;
                        _pageController.animateToPage(
                          next,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: WebColors.surface.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: WebColors.border),
          ),
          child: Icon(icon, color: WebColors.textMain, size: 18),
        ),
      ),
    );
  }

  Widget _buildHeroSlide(Product product, bool isWide) {
    if (isWide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
        child: Row(
          children: [
            // Left Content
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: WebColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: WebColors.gold.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.sparkles, size: 14, color: WebColors.gold),
                        const SizedBox(width: 6),
                        Text(
                          product.status.toUpperCase(),
                          style: const TextStyle(
                            color: WebColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Brand & Title
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: WebColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: WebColors.textMain,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description snippet
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WebColors.textMuted,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Price & CTA Row
                  Row(
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.hasDiscount && product.price > product.finalPrice)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: WebColors.textDim,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${product.finalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: WebColors.gold,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 28),

                      // CTA Button
                      ElevatedButton(
                        onPressed: () => widget.onProductTap(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WebColors.gold,
                          foregroundColor: const Color(0xFF090C10),
                          elevation: 8,
                          shadowColor: WebColors.gold.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'VIEW SNEAKER',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(CupertinoIcons.arrow_right, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 32),

            // Right Sneaker Big Image
            Expanded(
              flex: 5,
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.onProductTap(product),
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: WebProductImageHelper(
                          imagePath: product.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile / Tablet stacked Hero
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center Image
            Center(
              child: GestureDetector(
                onTap: () => widget.onProductTap(product),
                child: Transform.rotate(
                  angle: -0.1,
                  child: SizedBox(
                    height: 180,
                    child: WebProductImageHelper(
                      imagePath: product.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.category.toUpperCase(),
              style: const TextStyle(
                color: WebColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: WebColors.textMain,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: WebColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => widget.onProductTap(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WebColors.gold,
                    foregroundColor: const Color(0xFF090C10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'VIEW DETAILS',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
