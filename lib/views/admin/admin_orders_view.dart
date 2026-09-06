import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_images.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_animated_dropdown.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/responsive_text.dart';

class AdminOrdersView extends StatefulWidget {
  const AdminOrdersView({super.key});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  // Theme Colors
  static const Color primaryBlue = Color(0xFF4B96E6);
  static const Color screenBg = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color cardBg = Colors.white;
  static const Color subtleBorder = Color(0xFFE2E8F0);
  static const Color softGreyTile = Color(0xFFF8FAFC);

  // Status Filter options
  final List<String> _filterCategories = [
    'All',
    'Created',
    'Processing',
    'Dispatched',
    'Shipped',
    'Delivered',
    'Rejected',
    'Cancelled',
  ];

  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  // Supabase Orders State List - ONLY from database
  List<Map<String, dynamic>> _orders = [];
  RealtimeChannel? _ordersChannel;

  @override
  void initState() {
    super.initState();
    fetchOrders();
    _subscribeToOrdersRealtime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ordersChannel != null) {
      Supabase.instance.client.removeChannel(_ordersChannel!);
    }
    super.dispose();
  }

  // ── REALTIME ORDERS SUBSCRIPTION ───────────────────────────────────────────
  void _subscribeToOrdersRealtime() {
    try {
      final supabase = Supabase.instance.client;
      _ordersChannel = supabase
          .channel('public:orders_realtime_sync')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              debugPrint('🔄 Realtime orders change detected: ${payload.eventType}');
              fetchOrders(showLoading: false);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('⚠️ Supabase Realtime Orders Subscription: $e');
    }
  }

  // ── 1. FETCH ORDERS FROM SUPABASE ──────────────────────────────────────────
  Future<void> fetchOrders({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final supabase = Supabase.instance.client;

      // 1. Fetch orders strictly from Supabase table
      List<dynamic> response;
      try {
        response = await supabase
            .from('orders')
            .select('*')
            .order('created_at', ascending: false);
      } catch (err) {
        debugPrint('⚠️ Direct order fetch note: $err, retrying select...');
        response = await supabase.from('orders').select();
      }

      // 2. Fetch supplemental products & companies lookup maps
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
        debugPrint('⚠️ Error fetching products lookup: $e');
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
        debugPrint('⚠️ Error fetching companies lookup: $e');
      }

      // 3. Enrich orders with products & companies info
      List<Map<String, dynamic>> enrichedOrders = [];
      for (var item in response) {
        final order = Map<String, dynamic>.from(item);

        final pId = order['prod_id']?.toString();
        final cId =
            order['comp_id']?.toString() ?? order['company_id']?.toString();

        if (pId != null && productLookup.containsKey(pId)) {
          order['products'] = productLookup[pId];
        }

        if (cId != null && companyLookup.containsKey(cId)) {
          order['companies'] = companyLookup[cId];
        }

        // If company is still null, attempt lookup via product's company_id
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('❌ Error fetching orders: $e');

      AppToast.showError(
        title: 'Error Fetching Orders',
        message: e.toString().split('\n').first,
      );
    }
  }

  // ── UPDATE ORDER STATUS IN SUPABASE ────────────────────────────────────────
  Future<void> _updateOrderStatus(Map<String, dynamic> order, String newStatus) async {
    final orderId = order['order_id'];
    final dbId = order['id'];
    final statusLower = newStatus.toLowerCase().trim();

    try {
      final supabase = Supabase.instance.client;
      if (dbId != null) {
        await supabase
            .from('orders')
            .update({'status': statusLower})
            .eq('id', dbId);
      } else if (orderId != null) {
        await supabase
            .from('orders')
            .update({'status': statusLower})
            .eq('order_id', orderId);
      }

      // If Admin clicks 'Reject' or 'Cancel Order':
      // Update orders status to 'rejected' and revert product availability back to in stock:
      if (statusLower == 'rejected' || statusLower == 'cancelled') {
        final prodId = order['prod_id'] ?? order['product_id'];
        if (prodId != null) {
          try {
            final pNum = int.tryParse(prodId.toString());
            if (pNum != null) {
              await supabase
                  .from('products')
                  .update({
                    'availability_status': 'in_stock',
                    'is_available': true,
                  })
                  .eq('prod_id', pNum);
            } else {
              await supabase
                  .from('products')
                  .update({
                    'availability_status': 'in_stock',
                    'is_available': true,
                  })
                  .eq('id', prodId.toString());
            }
          } catch (e) {
            debugPrint('⚠️ Error reverting product availability: $e');
            try {
              await supabase
                  .from('products')
                  .update({'availability_status': 'in_stock'})
                  .eq('id', prodId);
            } catch (_) {}
          }
        }

        // Trigger HomeController to update UI immediately
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshAllSections();
        }

        AppToast.showInfo(
          context: context,
          title: 'Order Rejected',
          message: 'Order rejected. Item is back in stock.',
        );
      } else {
        // If Admin clicks 'Dispatch' or 'Accept':
        // Product remains 'out_of_stock'
        AppToast.showSuccess(
          context: context,
          title: 'Status Updated',
          message: statusLower == 'dispatched'
              ? 'Order marked as Dispatched'
              : 'Order status changed to $newStatus',
        );
      }

      fetchOrders(showLoading: false);
    } catch (e) {
      AppToast.showError(
        context: context,
        title: 'Update Failed',
        message: e.toString().split('\n').first,
      );
    }
  }

  // ── UPDATE PAYMENT STATUS IN SUPABASE ──────────────────────────────────────
  Future<void> _togglePaymentStatus(Map<String, dynamic> order) async {
    final bool currentPaid = order['payment_status'] == true ||
        order['payment_status']?.toString().toUpperCase() == 'TRUE' ||
        order['payment_status']?.toString().toUpperCase() == 'PAID';
    final bool newPaid = !currentPaid;

    final orderId = order['order_id'];
    final dbId = order['id'];

    try {
      final supabase = Supabase.instance.client;
      if (dbId != null) {
        await supabase
            .from('orders')
            .update({'payment_status': newPaid})
            .eq('id', dbId);
      } else if (orderId != null) {
        await supabase
            .from('orders')
            .update({'payment_status': newPaid})
            .eq('order_id', orderId);
      }

      if (newPaid) {
        AppToast.showSuccess(
          title: 'Payment Status',
          message: 'Order marked as PAID',
        );
      } else {
        AppToast.showWarning(
          title: 'Payment Status',
          message: 'Order marked as UNPAID',
        );
      }

      fetchOrders(showLoading: false);
    } catch (e) {
      AppToast.showError(
        title: 'Update Failed',
        message: e.toString().split('\n').first,
      );
    }
  }

  // ── FILTERED ORDERS GETTER ─────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) {
      final orderStatus = (order['status'] ?? 'Created').toString().toLowerCase();
      final matchesFilter = _selectedFilter == 'All' ||
          orderStatus == _selectedFilter.toLowerCase();

      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) return matchesFilter;

      final orderId = (order['order_id'] ?? '').toString().toLowerCase();
      final customerName =
          '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'
              .toLowerCase();
      final phone = (order['phone_no'] ?? '').toString().toLowerCase();

      final productData = order['products'] as Map<String, dynamic>?;
      final addressData = order['address'];
      final shoeName = (productData?['title'] ??
              productData?['name'] ??
              (addressData is Map ? addressData['product_name'] : null) ??
              '')
          .toString()
          .toLowerCase();
      final city = (addressData is Map ? addressData['city'] ?? '' : '')
          .toString()
          .toLowerCase();

      final matchesQuery = orderId.contains(query) ||
          customerName.contains(query) ||
          phone.contains(query) ||
          shoeName.contains(query) ||
          city.contains(query);

      return matchesFilter && matchesQuery;
    }).toList();
  }

  // ── HELPER FORMATTERS ──────────────────────────────────────────────────────
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Just now';
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
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $ampm';
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFFDCFCE7); // Soft Green
      case 'dispatched':
      case 'shipped':
        return const Color(0xFFDBEAFE); // Soft Blue
      case 'created':
      case 'processing':
        return const Color(0xFFFFEDD5); // Soft Orange
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFEE2E2); // Soft Red
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF15803D); // Green text
      case 'dispatched':
      case 'shipped':
        return const Color(0xFF1D4ED8); // Blue text
      case 'created':
      case 'processing':
        return const Color(0xFFC2410C); // Orange text
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFB91C1C); // Red text
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredOrders;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. TOP APP BAR ──
            _buildTopAppBar(),

            // ── SEARCH BAR (Toggleable) ──
            if (_isSearchActive) _buildSearchBar(),

            // ── 2. HORIZONTAL FILTER BAR ──
            _buildFilterBar(),

            const SizedBox(height: 8),

            // ── 3. MAIN ORDERS BODY ──
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      itemCount: 5,
                      itemBuilder: (context, index) => const AppOrderItemShimmer(),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchOrders,
                      color: primaryBlue,
                      child: filteredList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final order = filteredList[index];
                                return _buildOrderCard(order);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. TOP APP BAR ──────────────────────────────────────────────────────────
  Widget _buildTopAppBar() {
    final totalCount = _orders.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button
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
                  border: Border.all(color: subtleBorder, width: 1),
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

          // Centered Title with Count Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ResponsiveText(
                'Order Management',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ResponsiveText(
                  '$totalCount Total',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: primaryBlue,
                ),
              ),
            ],
          ),

          // Actions: Search & Refresh
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refresh Button
                InkWell(
                  onTap: () => fetchOrders(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: subtleBorder, width: 1),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: textDark,
                      size: 20,
                    ),
                  ),
                ),

                // Search Toggle Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isSearchActive = !_isSearchActive;
                      if (!_isSearchActive) _searchController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isSearchActive
                          ? primaryBlue.withValues(alpha: 0.12)
                          : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isSearchActive ? primaryBlue : subtleBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
                      color: _isSearchActive ? primaryBlue : textDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR WIDGET ───────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: primaryBlue.withValues(alpha: 0.3), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          decoration: const InputDecoration(
            hintText: 'Search by Order ID, Customer, Shoe, City...',
            hintStyle: TextStyle(fontSize: 13, color: textMuted),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: primaryBlue, size: 20),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── 2. HORIZONTAL FILTER BAR ───────────────────────────────────────────────
  Widget _buildFilterBar() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        itemCount: _filterCategories.length,
        itemBuilder: (context, index) {
          final category = _filterCategories[index];
          final bool isSelected = _selectedFilter == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = category;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryBlue : subtleBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Center(
                  child: ResponsiveText(
                    category,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : textMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 3. ORDER LIST CARD ─────────────────────────────────────────────────────
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String currentStatus =
        (order['status'] ?? 'Created').toString().capitalizeFirst ?? 'Created';
    final bool isPaid = order['payment_status'] == true ||
        order['payment_status']?.toString().toUpperCase() == 'TRUE' ||
        order['payment_status']?.toString().toUpperCase() == 'PAID';

    // Extracted Fields strictly from Database
    final String orderId = order['order_id'] ?? '#ORD-${order['id']}';
    final String formattedDate = _formatDate(order['created_at']);

    // Product Info
    final productData = order['products'] as Map<String, dynamic>?;
    final companyData = order['companies'] as Map<String, dynamic>?;
    final addressData = order['address'];

    final String shoeName = productData?['title'] ??
        productData?['name'] ??
        (addressData is Map
            ? (addressData['product_name'] ?? addressData['shoe_name'])
            : null) ??
        'Shoe Product #${order['prod_id'] ?? ''}'.trim();

    final String brandName = companyData?['name'] ??
        companyData?['title'] ??
        (addressData is Map ? addressData['company_name'] : null) ??
        'Brand';

    final String? shoeImageUrl = productData?['product_img_url'] ??
        productData?['image'] ??
        productData?['image_url'] ??
        (addressData is Map ? addressData['product_image'] : null);

    final double priceValue =
        double.tryParse(order['price']?.toString() ?? '0') ?? 0.0;

    // Customer Info
    String firstName = (order['first_name'] ?? '').toString().trim();
    String lastName = (order['last_name'] ?? '').toString().trim();

    if (firstName.isEmpty && addressData is Map) {
      firstName = (addressData['first_name'] ?? '').toString().trim();
      lastName = (addressData['last_name'] ?? '').toString().trim();
    }
    final String customerFullName =
        ('$firstName $lastName').trim().isNotEmpty
            ? ('$firstName $lastName').trim()
            : 'Customer';

    final String phoneNo =
        (order['phone_no'] ?? order['phone'] ?? (addressData is Map ? addressData['phone_no'] : null) ?? 'N/A')
            .toString();

    String formattedLocation = 'Location not specified';
    if (addressData is Map) {
      formattedLocation = addressData['location'] ??
          addressData['full_address'] ??
          '${addressData['city'] ?? ""}, ${addressData['street'] ?? ""}';
    } else if (addressData != null) {
      formattedLocation = addressData.toString();
    }

    final int? orderedQty = addressData is Map && addressData['quantity'] != null
        ? int.tryParse(addressData['quantity'].toString())
        : null;
    final int? orderedSize =
        addressData is Map && addressData['selected_size'] != null
            ? int.tryParse(addressData['selected_size'].toString())
            : null;

    return InkWell(
      onTap: () => _showOrderDetailsBottomSheet(order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: subtleBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ROW (Order ID Chip + Date + Status Tag) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Order ID Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ResponsiveText(
                          orderId,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Relative Date Text
                      ResponsiveText(
                        formattedDate,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ],
                  ),

                  // Status Tag with Quick Change Tap
                  InkWell(
                    onTap: () => _showChangeStatusDialog(order),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(currentStatus),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ResponsiveText(
                            currentStatus,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _getStatusTextColor(currentStatus),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 14,
                            color: _getStatusTextColor(currentStatus),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── SHOE DETAILS SECTION ──
              Row(
                children: [
                  // Rounded square container for shoe image
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: subtleBorder, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: shoeImageUrl != null &&
                                shoeImageUrl.startsWith('http')
                            ? Image.network(
                                shoeImageUrl,
                                width: 54,
                                height: 54,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  AppImages.boot,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                AppImages.boot,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Shoe details column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          shoeName,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ResponsiveText(
                                brandName,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textMuted,
                              ),
                            ),
                            if (orderedSize != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ResponsiveText(
                                  'Size $orderedSize',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                            if (orderedQty != null && orderedQty > 1) ...[
                              const SizedBox(width: 6),
                              ResponsiveText(
                                'x$orderedQty',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Total Price
                  ResponsiveText(
                    '\$${priceValue.toStringAsFixed(2)}',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── CUSTOMER INFORMATION TILE ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: softGreyTile,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: subtleBorder, width: 1),
                ),
                child: Column(
                  children: [
                    // Customer Name & Payment Status Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            ResponsiveText(
                              customerFullName,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ],
                        ),
                        // Payment Status Chip (Tappable to toggle)
                        InkWell(
                          onTap: () => _togglePaymentStatus(order),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ResponsiveText(
                              isPaid ? 'PAID' : 'UNPAID',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isPaid
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF9A3412),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Phone Row
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 15,
                          color: textMuted,
                        ),
                        const SizedBox(width: 8),
                        ResponsiveText(
                          phoneNo,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: textDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Address Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ResponsiveText(
                            formattedLocation,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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

  // ── CHANGE STATUS DIALOG ───────────────────────────────────────────────────
  void _showChangeStatusDialog(Map<String, dynamic> order) {
    final String currentStatus =
        (order['status'] ?? 'Created').toString().capitalizeFirst ?? 'Created';
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ResponsiveText(
                        'Update Order Status',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppAnimatedDropdown<String>(
                    label: 'Order Status',
                    hint: 'Select Status',
                    value: selectedStatus,
                    items: const [
                      'Created',
                      'Processing',
                      'Dispatched',
                      'Shipped',
                      'Delivered',
                      'Rejected',
                      'Cancelled'
                    ],
                    itemLabel: (status) => status,
                    prefixIcon: Icons.local_shipping_outlined,
                    isRequired: true,
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        Navigator.of(ctx).pop();
                        _updateOrderStatus(order, newStatus);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── FULL ORDER DETAILS BOTTOM SHEET ─────────────────────────────────────────
  void _showOrderDetailsBottomSheet(Map<String, dynamic> order) {
    final String currentStatus =
        (order['status'] ?? 'Created').toString().capitalizeFirst ?? 'Created';
    final bool isPaid = order['payment_status'] == true ||
        order['payment_status']?.toString().toUpperCase() == 'TRUE' ||
        order['payment_status']?.toString().toUpperCase() == 'PAID';

    final String orderId = order['order_id'] ?? '#ORD-${order['id']}';
    final String formattedDate = _formatDate(order['created_at']);

    final productData = order['products'] as Map<String, dynamic>?;
    final companyData = order['companies'] as Map<String, dynamic>?;
    final addressData = order['address'];

    final String shoeName = productData?['title'] ??
        productData?['name'] ??
        (addressData is Map
            ? (addressData['product_name'] ?? addressData['shoe_name'])
            : null) ??
        'Shoe Product #${order['prod_id'] ?? ''}'.trim();

    final String brandName = companyData?['name'] ??
        companyData?['title'] ??
        (addressData is Map ? addressData['company_name'] : null) ??
        'Brand';

    final String? shoeImageUrl = productData?['product_img_url'] ??
        productData?['image'] ??
        productData?['image_url'] ??
        (addressData is Map ? addressData['product_image'] : null);

    final double priceValue =
        double.tryParse(order['price']?.toString() ?? '0') ?? 0.0;

    String firstName = (order['first_name'] ?? '').toString().trim();
    String lastName = (order['last_name'] ?? '').toString().trim();
    if (firstName.isEmpty && addressData is Map) {
      firstName = (addressData['first_name'] ?? '').toString().trim();
      lastName = (addressData['last_name'] ?? '').toString().trim();
    }
    final String customerFullName =
        ('$firstName $lastName').trim().isNotEmpty
            ? ('$firstName $lastName').trim()
            : 'Customer';

    final String phoneNo =
        (order['phone_no'] ?? order['phone'] ?? (addressData is Map ? addressData['phone_no'] : null) ?? 'N/A')
            .toString();
    final String email = (order['email'] ?? (addressData is Map ? addressData['email'] : null) ?? 'N/A').toString();

    String formattedLocation = 'Location not specified';
    if (addressData is Map) {
      formattedLocation = addressData['location'] ??
          addressData['full_address'] ??
          '${addressData['city'] ?? ""}, ${addressData['street'] ?? ""} ${addressData['house'] ?? ""}';
    }

    final int? orderedQty = addressData is Map && addressData['quantity'] != null
        ? int.tryParse(addressData['quantity'].toString())
        : null;
    final int? orderedSize =
        addressData is Map && addressData['selected_size'] != null
            ? int.tryParse(addressData['selected_size'].toString())
            : null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        orderId,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                      const SizedBox(height: 2),
                      ResponsiveText(
                        formattedDate,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: orderId));
                      AppToast.showInfo(
                        context: context,
                        title: 'Copied',
                        message: 'Order ID copied to clipboard',
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: softGreyTile,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: subtleBorder),
                      ),
                      child: const Icon(Icons.copy_rounded, size: 16, color: primaryBlue),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Product Info Tile
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: softGreyTile,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subtleBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: shoeImageUrl != null && shoeImageUrl.startsWith('http')
                            ? Image.network(shoeImageUrl, fit: BoxFit.contain)
                            : Image.asset(AppImages.boot, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveText(
                            shoeName,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                          const SizedBox(height: 4),
                          ResponsiveText(
                            brandName,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (orderedSize != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ResponsiveText(
                                    'Size: $orderedSize',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBlue,
                                  ),
                                ),
                              if (orderedQty != null) ...[
                                const SizedBox(width: 8),
                                ResponsiveText(
                                  'Qty: $orderedQty',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    ResponsiveText(
                      '\$${priceValue.toStringAsFixed(2)}',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: primaryBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Customer & Address Details
              const ResponsiveText(
                'Customer & Delivery Details',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: softGreyTile,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subtleBorder),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.person_outline_rounded, 'Customer', customerFullName),
                    const Divider(height: 16),
                    _buildDetailRow(Icons.phone_outlined, 'Phone', phoneNo,
                        isActionable: true, onAction: () {
                      Clipboard.setData(ClipboardData(text: phoneNo));
                      AppToast.showInfo(
                        context: context,
                        title: 'Copied',
                        message: 'Phone number copied to clipboard',
                      );
                    }),
                    if (email.isNotEmpty && email != 'N/A') ...[
                      const Divider(height: 16),
                      _buildDetailRow(Icons.email_outlined, 'Email', email,
                          isActionable: true, onAction: () {
                        Clipboard.setData(ClipboardData(text: email));
                        AppToast.showInfo(
                          context: context,
                          title: 'Copied',
                          message: 'Email copied to clipboard',
                        );
                      }),
                    ],
                    const Divider(height: 16),
                    _buildDetailRow(Icons.location_on_outlined, 'Address', formattedLocation),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Status Actions: Dispatch or Reject
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _updateOrderStatus(order, 'Dispatched');
                      },
                      icon: const Icon(Icons.local_shipping_rounded, size: 16),
                      label: const Text('Dispatch Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B96E6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _updateOrderStatus(order, 'Rejected');
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Reject Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Dropdown & Payment Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        _showChangeStatusDialog(order);
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: Text('Status: $currentStatus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                        side: const BorderSide(color: primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _togglePaymentStatus(order);
                      },
                      icon: Icon(
                          isPaid ? Icons.check_circle_outline : Icons.payment_rounded,
                          size: 18),
                      label: Text(isPaid ? 'Mark UNPAID' : 'Mark PAID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPaid ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isActionable = false, VoidCallback? onAction}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: primaryBlue),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: ResponsiveText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
        Expanded(
          child: ResponsiveText(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        if (isActionable && onAction != null)
          InkWell(
            onTap: onAction,
            child: const Icon(Icons.copy_rounded, size: 14, color: textMuted),
          ),
      ],
    );
  }

  // ── EMPTY STATE WIDGET ──────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 38,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const ResponsiveText(
              'No Orders Found',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
            const SizedBox(height: 6),
            ResponsiveText(
              _selectedFilter == 'All'
                  ? 'There are currently no orders in the database.'
                  : 'No orders match the "$_selectedFilter" status.',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textMuted,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => fetchOrders(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh Orders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
