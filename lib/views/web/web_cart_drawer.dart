import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import 'web_colors.dart';
import 'web_product_image_helper.dart';

class WebCartDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onCheckout;

  const WebCartDrawer({
    super.key,
    required this.onClose,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final cart = CartController.to;
    final size = MediaQuery.of(context).size;
    final drawerWidth = size.width > 500 ? 460.0 : size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: drawerWidth,
          height: size.height,
          decoration: BoxDecoration(
            color: WebColors.surface,
            border: const Border(
              left: BorderSide(color: WebColors.border, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 40,
                offset: const Offset(-10, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: WebColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.bag_fill,
                          color: WebColors.gold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Obx(() => Text(
                              'BAG (${cart.itemCount})',
                              style: const TextStyle(
                                color: WebColors.textMain,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            )),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: WebColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: WebColors.border),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 16,
                              color: WebColors.textMain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Items List / Empty State ─────────────────────────
              Expanded(
                child: Obx(() {
                  final items = cart.items;

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                CupertinoIcons.bag,
                                size: 36,
                                color: WebColors.textDim,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Your Bag is Empty',
                              style: TextStyle(
                                color: WebColors.textMain,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Explore the catalog and add some kicks.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: WebColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: onClose,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WebColors.gold,
                                foregroundColor: const Color(0xFF090C10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'START SHOPPING',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final p = item.product;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: WebColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: WebColors.border),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: WebColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: WebProductImageHelper(
                                imagePath: p.image,
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: WebColors.textMain,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Size: EU ${item.selectedSize}',
                                    style: const TextStyle(
                                      color: WebColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${item.unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: WebColors.gold,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls & Remove
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () => cart.removeFromCart(item.id),
                                  child: const Icon(
                                    CupertinoIcons.trash,
                                    size: 16,
                                    color: WebColors.textDim,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildQtyBtn(
                                      icon: CupertinoIcons.minus,
                                      onTap: () => cart.decrementQuantity(item.id),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          color: WebColors.textMain,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    _buildQtyBtn(
                                      icon: CupertinoIcons.plus,
                                      onTap: () => cart.incrementQuantity(item.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),

              // ── Order Summary & Checkout CTA ─────────────────────
              Obx(() {
                if (cart.items.isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: WebColors.surfaceElevated,
                    border: const Border(top: BorderSide(color: WebColors.border)),
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(color: WebColors.textMuted, fontSize: 13),
                          ),
                          Text(
                            '\$${cart.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: WebColors.textMain,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      if (cart.hasDiscountApplied) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Discount Savings',
                              style: TextStyle(color: WebColors.emerald, fontSize: 13),
                            ),
                            Text(
                              '-\$${cart.totalDiscount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: WebColors.emerald,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Shipping
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimated Shipping',
                            style: TextStyle(color: WebColors.textMuted, fontSize: 13),
                          ),
                          Text(
                            '\$${cart.shippingCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: WebColors.textMain,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Divider(color: WebColors.border, height: 24),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: WebColors.textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '\$${cart.totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: WebColors.gold,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Checkout CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebColors.gold,
                            foregroundColor: const Color(0xFF090C10),
                            elevation: 8,
                            shadowColor: WebColors.gold.withOpacity(0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'PROCEED TO CHECKOUT',
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
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: WebColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: WebColors.border),
        ),
        child: Center(
          child: Icon(icon, size: 12, color: WebColors.textMain),
        ),
      ),
    );
  }
}
