import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/cart_item.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/responsive_text.dart';
import '../checkout/checkout_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
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
    final cartController = CartController.to;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.onboardingBg, // #F9F9F9
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── TOP BAR ────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Button (Functional both for Route navigation & Bottom tab navigation)
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().changeIndex(0);
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

                  // Title: My Cart
                  ResponsiveText(
                    'My Cart',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),

                  // Spacer to balance header row
                  const SizedBox(width: 44),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── CART ITEMS LIST (StreamBuilder Reactive Stream) ────────────────
            Expanded(
              child: StreamBuilder<List<CartItem>>(
                stream: cartController.cartStream,
                initialData: cartController.items,
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Clean Vector Cart Illustration (No surrounding box container)
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: Image.asset(
                                  AppImages.emptyCart,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ResponsiveText(
                                'Your Cart is Empty',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onboardingTitle,
                              ),
                              const SizedBox(height: 8),
                              const ResponsiveText(
                                'Explore our collection and add your favorite shoes to the cart.',
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
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: 8,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildCartItemCard(context, item, cartController, index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── BOTTOM SUMMARY CARD (Subtotal, Shipping, Dashed Divider, Total, Checkout)
            StreamBuilder<List<CartItem>>(
              stream: cartController.cartStream,
              initialData: cartController.items,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (items.isEmpty || MediaQuery.of(context).viewInsets.bottom > 0) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtotal Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ResponsiveText(
                            'Subtotal',
                            fontSize: 14,
                            color: AppColors.onboardingSub,
                            fontWeight: FontWeight.w500,
                          ),
                          ResponsiveText(
                            '\$${cartController.subtotal.toStringAsFixed(2)}',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onboardingTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Shipping Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ResponsiveText(
                            'Shopping',
                            fontSize: 14,
                            color: AppColors.onboardingSub,
                            fontWeight: FontWeight.w500,
                          ),
                          ResponsiveText(
                            '\$${cartController.shippingCost.toStringAsFixed(2)}',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onboardingTitle,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Dashed Divider
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final dashWidth = 5.0;
                          final dashSpace = 4.0;
                          final dashCount =
                              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(dashCount, (_) {
                              return SizedBox(
                                width: dashWidth,
                                height: 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Total Cost Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ResponsiveText(
                            'Total Cost',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onboardingTitle,
                          ),
                          ResponsiveText(
                            '\$${cartController.totalCost.toStringAsFixed(2)}',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onboardingTitle,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Get.to(() => const CheckoutView()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9EE1), // Blue primary
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const ResponsiveText(
                            'Checkout',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Cart Item Row Card (Matching Screenshot 2) ──
  Widget _buildCartItemCard(
    BuildContext context,
    CartItem item,
    CartController cartController,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Left Shoe Thumbnail (Light grey container)
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(
                item.product.image,
                width: 70,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // 2. Middle Column: Product Name, Price, Quantity (- 1 +)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  item.product.name,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
                const SizedBox(height: 4),
                ResponsiveText(
                  '\$${item.product.price.toStringAsFixed(2)}',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onboardingSub,
                ),
                const SizedBox(height: 8),

                // Quantity Control Row (- Qty +)
                Row(
                  children: [
                    // Minus Button
                    GestureDetector(
                      onTap: () => cartController.decrementQuantity(item.id),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.remove,
                            size: 14,
                            color: AppColors.onboardingSub,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ResponsiveText(
                        '${item.quantity}',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingTitle,
                      ),
                    ),

                    // Plus Button (Blue Circle)
                    GestureDetector(
                      onTap: () => cartController.incrementQuantity(item.id),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B9EE1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Right Column: Selected Size Label ABOVE Delete Trash Icon
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User Selected Size Label (displayed directly above delete icon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ResponsiveText(
                  '${item.selectedSize}',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
              ),

              const SizedBox(height: 28),

              // Trash Delete Icon
              GestureDetector(
                onTap: () => cartController.removeFromCart(item.id),
                child: Image.asset(
                  AppImages.deleteTrash,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
