import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product.dart';
import '../../utils/app_toast.dart';
import 'web_colors.dart';
import 'web_product_image_helper.dart';

class WebProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const WebProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<WebProductCard> createState() => _WebProductCardState();
}

class _WebProductCardState extends State<WebProductCard> {
  bool _isHovered = false;
  bool _isAdding = false;

  void _handleQuickAdd() async {
    if (widget.product.isOutOfStock) {
      AppToast.showWarning(
        title: 'Out of Stock',
        message: 'This item is currently out of stock.',
      );
      return;
    }

    setState(() => _isAdding = true);
    final size = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : 40;
    CartController.to.addToCart(widget.product, selectedSize: size);

    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      setState(() => _isAdding = false);
      AppToast.showSuccess(
        title: 'Added to Bag',
        message: '${widget.product.name} (EU $size) added to bag.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            color: WebColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? WebColors.gold.withOpacity(0.5)
                  : WebColors.border,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: WebColors.gold.withOpacity(0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Image Container with Badges ───────────────────
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: WebColors.surfaceElevated,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          WebColors.surfaceElevated,
                          WebColors.surface,
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 320),
                          scale: _isHovered ? 1.08 : 1.0,
                          curve: Curves.easeOutCubic,
                          child: Hero(
                            tag: 'web_prod_${p.id}',
                            child: WebProductImageHelper(
                              imagePath: p.image,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Status / Discount Badges (Top Left)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.hasDiscount && p.discountPercentage > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3366), Color(0xFFFF5E3A)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF3366).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '-${p.discountPercentage.toInt()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (p.isNewArrival)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: WebColors.cyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: WebColors.cyan, width: 1),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: WebColors.cyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        else if (p.isBestSeller)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: WebColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: WebColors.gold, width: 1),
                            ),
                            child: const Text(
                              'BESTSELLER',
                              style: TextStyle(
                                color: WebColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Favorite Heart Button (Top Right)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Obx(() {
                      final isFav = p.isFavorite.value;
                      return GestureDetector(
                        onTap: () => p.isFavorite.value = !p.isFavorite.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isFav
                                ? const Color(0xFFFF3366).withOpacity(0.2)
                                : WebColors.surface.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFav
                                  ? const Color(0xFFFF3366)
                                  : WebColors.borderSubtle,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              size: 18,
                              color: isFav ? const Color(0xFFFF3366) : WebColors.textMuted,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Out of Stock Overlay
                  if (p.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: const Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // ── Product Details (Category, Title, Rating, Price) ──
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand / Category & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WebColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: WebColors.gold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: WebColors.textMain,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WebColors.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Price & Add to Bag Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.hasDiscount && p.price > p.finalPrice) ...[
                              Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: WebColors.textDim,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            Text(
                              '\$${p.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: WebColors.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        // Quick Add Button
                        GestureDetector(
                          onTap: _isAdding ? null : _handleQuickAdd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: p.isOutOfStock
                                  ? null
                                  : WebColors.goldGradient,
                              color: p.isOutOfStock
                                  ? WebColors.surfaceElevated
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: p.isOutOfStock
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: WebColors.gold.withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: _isAdding
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF090C10),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      CupertinoIcons.bag_badge_plus,
                                      size: 20,
                                      color: p.isOutOfStock
                                          ? WebColors.textDim
                                          : const Color(0xFF090C10),
                                    ),
                            ),
                          ),
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
    );
  }
}
