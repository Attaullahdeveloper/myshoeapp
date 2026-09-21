import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/cart_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_toast.dart';
import 'web_colors.dart';

class WebCheckoutModal extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onOrderSuccess;

  const WebCheckoutModal({
    super.key,
    required this.onClose,
    required this.onOrderSuccess,
  });

  @override
  State<WebCheckoutModal> createState() => _WebCheckoutModalState();
}

class _WebCheckoutModalState extends State<WebCheckoutModal> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();

  bool _isSubmitting = false;
  bool _isOrderPlaced = false;
  String _generatedOrderId = '';
  String _selectedPaymentMethod = 'cod'; // 'cod' | 'card'

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      final fullName = user.userMetadata?['full_name']?.toString() ?? '';
      if (fullName.isNotEmpty) {
        final parts = fullName.split(' ');
        _firstNameController.text = parts.first;
        if (parts.length > 1) {
          _lastNameController.text = parts.sublist(1).join(' ');
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
    _cityController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) {
      AppToast.showWarning(
        title: 'Incomplete Form',
        message: 'Please fill in all shipping details correctly.',
      );
      return;
    }

    final cart = CartController.to;
    if (cart.items.isEmpty) {
      AppToast.showError(
        title: 'Empty Cart',
        message: 'There are no items in your shopping bag.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      final fullAddress =
          '${_houseController.text.trim()}, ${_streetController.text.trim()}, ${_cityController.text.trim()}';

      final address = OrderAddress(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        fullAddress: fullAddress,
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        house: _houseController.text.trim(),
      );

      // Create orders in Supabase for each cart item or composite
      for (final item in cart.items) {
        final int? prodId = int.tryParse(item.product.id);
        final int? compId = item.product.companyId != null
            ? int.tryParse(item.product.companyId!)
            : null;

        final order = OrderModel(
          orderId: orderId,
          userId: user?.id,
          prodId: prodId,
          compId: compId,
          price: item.totalPrice,
          discountApplied: item.totalDiscount > 0,
          paymentStatus: _selectedPaymentMethod == 'card',
          phoneNo: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          status: 'created',
          address: address,
        );

        await supabase.from('orders').insert(order.toSupabaseMap());
      }

      // Clear Cart on successful order
      cart.clearCart();

      setState(() {
        _isSubmitting = false;
        _isOrderPlaced = true;
        _generatedOrderId = orderId;
      });

      widget.onOrderSuccess();
    } catch (e) {
      setState(() => _isSubmitting = false);
      AppToast.showError(
        title: 'Order Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 800;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isDesktop ? 780 : size.width * 0.94,
          constraints: BoxConstraints(
            maxWidth: 820,
            maxHeight: size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: WebColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: WebColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: WebColors.gold.withOpacity(0.12),
                blurRadius: 30,
              ),
            ],
          ),
          child: _isOrderPlaced
              ? _buildSuccessView()
              : _buildCheckoutForm(isDesktop),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WebColors.emerald.withOpacity(0.15),
              border: Border.all(color: WebColors.emerald, width: 2),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.checkmark_alt,
                size: 44,
                color: WebColors.emerald,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ORDER CONFIRMED!',
            style: TextStyle(
              color: WebColors.textMain,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for your purchase. We have received your order.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: WebColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: WebColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WebColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ORDER ID: ',
                  style: TextStyle(
                    color: WebColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _generatedOrderId,
                  style: const TextStyle(
                    color: WebColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: WebColors.gold,
                foregroundColor: const Color(0xFF090C10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'CONTINUE SHOPPING',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm(bool isDesktop) {
    final cart = CartController.to;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: WebColors.gold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.creditcard_fill,
                          color: WebColors.gold,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SHIPPING & CHECKOUT',
                      style: TextStyle(
                        color: WebColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Name Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        hint: 'John',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hint: 'Doe',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Contact Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'john@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            !v!.contains('@') ? 'Valid email required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+92 300 1234567',
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.length < 7 ? 'Valid phone required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Address fields
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'New York / Lahore',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: _buildTextField(
                        controller: _streetController,
                        label: 'Street / Area',
                        hint: 'Main Boulevard, Block 4',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        controller: _houseController,
                        label: 'House / Apt #',
                        hint: 'House 42B',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Payment Method Selector
                const Text(
                  'PAYMENT METHOD',
                  style: TextStyle(
                    color: WebColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentOption(
                        id: 'cod',
                        title: 'Cash on Delivery',
                        subtitle: 'Pay when shoes arrive',
                        icon: CupertinoIcons.money_dollar_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPaymentOption(
                        id: 'card',
                        title: 'Debit / Credit Card',
                        subtitle: 'Secure online payment',
                        icon: CupertinoIcons.creditcard,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Order summary bar
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: WebColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WebColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cart.itemCount} Sneaker${cart.itemCount > 1 ? 's' : ''} in Order',
                            style: const TextStyle(
                              color: WebColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Grand Total: \$${cart.totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: WebColors.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handlePlaceOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebColors.gold,
                            foregroundColor: const Color(0xFF090C10),
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF090C10),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'CONFIRM ORDER',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
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
        ),

        // Close button
        Positioned(
          top: 20,
          right: 20,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onClose,
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
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: WebColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: WebColors.textMain, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: WebColors.textDim, fontSize: 13),
            filled: true,
            fillColor: WebColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WebColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WebColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WebColors.gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? WebColors.gold.withOpacity(0.1)
                : WebColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? WebColors.gold : WebColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? WebColors.gold : WebColors.textMuted,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? WebColors.gold : WebColors.textMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: WebColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.circle,
                color: isSelected ? WebColors.gold : WebColors.border,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
