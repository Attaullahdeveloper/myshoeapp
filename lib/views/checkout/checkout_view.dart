import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_images.dart';
import '../../widgets/app_animated_dropdown.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/auth_required_bottom_sheet.dart';
import '../../widgets/responsive_text.dart';
import '../../utils/app_toast.dart';
import '../orders/my_orders_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // Theme & Colors
  static const Color primaryLightBlue = Color(0xFF4B96E6);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color subtleBorderColor = Color(0xFFE2E8F0);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Contact Information Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Address Controllers
  final TextEditingController _fullAddressController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();

  // City selection
  String? _selectedCity = 'Karachi';
  final List<String> _cities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Gujranwala',
    'Hyderabad',
    'Abbottabad',
    'Other City',
  ];

  // Payment & validation state
  String _selectedPaymentMethod = 'Cash on Delivery'; // 'Cash on Delivery' or 'Card'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        _emailController.text = currentUser.email!;
      }
      final userMeta = currentUser.userMetadata;
      if (userMeta != null) {
        if (userMeta['full_name'] != null) {
          final parts = userMeta['full_name'].toString().split(' ');
          _firstNameController.text = parts.isNotEmpty ? parts.first : '';
          _lastNameController.text =
              parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }
        if (userMeta['phone'] != null) {
          _phoneController.text = userMeta['phone'].toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullAddressController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  // ── SUBMIT ORDER TO SUPABASE ────────────────────────────────────────────────
  Future<void> _submitOrder({
    required double totalCost,
    required bool hasDiscountApplied,
  }) async {
    // 1. FIRST: Trigger and Check Form Validation & Field Errors
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final email = _emailController.text.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    final phone = _phoneController.text.trim();

    if (!isFormValid ||
        _firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        email.isEmpty ||
        !emailRegex.hasMatch(email) ||
        phone.isEmpty ||
        !phone.startsWith('03') ||
        phone.length != 11 ||
        !RegExp(r'^[0-9]+$').hasMatch(phone) ||
        _fullAddressController.text.trim().isEmpty) {
      if (_firstNameController.text.trim().isEmpty) {
        AppToast.showError(
          context: context,
          title: 'Missing First Name',
          message: 'Please enter your first name before proceeding.',
        );
      } else if (_lastNameController.text.trim().isEmpty) {
        AppToast.showError(
          context: context,
          title: 'Missing Last Name',
          message: 'Please enter your last name before proceeding.',
        );
      } else if (email.isEmpty || !emailRegex.hasMatch(email)) {
        AppToast.showError(
          context: context,
          title: 'Invalid Email Address',
          message: 'Please enter a valid email address (e.g. user@gmail.com).',
        );
      } else if (phone.isEmpty) {
        AppToast.showError(
          context: context,
          title: 'Missing Phone Number',
          message: 'Please enter your contact phone number.',
        );
      } else if (!phone.startsWith('03')) {
        AppToast.showError(
          context: context,
          title: 'Invalid Phone Number',
          message: 'Phone number must start with 03 (e.g. 03001234567).',
        );
      } else if (phone.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
        AppToast.showError(
          context: context,
          title: 'Invalid Phone Number',
          message: 'Phone number must be exactly 11 digits.',
        );
      } else if (_fullAddressController.text.trim().isEmpty) {
        AppToast.showError(
          context: context,
          title: 'Missing Delivery Address',
          message: 'Please enter your delivery street and house address.',
        );
      } else {
        AppToast.showError(
          context: context,
          title: 'Incomplete Fields',
          message: 'Please fill in all mandatory fields correctly.',
        );
      }
      return;
    }

    // 2. SECOND: Auth Gate Verification (only after fields are valid)
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      final enteredEmail = _emailController.text.trim();
      AuthRequiredBottomSheet.show(
        context,
        orderTotal: totalCost,
        initialEmail: enteredEmail,
        onAuthSuccess: () {
          _submitOrder(
            totalCost: totalCost,
            hasDiscountApplied: hasDiscountApplied,
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // ── STEP 1 & 2: Query product availability before creating order ──
      final List<dynamic> productIdsToCheck = [];
      if (Get.isRegistered<CartController>() &&
          CartController.to.items.isNotEmpty) {
        for (final item in CartController.to.items) {
          productIdsToCheck.add(item.product.id);
        }
      }

      for (final rawId in productIdsToCheck) {
        Map<String, dynamic>? prodData;
        final pNum = int.tryParse(rawId.toString());
        try {
          if (pNum != null) {
            try {
              prodData = await supabase
                  .from('products')
                  .select('availability_status, is_available')
                  .eq('prod_id', pNum)
                  .maybeSingle();
            } catch (_) {}
          }
          if (prodData == null) {
            prodData = await supabase
                .from('products')
                .select('availability_status, is_available')
                .eq('id', rawId.toString())
                .maybeSingle();
          }
        } catch (e) {
          debugPrint('⚠️ Error checking product availability: $e');
        }

        if (prodData != null) {
          final status = prodData['availability_status']?.toString().toLowerCase();
          final isAvail = prodData['is_available'];
          if (status == 'out_of_stock' || isAvail == false) {
            setState(() {
              _isLoading = false;
            });
            AppToast.showError(
              context: context,
              title: 'Item Unavailable',
              message: 'Sorry, this shoe is already ordered/out of stock!',
            );
            return;
          }
        }
      }

      // Format: ORD-${DateTime.now().millisecondsSinceEpoch}
      final String generatedOrderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch}';

      final String fullLocation =
          '${_fullAddressController.text.trim()}, ${_selectedCity ?? ""}, ${_streetController.text.trim()} ${_houseController.text.trim()} - Pakistan'
              .trim();

      final addressMap = {
        'location': fullLocation.isNotEmpty
            ? fullLocation
            : 'Ashiyana Plaza, DI Khan, KPK - Pakistan',
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'full_address': _fullAddressController.text.trim(),
        'city': _selectedCity ?? '',
        'street': _streetController.text.trim(),
        'house': _houseController.text.trim(),
      };

      // Build order rows for all items in the cart
      final List<Map<String, dynamic>> orderRows = [];

      if (Get.isRegistered<CartController>() &&
          CartController.to.items.isNotEmpty) {
        final cartItems = CartController.to.items;
        for (int i = 0; i < cartItems.length; i++) {
          final item = cartItems[i];
          final pId = int.tryParse(item.product.id);
          final cId = item.product.companyId != null
              ? int.tryParse(item.product.companyId!)
              : null;
          final String itemOrderId = cartItems.length > 1
              ? '$generatedOrderId-${i + 1}'
              : generatedOrderId;

          final itemAddressMap = {
            ...addressMap,
            'quantity': item.quantity,
            'selected_size': item.selectedSize,
            'selected_unit': item.selectedUnit,
            'product_name': item.product.name,
            'product_image': item.product.image,
            'product_price': item.product.finalPrice,
            'company_id': item.product.companyId,
          };

          final Map<String, dynamic> row = {
            'order_id': itemOrderId,
            'user_id': user.id,
            if (pId != null) 'prod_id': pId,
            if (cId != null) 'comp_id': cId,
            'price': item.product.finalPrice * item.quantity,
            'discount_applied': item.product.hasDiscount,
            'payment_status': false,
            'phone_no': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'address': itemAddressMap,
            'status': 'created',
          };
          orderRows.add(row);
        }
      } else {
        // Fallback for single direct order
        int prodId = 1;
        int compId = 1;
        final Map<String, dynamic> orderPayload = {
          'order_id': generatedOrderId,
          'user_id': user.id,
          'prod_id': prodId,
          'comp_id': compId,
          'price': totalCost,
          'discount_applied': hasDiscountApplied,
          'payment_status': false,
          'phone_no': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'address': addressMap,
          'status': 'created',
        };
        orderRows.add(orderPayload);
      }

      debugPrint(
          '📦 Submitting ${orderRows.length} Order(s) to Supabase: $orderRows');

      // Attempt insert with top-level first_name & last_name or fallback to address map
      try {
        await supabase.from('orders').insert(
              orderRows
                  .map((r) => {
                        ...r,
                        'first_name': _firstNameController.text.trim(),
                        'last_name': _lastNameController.text.trim(),
                      })
                  .toList(),
            );
      } catch (insertErr) {
        debugPrint(
            '⚠️ Batch insert with top-level name failed ($insertErr), retrying standard insert...');
        await supabase.from('orders').insert(orderRows);
      }

      // Immediately update product status in products table to 'out_of_stock'
      for (final row in orderRows) {
        final pId = row['prod_id'] ?? row['product_id'];
        if (pId != null) {
          try {
            final pNum = int.tryParse(pId.toString());
            if (pNum != null) {
              await supabase
                  .from('products')
                  .update({
                    'availability_status': 'out_of_stock',
                    'is_available': false,
                  })
                  .eq('prod_id', pNum);
            } else {
              await supabase
                  .from('products')
                  .update({
                    'availability_status': 'out_of_stock',
                    'is_available': false,
                  })
                  .eq('id', pId.toString());
            }
          } catch (e) {
            debugPrint('⚠️ Note updating product to out_of_stock: $e');
            try {
              await supabase
                  .from('products')
                  .update({'availability_status': 'out_of_stock'})
                  .eq('id', pId);
            } catch (_) {}
          }
        }
      }

      // Trigger HomeController to update UI immediately
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshAllSections();
      }

      setState(() {
        _isLoading = false;
      });

      // Clear cart
      if (Get.isRegistered<CartController>()) {
        CartController.to.clearCart();
      }

      // Success Delightful Toast
      AppToast.showSuccess(
        context: context,
        title: 'Order Placed Successfully',
        message: 'Order placed successfully!',
      );

      // Show Payment Success Modal
      if (mounted) {
        _showPaymentSuccessDialog(
          context,
          orderId: generatedOrderId,
          totalCost: totalCost,
          city: _selectedCity ?? 'Pakistan',
          paymentMethod: _selectedPaymentMethod,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('❌ Order Submission Error: $e');

      AppToast.showError(
        title: 'Order Placement Error',
        message: 'Failed to save order: ${e.toString().split('\n').first}',
      );
    }
  }

  void _showPaymentSuccessDialog(
    BuildContext context, {
    required String orderId,
    required double totalCost,
    required String city,
    required String paymentMethod,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogContext) {
        return PaymentSuccessModal(
          orderId: orderId,
          totalCost: totalCost,
          city: city,
          paymentMethod: paymentMethod,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = 125.00;
    double shipping = 15.00;
    double discount = 0.00;
    bool hasDiscount = false;
    double discountPercentage = 0.0;

    if (Get.isRegistered<CartController>()) {
      final cartController = CartController.to;
      if (cartController.items.isNotEmpty) {
        subtotal = cartController.subtotal;
        discount = cartController.totalDiscount;
        hasDiscount = cartController.hasDiscountApplied;
        shipping = cartController.shippingCost;

        // Extract discount % for banner if available
        final discountedItems = cartController.items.where((i) => i.hasDiscount);
        if (discountedItems.isNotEmpty) {
          discountPercentage = discountedItems.first.product.discountPercentage;
          if (discountPercentage == 0 && subtotal > 0) {
            discountPercentage = (discount / subtotal) * 100;
          }
        }
      }
    }

    final double totalCost =
        (subtotal - discount + shipping).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. TOP APP BAR ──
            _buildAppBar(context),

            // ── MAIN BODY SCROLLABLE ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2. SHOE DETAIL / ORDER PREVIEW ──
                      _buildSectionHeader(
                        title: 'Shoe Details & Summary',
                        subtitle: 'Review the items in your order',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildShoeDetailPreviewList(),

                      const SizedBox(height: 20),

                      // ── 3. SHOE DISCOUNT STATUS ──
                      _buildSectionHeader(
                        title: 'Shoe Discount Status',
                        subtitle: 'Active discounts on selected items',
                        icon: Icons.local_offer_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildShoeDiscountCard(
                        hasDiscount: hasDiscount,
                        discountAmount: discount,
                        discountPercentage: discountPercentage,
                      ),

                      const SizedBox(height: 20),

                      // ── 4. CUSTOMER INFORMATION ──
                      _buildSectionHeader(
                        title: 'Customer Information',
                        subtitle: 'Personal details for order contact & updates',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      _buildCustomerInfoCard(),

                      const SizedBox(height: 20),

                      // ── 5. DELIVERY ADDRESS ──
                      _buildSectionHeader(
                        title: 'Delivery Address',
                        subtitle: 'Where should we deliver your shoes?',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildDeliveryAddressCard(),

                      const SizedBox(height: 20),

                      // ── 6. PAYMENT METHOD ──
                      _buildSectionHeader(
                        title: 'Payment Method',
                        subtitle: 'Select how you want to pay',
                        icon: Icons.payment_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildPaymentMethodSelector(),

                      const SizedBox(height: 20),

                      // ── 7. PRICE BREAKDOWN SUMMARY ──
                      _buildSectionHeader(
                        title: 'Price Breakdown',
                        subtitle: 'Detailed total cost calculated',
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildPriceBreakdownCard(
                        subtotal: subtotal,
                        shipping: shipping,
                        discount: discount,
                        totalCost: totalCost,
                        hasDiscount: hasDiscount,
                        discountPercentage: discountPercentage,
                      ),

                      const SizedBox(height: 26),

                      // ── 8. PLACE ORDER BUTTON ──
                      _buildPlaceOrderButton(
                        totalCost: totalCost,
                        hasDiscountApplied: hasDiscount,
                      ),

                      const SizedBox(height: 30),
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

  // ── 1. APP BAR WIDGET ───────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subtleBorderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textDark,
                  size: 18,
                ),
              ),
            ),
          ),
          const ResponsiveText(
            'Checkout',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: primaryLightBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryLightBlue, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText(
              title,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
            ResponsiveText(
              subtitle,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: textMuted,
            ),
          ],
        ),
      ],
    );
  }

  // ── 2. SHOE DETAIL / ORDER PREVIEW LIST ─────────────────────────────────────
  Widget _buildShoeDetailPreviewList() {
    if (Get.isRegistered<CartController>()) {
      final cart = CartController.to;
      if (cart.items.isNotEmpty) {
        return Column(
          children: cart.items.map((item) {
            final bool itemHasDiscount = item.hasDiscount;
            final double itemDiscPct = item.product.discountPercentage > 0
                ? item.product.discountPercentage
                : (item.totalDiscount / (item.originalPrice > 0 ? item.originalPrice : 1)) * 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: itemHasDiscount
                      ? successGreen.withValues(alpha: 0.3)
                      : subtleBorderColor,
                  width: itemHasDiscount ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Shoe Image Thumbnail
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildShoeThumbnail(item.product.image),
                  ),
                  const SizedBox(width: 14),
                  // Shoe Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          item.product.name,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        ResponsiveText(
                          item.product.category,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryLightBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ResponsiveText(
                                '${item.selectedUnit} ${item.selectedSize}',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryLightBlue,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ResponsiveText(
                                'Qty: ${item.quantity}',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            if (itemHasDiscount) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: successGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ResponsiveText(
                                  '${itemDiscPct.toStringAsFixed(0)}% OFF',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: successGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Item Price (Discounted + Strikethrough original if discount exists)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ResponsiveText(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: itemHasDiscount ? successGreen : textDark,
                      ),
                      if (itemHasDiscount) ...[
                        const SizedBox(height: 2),
                        Text(
                          '\$${item.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }
    }

    // Default Single Shoe Preview Fallback
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtleBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Image.asset(
                AppImages.boot,
                width: 54,
                height: 54,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.roller_skating,
                  color: primaryLightBlue,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Nike Air Max 270',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                ResponsiveText(
                  'Men’s Running Shoes',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    _Badge(label: 'EU 42', isPrimary: true),
                    SizedBox(width: 8),
                    _Badge(label: 'Qty: 1', isPrimary: false),
                  ],
                ),
              ],
            ),
          ),
          const ResponsiveText(
            '\$125.00',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ],
      ),
    );
  }

  Widget _buildShoeThumbnail(String image) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerImageLoader(
            width: 70,
            height: 70,
            borderRadius: 12,
          );
        },
        errorBuilder: (_, __, ___) => Image.asset(AppImages.boot, fit: BoxFit.contain),
      );
    }
    return Image.asset(
      image.isNotEmpty ? image : AppImages.boot,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.shopping_bag_outlined,
        color: primaryLightBlue,
        size: 30,
      ),
    );
  }

  // ── 3. SHOE DISCOUNT STATUS CARD ───────────────────────────────────────────
  Widget _buildShoeDiscountCard({
    required bool hasDiscount,
    required double discountAmount,
    required double discountPercentage,
  }) {
    if (hasDiscount) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: successGreen.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: successGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: successGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ResponsiveText(
                        'Discount Applied',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF166534),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: successGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ResponsiveText(
                          '${discountPercentage.toStringAsFixed(0)}% OFF',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ResponsiveText(
                    'You are saving \$${discountAmount.toStringAsFixed(2)} on this product!',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF15803D),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // No Discount Available on this shoe
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtleBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ResponsiveText(
                      'No Discount on This Item',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const ResponsiveText(
                        'Regular Price',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const ResponsiveText(
                  'This shoe is priced at standard retail with no active discount offer.',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. CUSTOMER INFORMATION CARD ───────────────────────────────────────────
  Widget _buildCustomerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtleBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Name & Last Name (Side by Side)
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'e.g. John',
                  icon: Icons.person_outline,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'e.g. Doe',
                  icon: Icons.person_outline,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Email Address (Strict regex validation & no whitespace)
          _buildFormField(
            controller: _emailController,
            label: 'Email Address (Required)',
            hint: 'user@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            isRequired: true,
            isMustEnter: true,
            validator: (value) {
              final val = value?.trim() ?? '';
              if (val.isEmpty) {
                return 'Email is required and cannot be empty';
              }
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
              );
              if (!emailRegex.hasMatch(val)) {
                return 'Please enter a valid email address (e.g. user@gmail.com)';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Phone Number (Numbers only, exactly 11 digits, must start with 03)
          _buildFormField(
            controller: _phoneController,
            label: 'Phone Number (11 Digits, starts with 03)',
            hint: '03001234567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            isRequired: true,
            isMustEnter: true,
            validator: (value) {
              final val = value?.trim() ?? '';
              if (val.isEmpty) {
                return 'Phone number is required';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                return 'Only numbers are allowed';
              }
              if (!val.startsWith('03')) {
                return 'Phone number must start with 03 (e.g. 03001234567)';
              }
              if (val.length != 11) {
                return 'Phone number must be exactly 11 digits (current: ${val.length})';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── 5. DELIVERY ADDRESS CARD ───────────────────────────────────────────────
  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtleBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Address Field
          _buildFormField(
            controller: _fullAddressController,
            label: 'Full Address',
            hint: 'e.g. House # 12-A, Main Commercial Area',
            icon: Icons.home_outlined,
            isRequired: true,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full address is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // City Dropdown Selector (Luxury Black & Animated Dropdown)
          AppAnimatedDropdown<String>(
            label: 'City',
            hint: 'Select Delivery City',
            value: _selectedCity,
            items: _cities,
            itemLabel: (city) => city,
            prefixIcon: Icons.location_city_rounded,
            isRequired: true,
            sheetTitle: 'Select Delivery City',
            showSearch: true,
            onChanged: (newCity) {
              setState(() {
                _selectedCity = newCity;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a city';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Street & House Fields (Side by Side)
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _streetController,
                  label: 'Street / Sector',
                  hint: 'e.g. Street 4, F-8',
                  icon: Icons.add_road_rounded,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Street required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField(
                  controller: _houseController,
                  label: 'House / Unit #',
                  hint: 'e.g. House 45-B',
                  icon: Icons.apartment_rounded,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'House required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Visual Delivery Preview Card
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 75),
                    painter: MapPatternPainter(),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryLightBlue.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          color: primaryLightBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        ResponsiveText(
                          'Deliver to: ${_selectedCity ?? "Selected Area"}',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryLightBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPER REUSABLE FORM FIELD ─────────────────────────────────────────────
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    bool isMustEnter = false,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ResponsiveText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: errorRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
            if (isMustEnter) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const ResponsiveText(
                  'Must Enter',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: errorRed,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  maxLength}) =>
              null,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: textHint,
            ),
            prefixIcon: Icon(icon, color: primaryLightBlue, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: subtleBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primaryLightBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: errorRed, width: 2.0),
            ),
            errorStyle: const TextStyle(
              color: errorRed,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ── 6. PAYMENT METHOD SELECTOR ─────────────────────────────────────────────
  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        _buildPaymentOptionTile(
          id: 'Cash on Delivery',
          title: 'Cash on Delivery (COD)',
          subtitle: 'Pay with cash upon delivery at your doorstep',
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          id: 'Card',
          title: 'Credit / Debit Card / Online',
          subtitle: 'Instant secure payment via Card or Gateway',
          icon: Icons.credit_card_rounded,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedPaymentMethod == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryLightBlue : subtleBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryLightBlue.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryLightBlue.withValues(alpha: 0.12)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryLightBlue : textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    title,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                  const SizedBox(height: 2),
                  ResponsiveText(
                    subtitle,
                    fontSize: 11.5,
                    color: textMuted,
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryLightBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryLightBlue : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── 7. PRICE BREAKDOWN SUMMARY ─────────────────────────────────────────────
  Widget _buildPriceBreakdownCard({
    required double subtotal,
    required double shipping,
    required double discount,
    required double totalCost,
    required bool hasDiscount,
    required double discountPercentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subtleBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _buildSummaryRow('Shipping Fee', '\$${shipping.toStringAsFixed(2)}'),
          if (hasDiscount && discount > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryRow(
              'Shoe Discount (${discountPercentage.toStringAsFixed(0)}% OFF)',
              '-\$${discount.toStringAsFixed(2)}',
              valueColor: successGreen,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: subtleBorderColor, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'Total Payable',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
              ResponsiveText(
                '\$${totalCost.toStringAsFixed(2)}',
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: primaryLightBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ResponsiveText(
          label,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
        ResponsiveText(
          value,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: valueColor ?? textDark,
        ),
      ],
    );
  }

  // ── 8. PLACE ORDER BUTTON ──────────────────────────────────────────────────
  Widget _buildPlaceOrderButton({
    required double totalCost,
    required bool hasDiscountApplied,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () => _submitOrder(
                  totalCost: totalCost,
                  hasDiscountApplied: hasDiscountApplied,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLightBlue,
          disabledBackgroundColor: primaryLightBlue.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: primaryLightBlue.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  ResponsiveText(
                    'Payment (\$${totalCost.toStringAsFixed(2)})',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}

// ── HELPER BADGE WIDGET ───────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _Badge({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFF4B96E6).withValues(alpha: 0.1)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ResponsiveText(
        label,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isPrimary ? const Color(0xFF4B96E6) : const Color(0xFF475569),
      ),
    );
  }
}

// ── PAYMENT SUCCESS ANIMATED MODAL ───────────────────────────────────────────
class PaymentSuccessModal extends StatefulWidget {
  final String orderId;
  final double totalCost;
  final String city;
  final String paymentMethod;

  const PaymentSuccessModal({
    super.key,
    required this.orderId,
    required this.totalCost,
    required this.city,
    required this.paymentMethod,
  });

  @override
  State<PaymentSuccessModal> createState() => _PaymentSuccessModalState();
}

class _PaymentSuccessModalState extends State<PaymentSuccessModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.1), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    AppImages.confettiPopper,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4B96E6),
                      size: 58,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const ResponsiveText(
              'Order Placed\nSuccessfully!',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ResponsiveText(
                'Order ID: ${widget.orderId}',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4B96E6),
              ),
            ),
            const SizedBox(height: 14),
            ResponsiveText(
              'Your order of \$${widget.totalCost.toStringAsFixed(2)} has been recorded and will be delivered to ${widget.city}.',
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // View My Orders Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (Get.isRegistered<CartController>()) {
                    CartController.to.clearCart();
                  }
                  Navigator.of(context).pop();
                  Get.back();
                  Get.to(() => const MyOrdersView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B96E6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const ResponsiveText(
                  'Track Order / My Orders',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Back to Shopping Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  if (Get.isRegistered<CartController>()) {
                    CartController.to.clearCart();
                  }
                  Navigator.of(context).pop();
                  Get.back();
                  if (Get.isRegistered<HomeController>()) {
                    Get.find<HomeController>().changeIndex(0);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4B96E6), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const ResponsiveText(
                  'Back To Shopping',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B96E6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MAP PATTERN CUSTOM PAINTER ───────────────────────────────────────────────
class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(size.width * 0.3, size.height * 0.2, size.width * 0.6,
          size.height * 0.8, size.width, size.height * 0.5);

    final path2 = Path()
      ..moveTo(size.width * 0.25, 0)
      ..cubicTo(size.width * 0.45, size.height * 0.6, size.width * 0.75,
          size.height * 0.3, size.width * 0.85, size.height);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
