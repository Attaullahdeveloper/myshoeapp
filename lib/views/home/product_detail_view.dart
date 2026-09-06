import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_shimmer.dart';
import '../cart/cart_view.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;
  final String heroTag;

  const ProductDetailView({
    super.key,
    required this.product,
    required this.heroTag,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _shoeScaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Staggered details inside the card
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _colorsFadeAnimation;
  late Animation<double> _sizesFadeAnimation;

  late int _selectedSize;
  late String _selectedColor;
  String _selectedUnit = 'EU';

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    _selectedSize = p.sizes.isNotEmpty ? p.sizes.first : 40;
    _selectedColor = p.colors.isNotEmpty ? p.colors.first : '#1A2530';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _shoeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _titleFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );

    _colorsFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    _sizesFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF1A2530);
    }
  }

  Widget _buildProductImage(String imagePath, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerImageLoader(
            width: width ?? 200,
            height: height ?? 140,
            borderRadius: 16,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported_rounded,
            size: 90,
            color: Color(0xFF707B81),
          );
        },
      );
    } else if (imagePath.startsWith('/') || imagePath.contains(':\\') || imagePath.contains('/data/')) {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported_rounded,
            size: 90,
            color: Color(0xFF707B81),
          );
        },
      );
    } else if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported_rounded,
            size: 90,
            color: Color(0xFF707B81),
          );
        },
      );
    }
    return const Icon(
      Icons.shopping_bag_outlined,
      size: 90,
      color: AppColors.onboardingBtn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final product = widget.product;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ── TOP BAR ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.onboardingTitle,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  ResponsiveText(
                    product.category.isNotEmpty ? product.category : "Men's Shoes",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const CartView()),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/shopping_bag.png',
                          width: 22,
                          height: 22,
                          color: AppColors.onboardingTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── MAIN SHOE DISPLAY AREA ──
            SizedBox(
              height: size.height * 0.32,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Slider Ring Background
                  Positioned(
                    bottom: 10,
                    child: Image.asset(
                      'assets/images/slider_ring.png',
                      width: size.width * 0.85,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // Hero Shoe Image (High Res & Properly Scaled)
                  Positioned(
                    bottom: 30,
                    child: Hero(
                      tag: widget.heroTag,
                      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return _buildProductImage(product.image, width: size.width * 0.75, height: 180);
                          },
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _shoeScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _shoeScaleAnimation.value,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: size.width * 0.75,
                          height: 180,
                          child: _buildProductImage(product.image, width: size.width * 0.75, height: 180),
                        ),
                      ),
                    ),
                  ),

                  // Floating Availability Badge (Top Right)
                  Positioned(
                    top: 10,
                    right: size.width * 0.06,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isAvailableStatus
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: product.isAvailableStatus
                              ? const Color(0xFF81C784)
                              : const Color(0xFFE57373),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: product.isAvailableStatus
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isAvailableStatus ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: product.isAvailableStatus
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Discount Tag Pill (Top Left)
                  if (product.hasDiscount && product.discountPercentage > 0)
                    Positioned(
                      top: 10,
                      left: size.width * 0.06,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-${product.discountPercentage.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── BOTTOM DETAIL CARD (White Card) ──
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Scrollable Content
                      Positioned.fill(
                        bottom: 90 + bottomPadding,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Badges & Title section
                              AnimatedBuilder(
                                animation: _titleFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _titleFadeAnimation.value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1.0 - _titleFadeAnimation.value) * 12),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (product.isBestSeller) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const ResponsiveText(
                                              'BEST SELLER',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        if (product.isNewArrival) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3F2FD),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const ResponsiveText(
                                              'NEW ARRIVAL',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        // Company Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.onboardingBtn.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ResponsiveText(
                                            product.category,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.onboardingBtn,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ResponsiveText(
                                      product.name,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onboardingTitle,
                                    ),
                                    const SizedBox(height: 8),

                                    // Dynamic Price Display (Original & Discounted)
                                    if (product.hasDiscount && product.discountedPrice > 0) ...[
                                      Row(
                                        children: [
                                          ResponsiveText(
                                            '\$${product.discountedPrice.toStringAsFixed(2)}',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFFE74C3C),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF707B81),
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFE8EC),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '-${product.discountPercentage.toInt()}%',
                                              style: const TextStyle(
                                                color: Color(0xFFE74C3C),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      ResponsiveText(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onboardingTitle,
                                      ),
                                    ],

                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF707B81)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Stock Available: ${product.totalStock} pairs',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF707B81),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                    ResponsiveText(
                                      product.description,
                                      fontSize: 14,
                                      color: AppColors.onboardingSub,
                                      maxLines: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 2. Color Selection (Replaces Gallery)
                              AnimatedBuilder(
                                animation: _colorsFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _colorsFadeAnimation.value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1.0 - _colorsFadeAnimation.value) * 12),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const ResponsiveText(
                                      'Select Color',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onboardingTitle,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: (product.colors.isNotEmpty
                                              ? product.colors
                                              : ['#1A2530', '#5B9EE1', '#E74C3C'])
                                          .map((hex) {
                                        final isSelected = _selectedColor == hex;
                                        final colVal = _parseHexColor(hex);
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedColor = hex;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 14),
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: colVal,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.onboardingBtn
                                                    : Colors.black12,
                                                width: isSelected ? 3 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.onboardingBtn.withValues(alpha: 0.35),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check_rounded,
                                                    size: 20,
                                                    color: colVal.computeLuminance() > 0.5
                                                        ? Colors.black
                                                        : Colors.white,
                                                  )
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 3. Size Selection
                              AnimatedBuilder(
                                animation: _sizesFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _sizesFadeAnimation.value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1.0 - _sizesFadeAnimation.value) * 12),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const ResponsiveText(
                                              'Select Size',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onboardingTitle,
                                            ),
                                            const SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () => _showAllSizesBottomSheet(context, product),
                                              child: const ResponsiveText(
                                                'See all',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.onboardingBtn,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: ['EU', 'US', 'UK'].map((unit) {
                                            final isSelected = _selectedUnit == unit;
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedUnit = unit;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                child: ResponsiveText(
                                                  unit,
                                                  fontSize: 13,
                                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                                  color: isSelected ? AppColors.onboardingTitle : AppColors.onboardingSub,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: (product.sizes.isNotEmpty ? product.sizes : [38, 39, 40, 41, 42, 43]).map((sizeVal) {
                                          final isSelected = _selectedSize == sizeVal;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedSize = sizeVal;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(right: 10),
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: isSelected ? AppColors.onboardingBtn : const Color(0xFFF9F9F9),
                                                shape: BoxShape.circle,
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: AppColors.onboardingBtn.withValues(alpha: 0.35),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: ResponsiveText(
                                                  sizeVal.toString(),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected ? Colors.white : AppColors.onboardingTitle,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fixed Bottom Price & Add to Cart Bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 28,
                            right: 28,
                            top: 16,
                            bottom: 16 + bottomPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ResponsiveText(
                                    'Total Price',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onboardingSub,
                                  ),
                                  const SizedBox(height: 4),
                                  if (product.hasDiscount && product.discountedPrice > 0) ...[
                                    Row(
                                      children: [
                                        ResponsiveText(
                                          '\$${product.discountedPrice.toStringAsFixed(2)}',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFE74C3C),
                                        ),
                                        const SizedBox(width: 4),
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
                                    ),
                                  ] else ...[
                                    ResponsiveText(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onboardingTitle,
                                    ),
                                  ],
                                ],
                              ),
                              GestureDetector(
                                onTap: product.isOutOfStock
                                    ? () {
                                        AppToast.showError(
                                          context: context,
                                          title: 'Item Unavailable',
                                          message:
                                              'Sorry, this shoe is currently out of stock!',
                                        );
                                      }
                                    : () {
                                        final isNew = CartController.to.addToCart(
                                          product,
                                          selectedSize: _selectedSize,
                                          selectedUnit: _selectedUnit,
                                        );
                                        if (isNew) {
                                          AppToast.showSuccess(
                                            context: context,
                                            title: 'Added to Cart',
                                            message:
                                                '${product.name} (Size $_selectedSize) added to cart!',
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
                                  width: 167,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: product.isOutOfStock
                                        ? const Color(0xFF94A3B8)
                                        : AppColors.onboardingBtn,
                                    borderRadius: BorderRadius.circular(27),
                                    boxShadow: product.isOutOfStock
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: AppColors.onboardingBtn.withValues(alpha: 0.40),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (product.isOutOfStock) ...[
                                          const Icon(Icons.block_rounded, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                        ],
                                        ResponsiveText(
                                          product.isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllSizesBottomSheet(BuildContext context, Product product) {
    final sizesList = product.sizes.isNotEmpty ? product.sizes : [37, 38, 39, 40, 41, 42, 43, 44, 45];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ResponsiveText(
                    'Available Shoe Sizes',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onboardingTitle,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: sizesList.map((sz) {
                      final isSelected = _selectedSize == sz;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = sz;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.onboardingBtn : const Color(0xFFF9F9F9),
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.onboardingBtn.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: ResponsiveText(
                              '$sz',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.onboardingTitle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
