import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/custom_button.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController =
      TextEditingController(text: 'rumenhussen@gmail.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+92 300 1234567');
  final TextEditingController _addressController =
      TextEditingController(text: 'Ashiyana Plaza, DI Khan, KPK - Pakistan');

  String _selectedPaymentMethod = 'Paypal Card';
  final List<Map<String, String>> _paymentMethods = [
    {
      'title': 'Paypal Card',
      'subtitle': '**** **** 0696 4629',
    },
    {
      'title': 'Visa Credit Card',
      'subtitle': '**** **** 4821 9012',
    },
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when order arrives',
    },
  ];

  bool _isEditingEmail = false;
  bool _isEditingPhone = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, CartController cartController) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        return const PaymentSuccessModal();
      },
    );
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
                  // Back Arrow Button
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

                  // Title: Checkout
                  ResponsiveText(
                    'Checkout',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),

                  // Spacer to balance header row
                  const SizedBox(width: 44),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── MAIN FORM BODY ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Contact Information Card Container ──
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            'Contact Information',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onboardingTitle,
                          ),
                          const SizedBox(height: 16),

                          // Email Row
                          Row(
                            children: [
                              Image.asset(
                                AppImages.checkoutEmail,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isEditingEmail)
                                      TextField(
                                        controller: _emailController,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onboardingTitle,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                      )
                                    else
                                      ResponsiveText(
                                        _emailController.text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onboardingTitle,
                                      ),
                                    const SizedBox(height: 2),
                                    ResponsiveText(
                                      'Email',
                                      fontSize: 12,
                                      color: AppColors.onboardingSub,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditingEmail = !_isEditingEmail;
                                  });
                                },
                                child: Image.asset(
                                  AppImages.checkoutEdit,
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Phone Row (Pakistan Phone Input, e.g. +92 ...)
                          Row(
                            children: [
                              Image.asset(
                                AppImages.checkoutPhone,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isEditingPhone)
                                      TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onboardingTitle,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                      )
                                    else
                                      ResponsiveText(
                                        _phoneController.text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onboardingTitle,
                                      ),
                                    const SizedBox(height: 2),
                                    ResponsiveText(
                                      'Phone',
                                      fontSize: 12,
                                      color: AppColors.onboardingSub,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditingPhone = !_isEditingPhone;
                                  });
                                },
                                child: Image.asset(
                                  AppImages.checkoutEdit,
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 2. Address Card Section ──
                    ResponsiveText(
                      'Address',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 10),

                    // Address Text Card Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                          Expanded(
                            child: ResponsiveText(
                              _addressController.text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onboardingTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.onboardingSub,
                            size: 22,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Light Blue Map Visual Container with Pin Marker
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3FD),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4E6F8),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Map background pattern simulation
                          CustomPaint(
                            size: const Size(double.infinity, 120),
                            painter: MapPatternPainter(),
                          ),
                          // Location Pin Badge Icon
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B9EE1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5B9EE1).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 3. Payment Method Section ──
                    ResponsiveText(
                      'Payment Method',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 10),

                    // Payment Method Dropdown Container
                    Container(
                      padding: const EdgeInsets.all(14),
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
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (context) {
                          return _paymentMethods.map((method) {
                            return PopupMenuItem<String>(
                              value: method['title'],
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.payment_rounded,
                                    color: Color(0xFF5B9EE1),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        method['title']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      Text(
                                        method['subtitle']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Row(
                          children: [
                            // Left Payment Icon Badge
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.payment_rounded,
                                  color: Color(0xFF003087),
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ResponsiveText(
                                    _selectedPaymentMethod,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onboardingTitle,
                                  ),
                                  const SizedBox(height: 2),
                                  ResponsiveText(
                                    _paymentMethods.firstWhere(
                                      (m) => m['title'] == _selectedPaymentMethod,
                                      orElse: () => _paymentMethods[0],
                                    )['subtitle']!,
                                    fontSize: 12,
                                    color: AppColors.onboardingSub,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.onboardingSub,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ── 4. BOTTOM SUMMARY CARD (Subtotal, Shipping, Total, Payment Button) ──
            StreamBuilder<List<dynamic>>(
              stream: cartController.cartStream,
              initialData: cartController.items,
              builder: (context, snapshot) {
                if (MediaQuery.of(context).viewInsets.bottom > 0) {
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
                          const dashWidth = 5.0;
                          const dashSpace = 4.0;
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

                      // Simple Modern Payment Action Button
                      PrimaryButton(
                        title: 'Payment',
                        onPressed: () => _showSuccessDialog(context, cartController),
                        borderRadius: 30,
                        height: 56,
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
}

// ── PAYMENT SUCCESS ANIMATED MODAL ─────────────────────────────────────────────
class PaymentSuccessModal extends StatefulWidget {
  const PaymentSuccessModal({super.key});

  @override
  State<PaymentSuccessModal> createState() => _PaymentSuccessModalState();
}

class _PaymentSuccessModalState extends State<PaymentSuccessModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.15), weight: 65),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 35),
    ]).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated Confetti Celebration Image Container ──
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F3FD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          AppImages.confettiPopper,
                          width: 95,
                          height: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Title: Your Payment Is Successful
            const ResponsiveText(
              'Your Payment Is\nSuccessful',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingTitle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Back To Shopping Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 1. Clear cart
                  CartController.to.clearCart();
                  // 2. Close dialog & navigate back to Home Screen
                  Navigator.of(context).pop();
                  Get.back(); // Close CheckoutView
                  if (Get.isRegistered<HomeController>()) {
                    Get.find<HomeController>().changeIndex(0);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9EE1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const ResponsiveText(
                  'Back To Shopping',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painter to simulate map road background pattern ───────────────────
class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E6F8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(size.width * 0.3, size.height * 0.1, size.width * 0.6,
          size.height * 0.7, size.width, size.height * 0.4);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(size.width * 0.4, size.height * 0.5, size.width * 0.7,
          size.height * 0.2, size.width * 0.8, size.height);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── SLIDE TO PAY BUTTON WIDGET ───────────────────────────────────────────────
class SlideToPayButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  const SlideToPayButton({super.key, required this.onSwipeComplete});

  @override
  State<SlideToPayButton> createState() => _SlideToPayButtonState();
}

class _SlideToPayButtonState extends State<SlideToPayButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isCompleted = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_resetController);
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _resetDrag() {
    _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragValue = _resetAnimation.value;
        });
      });
    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const knobSize = 48.0;
        const padding = 4.0;
        final maxDrag = totalWidth - knobSize - (padding * 2);

        return Container(
          width: totalWidth,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF5B9EE1),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B9EE1).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track text & icon
              Center(
                child: Opacity(
                  opacity: (1.0 - (_dragValue / (maxDrag == 0 ? 1 : maxDrag))).clamp(0.2, 1.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Swipe to Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // Slidable Knob Button
              Positioned(
                left: padding + _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragValue += details.delta.dx;
                      _dragValue = _dragValue.clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isCompleted) return;
                    if (_dragValue >= maxDrag * 0.75) {
                      setState(() {
                        _dragValue = maxDrag;
                        _isCompleted = true;
                      });
                      widget.onSwipeComplete();
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) {
                          setState(() {
                            _dragValue = 0.0;
                            _isCompleted = false;
                          });
                        }
                      });
                    } else {
                      _resetDrag();
                    }
                  },
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF5B9EE1),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
