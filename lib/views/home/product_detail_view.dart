import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';
import '../../controllers/cart_controller.dart';
import '../cart/cart_view.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;
  final String heroTag;
  const ProductDetailView({super.key, required this.product, required this.heroTag});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _shoeScaleAnimation; // Smooth sequence overshoot
  late Animation<Offset> _slideAnimation;      // Simple Slide View Animation for details card
  
  // Staggered details inside the card
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _galleryFadeAnimation;
  late Animation<double> _sizesFadeAnimation;

  int _selectedSize = 40;
  int _selectedGalleryIndex = 0;
  String _selectedUnit = 'EU';

  @override
  void initState() {
    super.initState();

    // 850ms duration allows the spring and staggered fades to blend seamlessly and smoothly
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // 1. Shoe Scale Overshoot Sequence: Starts at t=0.2 (after landing) with no initial jump
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

    // 2. Simple Slide View Animation for the details card (Slides up in one piece)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // 3. Staggered details inside the card (fades/slides relative to the card's position)
    _titleFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );

    _galleryFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    _sizesFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
    );

    // Start the animation timeline
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Slightly compact shoe scale factor (to satisfy user's request)
  double _getShoeScaleFactor(String imagePath) {
    if (imagePath.contains('shoe_nike_3')) {
      return 1.45; // Was 1.65
    } else if (imagePath.contains('shoe_adidas_red') || 
               imagePath.contains('shoe_nike_orange') || 
               imagePath.contains('shoe_nike_blue') || 
               imagePath.contains('shoe_nike_pink') || 
               imagePath.contains('shoe_nike_grey') || 
               imagePath.contains('shoe_nike_pink_grey')) {
      return 1.22; // Was 1.38
    } else {
      return 1.32; // Was 1.50
    }
  }

  Widget _buildAngleCard({required String title, required Widget child, double? width}) {
    return Container(
      width: width,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          ),
          ResponsiveText(
            title,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onboardingSub,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final product = widget.product;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Gallery thumbnails (using default assets for mock gallery)
    final galleryImages = [
      product.image,
      product.image.contains('shoe_nike_1') ? 'assets/images/shoe_nike_2.png' : 'assets/images/shoe_nike_1.png',
      product.image.contains('shoe_nike_3') ? 'assets/images/shoe_nike_2.png' : 'assets/images/shoe_nike_3.png',
    ];

    final angles = [
      {
        'title': 'Side',
        'transform': Matrix4.rotationY(3.14159),
      },
      {
        'title': 'Top',
        'transform': Matrix4.identity()..rotateZ(0.78),
      },
      {
        'title': 'Sole',
        'transform': Matrix4.identity()..rotateZ(1.57),
      },
      {
        'title': 'Heel',
        'transform': Matrix4.identity()..rotateZ(3.14159),
      },
      {
        'title': 'Quarter',
        'transform': Matrix4.identity()..rotateZ(-0.78),
      },
      {
        'title': 'Inner',
        'transform': Matrix4.rotationX(3.14159),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ── TOP BAR ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (Circle Avatar with Arrow)
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
                  // Center Text
                  ResponsiveText(
                    "Men's Shoes",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),
                  // Shopping Bag Button
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

            // ── MAIN SHOE DISPLAY AREA ───────────────────────────────────────
            SizedBox(
              height: size.height * 0.32,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 1. Slider Ring Image (Directly below shoe)
                  Positioned(
                    bottom: 10,
                    child: Image.asset(
                      'assets/images/slider_ring.png',
                      width: size.width * 0.85,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // 2. Hero Shoe Image (Clean 2D View with scale animation)
                  Positioned(
                    bottom: 42,
                    child: Hero(
                      tag: widget.heroTag,
                      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return Image.asset(
                              product.image,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            );
                          },
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _shoeScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _shoeScaleAnimation.value * _getShoeScaleFactor(product.image),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          galleryImages[_selectedGalleryIndex],
                          width: size.width * 0.70,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BOTTOM DETAIL CARD (White Card) ──────────────────────────────
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
                      // Scrollable Details Content
                      Positioned.fill(
                        bottom: 90 + bottomPadding, // Leave space for fixed bottom bar
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Title / description (staggered fade-in)
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
                                    if (product.isBestSeller) ...[
                                      const ResponsiveText(
                                        'BEST SELLER',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onboardingBtn,
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                    ResponsiveText(
                                      product.name,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onboardingTitle,
                                    ),
                                    const SizedBox(height: 6),
                                    ResponsiveText(
                                      '\$${(product.price).toStringAsFixed(2)}',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onboardingTitle,
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
                              const SizedBox(height: 20),

                              // 2. Gallery (staggered fade-in)
                              AnimatedBuilder(
                                animation: _galleryFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _galleryFadeAnimation.value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1.0 - _galleryFadeAnimation.value) * 12),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ResponsiveText(
                                      'Gallery',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onboardingTitle,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: List.generate(galleryImages.length, (index) {
                                        final isSelected = _selectedGalleryIndex == index;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedGalleryIndex = index;
                                            });
                                          },
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            margin: const EdgeInsets.only(right: 14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9F9F9),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected ? AppColors.onboardingBtn : Colors.transparent,
                                                width: 1.5,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: Image.asset(
                                              galleryImages[index],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 3. Sizes (staggered fade-in)
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
                                        ResponsiveText(
                                          'Size',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onboardingTitle,
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
                              const SizedBox(height: 24),

                              // 4. Different Angles (staggered fade-in)
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
                                    ResponsiveText(
                                      'Different Angles',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onboardingTitle,
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      children: [
                                        Row(
                                          children: List.generate(3, (index) {
                                            final angle = angles[index];
                                            final heroTag = 'angle_hero_${index}_$_selectedGalleryIndex';
                                            return Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: index == 2 ? 0 : 12),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showAnglePopUp(
                                                      context,
                                                      galleryImages[_selectedGalleryIndex],
                                                      angle['transform'] as Matrix4,
                                                      heroTag,
                                                    );
                                                  },
                                                  child: _buildAngleCard(
                                                    title: angle['title'] as String,
                                                    child: Hero(
                                                      tag: heroTag,
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: Transform(
                                                          alignment: Alignment.center,
                                                          transform: angle['transform'] as Matrix4,
                                                          child: Image.asset(
                                                            galleryImages[_selectedGalleryIndex],
                                                            fit: BoxFit.contain,
                                                            filterQuality: FilterQuality.high,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: List.generate(3, (index) {
                                            final actualIndex = index + 3;
                                            final angle = angles[actualIndex];
                                            final heroTag = 'angle_hero_${actualIndex}_$_selectedGalleryIndex';
                                            return Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: index == 2 ? 0 : 12),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showAnglePopUp(
                                                      context,
                                                      galleryImages[_selectedGalleryIndex],
                                                      angle['transform'] as Matrix4,
                                                      heroTag,
                                                    );
                                                  },
                                                  child: _buildAngleCard(
                                                    title: angle['title'] as String,
                                                    child: Hero(
                                                      tag: heroTag,
                                                      child: Material(
                                                        color: Colors.transparent,
                                                        child: Transform(
                                                          alignment: Alignment.center,
                                                          transform: angle['transform'] as Matrix4,
                                                          child: Image.asset(
                                                            galleryImages[_selectedGalleryIndex],
                                                            fit: BoxFit.contain,
                                                            filterQuality: FilterQuality.high,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fixed Bottom Price & Add to Cart Bar (Static & Fixed, never moves or animates)
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
                                    'Price',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onboardingSub,
                                  ),
                                  const SizedBox(height: 4),
                                  ResponsiveText(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onboardingTitle,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  CartController.to.addToCart(
                                    product,
                                    selectedSize: _selectedSize,
                                    selectedUnit: _selectedUnit,
                                  );
                                  Get.closeCurrentSnackbar();
                                  Get.snackbar(
                                    'Cart Updated',
                                    '${product.name} (Size $_selectedSize) added to cart!',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: AppColors.onboardingBtn,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
                                    duration: const Duration(milliseconds: 1800),
                                    mainButton: TextButton(
                                      onPressed: () => Get.to(() => const CartView()),
                                      child: const Text(
                                        'VIEW CART',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 167, // Exactly 167
                                  height: 54, // Exactly 54
                                  decoration: BoxDecoration(
                                    color: AppColors.onboardingBtn,
                                    borderRadius: BorderRadius.circular(27),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.onboardingBtn.withValues(alpha: 0.40),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: ResponsiveText(
                                      'Add to Cart',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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

  void _showAnglePopUp(BuildContext context, String imagePath, Matrix4 transform, String heroTag) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.close, color: AppColors.onboardingTitle, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Hero(
                    tag: heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: transform,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
