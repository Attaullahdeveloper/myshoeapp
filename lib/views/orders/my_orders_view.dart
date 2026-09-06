import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/responsive_text.dart';
import '../auth/signin_view.dart';
import 'order_details_view.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView> {
  // ── DESIGN SYSTEM COLORS ───────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF4B96E6);
  static const Color primaryLightBlue = Color(0xFF5B9EE1);
  static const Color screenBg = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color subtleBorder = Color(0xFFE2E8F0);
  static const Color softGreyTile = Color(0xFFF1F5F9);

  // Filter categories
  final List<String> _filters = ['All', 'Active', 'Delivered', 'Cancelled'];
  String _selectedFilter = 'All';

  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  RealtimeChannel? _ordersChannel;

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
    _subscribeToOrdersRealtime();
  }

  @override
  void dispose() {
    if (_ordersChannel != null) {
      Supabase.instance.client.removeChannel(_ordersChannel!);
    }
    super.dispose();
  }

  // ── 1. REALTIME ORDER STATUS SUBSCRIPTION ──────────────────────────────────
  void _subscribeToOrdersRealtime() {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Listen to changes in the 'orders' table in real-time
      _ordersChannel = supabase
          .channel('public:user_orders_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              debugPrint('🔄 Realtime orders update detected: ${payload.eventType}');
              // Automatically fetch updated orders and status from database
              fetchUserOrders(showLoading: false);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('⚠️ Supabase Realtime User Orders Subscription: $e');
    }
  }

  // ── 2. FETCH SPECIFIC USER ORDERS ──────────────────────────────────────────
  Future<void> fetchUserOrders({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _orders = [];
            _isLoading = false;
          });
        }
        return;
      }

      // Fetch orders specifically matching user_id (or user's email)
      List<dynamic> response = [];
      try {
        if (currentUser.email != null && currentUser.email!.isNotEmpty) {
          response = await supabase
              .from('orders')
              .select('*')
              .or('user_id.eq.${currentUser.id},email.eq.${currentUser.email}')
              .order('created_at', ascending: false);
        } else {
          response = await supabase
              .from('orders')
              .select('*')
              .eq('user_id', currentUser.id)
              .order('created_at', ascending: false);
        }
      } catch (err) {
        debugPrint('⚠️ Order fetch fallback attempt: $err');
        try {
          response = await supabase
              .from('orders')
              .select('*')
              .eq('user_id', currentUser.id);
        } catch (_) {
          response = [];
        }
      }

      // Products & Companies lookup maps for enriched titles & images
      final Map<String, Map<String, dynamic>> productLookup = {};
      final Map<String, Map<String, dynamic>> companyLookup = {};

      try {
        final prods = await supabase.from('products').select('*');
        for (var p in prods) {
          final m = Map<String, dynamic>.from(p);
          final pId1 = m['prod_id']?.toString();
          final pId2 = m['id']?.toString();
          if (pId1 != null && pId1.isNotEmpty) productLookup[pId1] = m;
          if (pId2 != null && pId2.isNotEmpty) productLookup[pId2] = m;
        }
      } catch (e) {
        debugPrint('⚠️ Product lookup note: $e');
      }

      try {
        final comps = await supabase.from('companies').select('*');
        for (var c in comps) {
          final m = Map<String, dynamic>.from(c);
          final cId1 = m['id']?.toString();
          final cId2 = m['comp_id']?.toString();
          final cId3 = m['company_id']?.toString();
          if (cId1 != null && cId1.isNotEmpty) companyLookup[cId1] = m;
          if (cId2 != null && cId2.isNotEmpty) companyLookup[cId2] = m;
          if (cId3 != null && cId3.isNotEmpty) companyLookup[cId3] = m;
        }
      } catch (e) {
        debugPrint('⚠️ Company lookup note: $e');
      }

      // Enrich orders
      List<Map<String, dynamic>> enrichedOrders = [];
      for (var item in response) {
        final order = Map<String, dynamic>.from(item);
        final pId = order['prod_id']?.toString();
        final cId = order['comp_id']?.toString() ?? order['company_id']?.toString();

        if (pId != null && productLookup.containsKey(pId)) {
          order['products'] = productLookup[pId];
        }
        if (cId != null && companyLookup.containsKey(cId)) {
          order['companies'] = companyLookup[cId];
        }
        if (order['companies'] == null && order['products'] != null) {
          final prodCompId = order['products']['company_id']?.toString();
          if (prodCompId != null && companyLookup.containsKey(prodCompId)) {
            order['companies'] = companyLookup[prodCompId];
          }
        }
        enrichedOrders.add(order);
      }

      if (mounted) {
        setState(() {
          _orders = enrichedOrders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching user orders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ── FILTERED ORDERS ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'All') return _orders;

    return _orders.where((order) {
      final status = (order['status'] ?? 'created').toString().toLowerCase();
      if (_selectedFilter == 'Active') {
        return status == 'created' || status == 'processing' || status == 'shipped';
      } else if (_selectedFilter == 'Delivered') {
        return status == 'delivered';
      } else if (_selectedFilter == 'Cancelled') {
        return status == 'cancelled';
      }
      return true;
    }).toList();
  }

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
        return status.capitalizeFirst ?? status;
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
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && dt.day == now.day) {
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return 'Today, $hour:$minute $ampm';
    } else if (diff.inDays < 2 &&
        dt.day == now.subtract(const Duration(days: 1)).day) {
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return 'Yesterday, $hour:$minute $ampm';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $ampm';
    }
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

  // ── BUILD MAIN SCREEN ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP APP BAR ──
            _buildAppBar(context),

            // If not logged in
            if (currentUser == null)
              Expanded(child: _buildNotLoggedInState())
            else ...[
              // ── FILTER CHIPS BAR ──
              _buildFilterBar(),

              const SizedBox(height: 8),

              // ── ORDERS LIST ──
              Expanded(
                child: _isLoading
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        itemCount: 4,
                        itemBuilder: (context, index) =>
                            const AppOrderItemShimmer(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => fetchUserOrders(showLoading: true),
                        color: primaryBlue,
                        child: _filteredOrders.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return _buildOrderCard(order);
                                },
                              ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: subtleBorder, width: 1)),
      ),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: softGreyTile,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: subtleBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: textDark),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Live Realtime Indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ResponsiveText(
                  'My Orders',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ResponsiveText(
                      _orders.isNotEmpty
                          ? '${_orders.length} order${_orders.length > 1 ? 's' : ''} placed • Realtime sync'
                          : 'Live order status updates',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Refresh Button
          IconButton(
            onPressed: () => fetchUserOrders(showLoading: true),
            icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
    );
  }

  // ── FILTER BAR ─────────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              }
            },
            selectedColor: primaryBlue,
            backgroundColor: cardBg,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : textDark,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected ? primaryBlue : subtleBorder,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          );
        },
      ),
    );
  }

  // ── ORDER CARD (MATCHING PICTURE 1 DESIGN) ──────────────────────────────────
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String rawStatus = (order['status'] ?? 'created').toString();
    final String statusLabel = _formatStatusLabel(rawStatus);
    final int stepIndex = _getStatusStepIndex(rawStatus);

    final String orderId = order['order_id'] ?? '#ORD-${order['id']}';
    final String formattedDate = _formatDate(order['created_at']);
    final String shortDate = _formatShortDate(order['created_at']);
    final double price =
        double.tryParse(order['price']?.toString() ?? '0') ?? 0.0;

    // Product extraction
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openOrderDetails(order),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. STATUS CARD BANNER (WARM AMBER TINT) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFDE68A), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
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
                                const SizedBox(width: 5),
                                ResponsiveText(
                                  'Current Status: $statusLabel',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ],
                            ),
                          ),

                          // Live Sync Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sync_rounded,
                                    size: 12, color: Color(0xFF059669)),
                                SizedBox(width: 4),
                                ResponsiveText(
                                  'Live Sync',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ResponsiveText(
                        _getStatusHeading(rawStatus),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      const SizedBox(height: 3),
                      ResponsiveText(
                        'Placed on $formattedDate',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── 2. TRACKING PROGRESS ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ResponsiveText(
                            'TRACKING PROGRESS',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ResponsiveText(
                              _getEstDeliveryDate(order['created_at']),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatusStepper(stepIndex, shortDate),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── 3. ITEM ORDERED ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ResponsiveText(
                      'ITEM ORDERED',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                    ResponsiveText(
                      '${qty ?? 1} Item',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image with HOT badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: shoeImageUrl != null &&
                                    shoeImageUrl.isNotEmpty
                                ? Image.network(
                                    shoeImageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 24,
                                    ),
                                  )
                                : const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 24,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 3,
                          left: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFFCA5A5), width: 0.7),
                            ),
                            child: const ResponsiveText(
                              'HOT',
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: ResponsiveText(
                                  brandName.toUpperCase(),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const ResponsiveText(
                                'Retro Ed.',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          ResponsiveText(
                            shoeName,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          ResponsiveText(
                            'Size: ${sizeVal ?? "Standard (US 9.5)"}  •  Qty: ${qty ?? 1}',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ResponsiveText(
                                '\$${price.toStringAsFixed(2)}',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const ResponsiveText(
                                  'Guaranteed Authentic',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),

                // ── 4. BOTTOM ACTION & ORDER ID ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order ID chip (with copy)
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ResponsiveText(
                              orderId,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded,
                                size: 11, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),

                    // Tap to View Details
                    Row(
                      children: [
                        const ResponsiveText(
                          'View Details & Track',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 11, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── ORDER STATUS STEPPER (MATCHING PICTURE 1 DESIGN) ───────────────────────
  Widget _buildStatusStepper(int currentStepIndex, [String shortDate = 'Today']) {
    final steps = [
      {'title': 'Placed', 'sub': shortDate, 'icon': Icons.check_rounded},
      {'title': 'Processing', 'sub': 'Pending', 'icon': Icons.inventory_2_outlined},
      {'title': 'Shipped', 'sub': 'TBD', 'icon': Icons.local_shipping_outlined},
      {'title': 'Delivered', 'sub': 'TBD', 'icon': Icons.verified_outlined},
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              final lineIdx = index ~/ 2;
              final isPassed = currentStepIndex > lineIdx;
              return Expanded(
                child: Container(
                  height: 2.5,
                  color: isPassed
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                ),
              );
            } else {
              final stepIdx = index ~/ 2;
              final isCompletedOrCurrent = currentStepIndex >= stepIdx;
              final isPassed = currentStepIndex > stepIdx;

              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompletedOrCurrent
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompletedOrCurrent
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: isCompletedOrCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.25),
                            blurRadius: 6,
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
                    size: 13,
                    color: isCompletedOrCurrent
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            final isCurrent = currentStepIndex == idx;
            final isPassed = currentStepIndex >= idx;

            return SizedBox(
              width: 62,
              child: Column(
                children: [
                  ResponsiveText(
                    data['title'] as String,
                    textAlign: TextAlign.center,
                    fontSize: 10.5,
                    fontWeight: isCurrent || isPassed
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isCurrent
                        ? const Color(0xFF2563EB)
                        : (isPassed
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 1.5),
                  ResponsiveText(
                    data['sub'] as String,
                    textAlign: TextAlign.center,
                    fontSize: 9.5,
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

  // ── NAVIGATE TO FULL ORDER DETAILS VIEW ────────────────────────────────────
  void _openOrderDetails(Map<String, dynamic> order) {
    Get.to(() => OrderDetailsView(order: order));
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_mall_outlined,
                size: 42,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            ResponsiveText(
              _selectedFilter == 'All'
                  ? 'No Orders Yet'
                  : 'No $_selectedFilter Orders',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
            const SizedBox(height: 8),
            const ResponsiveText(
              'Your placed shoe orders and their live status from the store admin will be shown right here.',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  if (Get.isRegistered<HomeController>()) {
                    Get.find<HomeController>().changeIndex(0);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryLightBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                icon: const Icon(Icons.shopping_bag_outlined,
                    size: 18, color: Colors.white),
                label: const ResponsiveText(
                  'Explore Shoes',
                  fontSize: 14,
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

  // ── NOT LOGGED IN STATE ────────────────────────────────────────────────────
  Widget _buildNotLoggedInState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 38,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const ResponsiveText(
              'Sign In Required',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
            const SizedBox(height: 8),
            const ResponsiveText(
              'Please sign in with your account to view your placed orders and live delivery tracking.',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const SignInView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: const ResponsiveText(
                  'Sign In Now',
                  fontSize: 14,
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
