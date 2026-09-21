import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product.dart';
import '../../utils/app_toast.dart';
import 'web_colors.dart';
import 'web_product_image_helper.dart';

class WebProductDetailModal extends StatefulWidget {
  final Product product;
  final VoidCallback onClose;
  final VoidCallback onBuyNow;

  const WebProductDetailModal({
    super.key,
    required this.product,
    required this.onClose,
    required this.onBuyNow,
  });

  @override
  State<WebProductDetailModal> createState() => _WebProductDetailModalState();
}

class _WebProductDetailModalState extends State<WebProductDetailModal> {
  late String _selectedImage;
  late int _selectedSize;
  int _selectedColorIndex = 0;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.product.image;
    _selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes.first : 40;
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  void _handleAddToCart() async {
    if (widget.product.isOutOfStock) {
      AppToast.showWarning(
        title: 'Out of Stock',
        message: 'This sneaker is currently unavailable.',
      );
      return;
    }

    setState(() => _isAdding = true);
    CartController.to.addToCart(
      widget.product,
      selectedSize: _selectedSize,
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isAdding = false);
      AppToast.showSuccess(
        title: 'Added to Bag',
        message: '${widget.product.name} (EU $_selectedSize) is now in your bag.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 850;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isDesktop ? 940 : size.width * 0.94,
          constraints: BoxConstraints(
            maxWidth: 980,
            maxHeight: size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: WebColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: WebColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.65),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: WebColors.gold.withOpacity(0.12),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 36 : 24),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Interactive Gallery
                          Expanded(flex: 5, child: _buildGallerySection(p)),
                          const SizedBox(width: 36),
                          // Right: Info, Sizes, Actions
                          Expanded(flex: 5, child: _buildDetailsSection(p)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGallerySection(p),
                          const SizedBox(height: 24),
                          _buildDetailsSection(p),
                        ],
                      ),
              ),

              // Close Button (Top Right)
              Positioned(
                top: 20,
                right: 20,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: WebColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: WebColors.border),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 18,
                          color: WebColors.textMain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(Product p) {
    final allImages = <String>[];
    if (p.image.isNotEmpty) allImages.add(p.image);
    for (var img in p.galleryImages) {
      if (img.isNotEmpty && !allImages.contains(img)) {
        allImages.add(img);
      }
    }

    return Column(
      children: [
        // Big Main Image Container
        Container(
          height: 360,
          width: double.infinity,
          decoration: BoxDecoration(
            color: WebColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: WebColors.border),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: WebProductImageHelper(
                key: ValueKey(_selectedImage),
                imagePath: _selectedImage,
                height: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Thumbnails row
        if (allImages.length > 1)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final img = allImages[index];
                final isSelected = _selectedImage == img;

                return GestureDetector(
                  onTap: () => setState(() => _selectedImage = img),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: WebColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? WebColors.gold : WebColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: WebProductImageHelper(
                      imagePath: img,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(Product p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category / Brand & Status Pill
        Row(
          children: [
            Text(
              p.category.toUpperCase(),
              style: const TextStyle(
                color: WebColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: p.isInStock
                    ? WebColors.emerald.withOpacity(0.15)
                    : WebColors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: p.isInStock ? WebColors.emerald : WebColors.red,
                ),
              ),
              child: Text(
                p.isInStock ? 'IN STOCK' : 'OUT OF STOCK',
                style: TextStyle(
                  color: p.isInStock ? WebColors.emerald : WebColors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Shoe Title
        Text(
          p.name,
          style: const TextStyle(
            color: WebColors.textMain,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // Rating & Reviews
        Row(
          children: [
            ...List.generate(
              5,
              (index) => const Icon(
                Icons.star_rounded,
                size: 20,
                color: WebColors.gold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${p.rating.toStringAsFixed(1)} (128 Reviews)',
              style: const TextStyle(
                color: WebColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${p.finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: WebColors.textMain,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (p.hasDiscount && p.price > p.finalPrice) ...[
              const SizedBox(width: 14),
              Text(
                '\$${p.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: WebColors.textDim,
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WebColors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${p.discountPercentage.toInt()}% OFF',
                  style: const TextStyle(
                    color: WebColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        // Description
        if (p.description.isNotEmpty) ...[
          const Text(
            'DESCRIPTION',
            style: TextStyle(
              color: WebColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.description,
            style: const TextStyle(
              color: WebColors.textMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Sizes Selector
        if (p.sizes.isNotEmpty) ...[
          const Text(
            'SELECT SIZE (EU)',
            style: TextStyle(
              color: WebColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: p.sizes.map((sz) {
              final isSelected = _selectedSize == sz;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSize = sz),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? WebColors.gold
                          : WebColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? WebColors.gold : WebColors.border,
                      ),
                    ),
                    child: Text(
                      '$sz',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF090C10)
                            : WebColors.textMain,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Colors Selector
        if (p.colors.isNotEmpty) ...[
          const Text(
            'COLOR PALETTE',
            style: TextStyle(
              color: WebColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            children: List.generate(p.colors.length, (idx) {
              final color = _parseHexColor(p.colors[idx]);
              final isSelected = _selectedColorIndex == idx;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? WebColors.gold : Colors.white24,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: WebColors.gold.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
        ],

        // Action Buttons Row (Add to Bag + Buy Now)
        Row(
          children: [
            Expanded(
              child: ElevatedButton.styleFrom(
                backgroundColor: WebColors.surfaceElevated,
                foregroundColor: WebColors.textMain,
                side: const BorderSide(color: WebColors.gold, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ).build(
                context,
                onPressed: p.isOutOfStock || _isAdding ? null : _handleAddToCart,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isAdding)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(WebColors.gold),
                        ),
                      )
                    else ...[
                      const Icon(CupertinoIcons.bag_badge_plus, size: 20, color: WebColors.gold),
                      const SizedBox(width: 10),
                      const Text(
                        'ADD TO BAG',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: ElevatedButton(
                onPressed: p.isOutOfStock
                    ? null
                    : () {
                        CartController.to.addToCart(p, selectedSize: _selectedSize);
                        widget.onBuyNow();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WebColors.gold,
                  foregroundColor: const Color(0xFF090C10),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 10,
                  shadowColor: WebColors.gold.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BUY NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(CupertinoIcons.arrow_right, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension on ButtonStyle {
  Widget build(BuildContext context, {required VoidCallback? onPressed, required Widget child}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: this,
      child: child,
    );
  }
}
