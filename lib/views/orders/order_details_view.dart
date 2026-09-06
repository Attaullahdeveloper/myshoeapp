import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_toast.dart';
import '../../widgets/responsive_text.dart';

class OrderDetailsView extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsView({super.key, required this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  // ── DESIGN SYSTEM PALETTE ──────────────────────────────────────────────────
  static const Color screenBg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color subtleBorder = Color(0xFFE2E8F0);

  // ── HELPERS ────────────────────────────────────────────────────────────────
  String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return 'Order Placed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : status;
    }
  }

  String _getStatusHeading(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return 'Waiting for seller dispatch';
      case 'processing':
        return 'Order is being packed & prepared';
      case 'shipped':
        return 'Order is on the way with courier';
      case 'delivered':
        return 'Order successfully delivered';
      case 'cancelled':
        return 'Order has been cancelled';
      default:
        return 'Status updated';
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return -1;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Recent';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return dateStr;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $ampm';
  }

  String _formatShortDate(String? dateStr) {
    if (dateStr == null) return 'Today';
    final dt = DateTime.tryParse(dateStr)?.toLocal();
    if (dt == null) return 'Today';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _getEstDeliveryDate(String? dateStr) {
    final dt = DateTime.tryParse(dateStr ?? '')?.toLocal() ?? DateTime.now();
    final start = dt.add(const Duration(days: 3));
    final end = dt.add(const Duration(days: 5));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Est: ${start.day} - ${end.day} ${months[end.month - 1]}';
  }

  void _showCourierTrackingModal(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: subtleBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: primaryBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ResponsiveText(
                        'Live Courier Tracking',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                      ResponsiveText(
                        'Tracking # TRK-${orderId.replaceAll(RegExp(r'[^0-9]'), '').padRight(8, '0').substring(0, 8)}',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: subtleBorder),
              ),
              child: Column(
                children: [
                  _buildModalTrackingRow(
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    title: 'Dispatched from Warehouse',
                    time: 'Hub Logistics Center',
                    isDone: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModalTrackingRow(
                    icon: Icons.radio_button_checked_rounded,
                    color: primaryBlue,
                    title: 'In Transit to Regional Station',
                    time: 'Out for distribution',
                    isDone: true,
                  ),
                  const SizedBox(height: 12),
                  _buildModalTrackingRow(
                    icon: Icons.radio_button_unchecked_rounded,
                    color: textMuted,
                    title: 'Out for Final Delivery',
                    time: 'Expected tomorrow',
                    isDone: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const ResponsiveText(
                  'OK, Understood',
                  fontSize: 14.5,
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

  Widget _buildModalTrackingRow({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required bool isDone,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                title,
                fontSize: 13,
                fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                color: isDone ? textDark : textMuted,
              ),
              ResponsiveText(
                time,
                fontSize: 11,
                color: textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final String rawStatus = (order['status'] ?? 'created').toString();
    final String statusLabel = _formatStatusLabel(rawStatus);
    final int stepIndex = _getStatusStepIndex(rawStatus);

    final String orderId = order['order_id'] ?? '#ORD-${order['id']}';
    final String formattedDate = _formatDate(order['created_at']);
    final String shortDate = _formatShortDate(order['created_at']);
    final double price =
        double.tryParse(order['price']?.toString() ?? '0') ?? 0.0;
    final bool isPaid = order['payment_status'] == true ||
        order['payment_status']?.toString().toUpperCase() == 'TRUE' ||
        order['payment_status']?.toString().toUpperCase() == 'PAID';

    // Extracted product & company info
    final productData = order['products'] as Map<String, dynamic>?;
    final companyData = order['companies'] as Map<String, dynamic>?;
    final addressData = order['address'];

    final String shoeName = productData?['title'] ??
        productData?['name'] ??
        (addressData is Map
            ? (addressData['product_name'] ?? addressData['shoe_name'])
            : null) ??
        'Premium Footwear';

    final String brandName = companyData?['name'] ??
        companyData?['title'] ??
        (addressData is Map ? addressData['company_name'] : null) ??
        'Jordan';

    final String? shoeImageUrl = productData?['product_img_url'] ??
        productData?['image'] ??
        productData?['image_url'] ??
        (addressData is Map ? addressData['product_image'] : null);

    final int? qty = addressData is Map && addressData['quantity'] != null
        ? int.tryParse(addressData['quantity'].toString())
        : null;

    final dynamic sizeVal =
        addressData is Map ? addressData['selected_size'] : null;

    final String phone = (order['phone_no'] ??
            (addressData is Map ? addressData['phone_no'] : null) ??
            '03123213213')
        .toString();

    final String email = (order['email'] ??
            (addressData is Map ? addressData['email'] : null) ??
            'user@gmail.com')
        .toString();

    String formattedLocation = 'Delivery address recorded';
    if (addressData is Map) {
      formattedLocation = addressData['location'] ??
          addressData['full_address'] ??
          '${addressData['house'] ?? ""}, ${addressData['street'] ?? ""}, ${addressData['city'] ?? ""} - Pakistan';
    } else if (addressData != null) {
      formattedLocation = addressData.toString();
    }

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: textDark, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveText(
              'Order Details',
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
            ResponsiveText(
              orderId,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: textMuted, size: 20),
            tooltip: 'Support',
            onPressed: () {
              AppToast.showSuccess(
                context: context,
                title: 'Customer Support',
                message: 'Connecting to customer support team...',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: textMuted, size: 20),
            tooltip: 'Share Order',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text:
                      'Shoe App Order Details: $orderId | $shoeName | Status: $statusLabel'));
              AppToast.showSuccess(
                context: context,
                title: 'Share Link Copied',
                message: 'Order summary copied to clipboard',
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. STATUS CARD (WARM AMBER TINT) ──
            _buildStatusCard(
              rawStatus: rawStatus,
              statusLabel: statusLabel,
              formattedDate: formattedDate,
            ),
            const SizedBox(height: 14),

            // ── 2. TRACKING PROGRESS STEPPER ──
            _buildTrackingProgressCard(
              stepIndex: stepIndex,
              createdDate: order['created_at'],
              shortDate: shortDate,
            ),
            const SizedBox(height: 14),

            // ── 3. ITEM ORDERED CARD ──
            _buildItemOrderedCard(
              shoeName: shoeName,
              brandName: brandName,
              shoeImageUrl: shoeImageUrl,
              sizeVal: sizeVal,
              qty: qty,
              price: price,
            ),
            const SizedBox(height: 14),

            // ── 4. ORDER INFORMATION CARD ──
            _buildOrderInfoCard(
              orderId: orderId,
              formattedDate: formattedDate,
              isPaid: isPaid,
            ),
            const SizedBox(height: 14),

            // ── 5. DELIVERY INFORMATION CARD ──
            _buildDeliveryInfoCard(
              formattedLocation: formattedLocation,
              phone: phone,
              email: email,
            ),
            const SizedBox(height: 14),

            // ── 6. PRICE BREAKDOWN CARD ──
            _buildPriceBreakdownCard(
              qty: qty,
              price: price,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      // ── BOTTOM BUTTONS BAR ──
      bottomNavigationBar: _buildBottomActionBar(context, orderId),
    );
  }

  // ── 1. STATUS CARD ─────────────────────────────────────────────────────────
  Widget _buildStatusCard({
    required String rawStatus,
    required String statusLabel,
    required String formattedDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Warm light amber
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current Status Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ResponsiveText(
                      'Current Status: $statusLabel',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ],
                ),
              ),

              // Live Sync Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync_rounded,
                        size: 13, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    ResponsiveText(
                      'Live Sync',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ResponsiveText(
            _getStatusHeading(rawStatus),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
          const SizedBox(height: 4),
          ResponsiveText(
            'Placed on $formattedDate',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textMuted,
          ),
        ],
      ),
    );
  }

  // ── 2. TRACKING PROGRESS CARD ──────────────────────────────────────────────
  Widget _buildTrackingProgressCard({
    required int stepIndex,
    required String? createdDate,
    required String shortDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'TRACKING PROGRESS',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ResponsiveText(
                  _getEstDeliveryDate(createdDate),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildTrackingStepper(stepIndex, shortDate),
        ],
      ),
    );
  }

  Widget _buildTrackingStepper(int currentStepIndex, String shortDate) {
    final steps = [
      {'title': 'Placed', 'sub': shortDate, 'icon': Icons.check_rounded},
      {'title': 'Processing', 'sub': 'Pending', 'icon': Icons.inventory_2_outlined},
      {'title': 'Shipped', 'sub': 'TBD', 'icon': Icons.local_shipping_outlined},
      {'title': 'Delivered', 'sub': 'TBD', 'icon': Icons.verified_outlined},
    ];

    return Column(
      children: [
        // Stepper Icons & Lines
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              // Line
              final lineIdx = index ~/ 2;
              final isPassed = currentStepIndex > lineIdx;
              return Expanded(
                child: Container(
                  height: 2.5,
                  color: isPassed ? primaryBlue : const Color(0xFFE2E8F0),
                ),
              );
            } else {
              // Icon Circle
              final stepIdx = index ~/ 2;
              final isCompletedOrCurrent = currentStepIndex >= stepIdx;
              final isPassed = currentStepIndex > stepIdx;

              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompletedOrCurrent
                      ? primaryBlue
                      : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompletedOrCurrent
                        ? primaryBlue
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: isCompletedOrCurrent
                      ? [
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    isPassed
                        ? Icons.check_rounded
                        : (steps[stepIdx]['icon'] as IconData),
                    size: 15,
                    color: isCompletedOrCurrent
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 10),
        // Step Labels & Subtitles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            final isCurrent = currentStepIndex == idx;
            final isPassed = currentStepIndex >= idx;

            return SizedBox(
              width: 68,
              child: Column(
                children: [
                  ResponsiveText(
                    data['title'] as String,
                    textAlign: TextAlign.center,
                    fontSize: 11.5,
                    fontWeight: isCurrent || isPassed
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isCurrent
                        ? primaryBlue
                        : (isPassed ? textDark : const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 2),
                  ResponsiveText(
                    data['sub'] as String,
                    textAlign: TextAlign.center,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 3. ITEM ORDERED CARD ───────────────────────────────────────────────────
  Widget _buildItemOrderedCard({
    required String shoeName,
    required String brandName,
    required String? shoeImageUrl,
    required dynamic sizeVal,
    required int? qty,
    required double price,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'ITEM ORDERED',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
              ResponsiveText(
                '${qty ?? 1} Item',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image container with HOT badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: subtleBorder),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: shoeImageUrl != null && shoeImageUrl.isNotEmpty
                          ? Image.network(
                              shoeImageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported_rounded,
                                color: Color(0xFF94A3B8),
                                size: 28,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: primaryBlue,
                              size: 28,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFFCA5A5), width: 0.8),
                      ),
                      child: const ResponsiveText(
                        'HOT',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ResponsiveText(
                            brandName.toUpperCase(),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const ResponsiveText(
                          'Retro Ed.',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText(
                      shoeName,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    ResponsiveText(
                      'Size: ${sizeVal ?? "Standard (US 9.5)"}  •  Qty: ${qty ?? 1}',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ResponsiveText(
                          '\$${price.toStringAsFixed(2)}',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const ResponsiveText(
                            'Guaranteed Authentic',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. ORDER INFORMATION CARD ──────────────────────────────────────────────
  Widget _buildOrderInfoCard({
    required String orderId,
    required String formattedDate,
    required bool isPaid,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            'ORDER INFORMATION',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
          const SizedBox(height: 14),
          // Order ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'Order ID',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: orderId));
                  AppToast.showSuccess(
                    context: context,
                    title: 'Copied',
                    message: 'Order ID copied to clipboard',
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ResponsiveText(
                        orderId,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.copy_rounded,
                          size: 12, color: textMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Placed Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'Placed Date',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              ResponsiveText(
                formattedDate,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment Method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'Payment Method',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPaid
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.credit_card_rounded
                          : Icons.payments_outlined,
                      size: 13,
                      color: isPaid
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 5),
                    ResponsiveText(
                      isPaid ? 'Paid Online' : 'Cash on Delivery (COD)',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isPaid
                          ? const Color(0xFF059669)
                          : const Color(0xFFB45309),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. DELIVERY INFORMATION CARD ───────────────────────────────────────────
  Widget _buildDeliveryInfoCard({
    required String formattedLocation,
    required String phone,
    required String email,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            'DELIVERY INFORMATION',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
          const SizedBox(height: 14),
          // Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded,
                    size: 18, color: primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ResponsiveText(
                      'Shipping Address',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                    const SizedBox(height: 2),
                    ResponsiveText(
                      formattedLocation,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Phone Row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_rounded,
                    size: 16, color: textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText(
                  phone,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
                  final uri = Uri(scheme: 'tel', path: cleanPhone);
                  try {
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      Clipboard.setData(ClipboardData(text: phone));
                      AppToast.showSuccess(
                        context: context,
                        title: 'Copied',
                        message: 'Phone number copied to clipboard',
                      );
                    }
                  } catch (_) {
                    Clipboard.setData(ClipboardData(text: phone));
                    AppToast.showSuccess(
                      context: context,
                      title: 'Copied',
                      message: 'Phone number copied to clipboard',
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ResponsiveText(
                    'Call',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Email Row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.email_rounded,
                    size: 16, color: textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ResponsiveText(
                  email,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 6. PRICE BREAKDOWN CARD ────────────────────────────────────────────────
  Widget _buildPriceBreakdownCard({
    required int? qty,
    required double price,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            'PRICE BREAKDOWN',
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                'Subtotal (${qty ?? 1} Item)',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              ResponsiveText(
                '\$${price.toStringAsFixed(2)}',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                'Standard Shipping',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              ResponsiveText(
                'FREE',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                'Estimated Tax',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textMuted,
              ),
              ResponsiveText(
                '\$0.00',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: subtleBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ResponsiveText(
                'Total Amount',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
              ResponsiveText(
                '\$${price.toStringAsFixed(2)}',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTION BUTTONS ──────────────────────────────────────────────────
  Widget _buildBottomActionBar(BuildContext context, String orderId) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel / Back Button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const ResponsiveText(
                  'Cancel / Back',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Track Live Courier Button
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => _showCourierTrackingModal(context, orderId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: primaryBlue.withValues(alpha: 0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_searching_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    ResponsiveText(
                      'Track Live Courier',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
