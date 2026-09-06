import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  // Bottom Bar tab selection
  final RxInt selectedIndex = 0.obs;

  // Selected company ID for the Brand/Popular Shoes tab (null or 'all' represents 'All Brands')
  final Rxn<String> selectedCompanyId = Rxn<String>(null);

  // Loading states for distinct sections
  final RxBool isLoadingCompanies = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingAllProducts = false.obs;
  final RxBool isLoadingNewArrivals = false.obs;
  final RxBool isLoadingDiscountProducts = false.obs;

  // Dynamic list of active companies from Supabase
  final RxList<Map<String, dynamic>> companies = <Map<String, dynamic>>[].obs;

  // Category name for display
  final RxString selectedCategory = 'All Brands'.obs;

  // 1. All products across ALL brands (for Admin, Search, and Global catalog)
  final RxList<Product> allProducts = <Product>[].obs;

  // 2. Products for the currently selected brand tab (Popular Shoes section)
  final RxList<Product> brandProducts = <Product>[].obs;

  // Backward compatibility alias: `products` points to `brandProducts`
  RxList<Product> get products => brandProducts;

  // 3. New Arrivals products (decoupled from brand tab)
  final RxList<Product> newArrivalProducts = <Product>[].obs;

  // 4. Special discount deals / offers products (decoupled from brand tab)
  final RxList<Product> discountProducts = <Product>[].obs;

  late PageController newArrivalsPageController;
  final Map<String, ScrollController> brandScrollControllers = {};
  Timer? _autoScrollTimer;

  RealtimeChannel? _companyChannel;
  RealtimeChannel? _productChannel;

  ScrollController getScrollController(String brand) {
    if (!brandScrollControllers.containsKey(brand)) {
      brandScrollControllers[brand] = ScrollController();
    }
    return brandScrollControllers[brand]!;
  }

  @override
  void onInit() {
    super.onInit();
    newArrivalsPageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
    _initData();
    _subscribeRealtime();
  }

  Future<void> _initData() async {
    await fetchCompanies();
    await Future.wait([
      fetchAllProducts(),
      fetchBrandProducts(),
      fetchNewArrivalProducts(),
      fetchDiscountProducts(),
    ]);
  }

  void _subscribeRealtime() {
    try {
      _companyChannel = supabase
          .channel('public:companies:home')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'companies',
            callback: (payload) {
              debugPrint('🔄 Realtime company change detected on Home Screen!');
              fetchCompanies();
            },
          )
          .subscribe();

      _productChannel = supabase
          .channel('public:products:home')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            callback: (payload) {
              debugPrint('🔄 Realtime product change detected on Home Screen!');
              refreshAllSections();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('⚠️ Supabase Realtime Subscription notice: $e');
    }
  }

  /// Refreshes all product sections in parallel
  Future<void> refreshAllSections() async {
    await Future.wait([
      fetchAllProducts(),
      fetchBrandProducts(),
      fetchNewArrivalProducts(),
      fetchDiscountProducts(),
    ]);
  }

  @override
  void onClose() {
    newArrivalsPageController.dispose();
    for (var controller in brandScrollControllers.values) {
      controller.dispose();
    }
    _autoScrollTimer?.cancel();
    if (_companyChannel != null) supabase.removeChannel(_companyChannel!);
    if (_productChannel != null) supabase.removeChannel(_productChannel!);
    super.onClose();
  }

  /// ── 1. FETCH COMPANIES (Active companies from Supabase) ──
  Future<void> fetchCompanies() async {
    isLoadingCompanies.value = true;
    try {
      debugPrint('⏳ Fetching active companies from Supabase "companies" table...');
      final response = await supabase
          .from('companies')
          .select()
          .eq('is_active', true);

      final List<Map<String, dynamic>> fetched =
          List<Map<String, dynamic>>.from(response as List);

      companies.assignAll(fetched);
      debugPrint('✅ Fetched ${fetched.length} active companies from Supabase.');

      // Default brand tab: Select first brand for Popular section if nothing is selected
      if (companies.isNotEmpty && selectedCompanyId.value == null) {
        selectedCompanyId.value = companies.first['id']?.toString();
        selectedCategory.value = companies.first['name']?.toString() ?? 'All Brands';
      }
    } catch (e) {
      debugPrint('❌ Error fetching companies from Supabase: $e');
    } finally {
      isLoadingCompanies.value = false;
    }
  }

  /// ── 2. FETCH ALL PRODUCTS (Global catalog, Admin Panel, Search) ──
  /// NEVER locks by company_id. Loads everything from Supabase.
  Future<void> fetchAllProducts() async {
    isLoadingAllProducts.value = true;
    try {
      debugPrint('⏳ Fetching ALL products from Supabase (Global)...');
      final List<dynamic> response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      final List<Product> fetched = response.map((json) {
        final compId = json['company_id']?.toString();
        final compName = getCompanyNameById(compId);
        return Product.fromSupabaseJson(
          Map<String, dynamic>.from(json),
          categoryName: compName,
        );
      }).toList();

      allProducts.assignAll(fetched);
      debugPrint('✅ Fetched ${fetched.length} total products globally.');
    } catch (e) {
      debugPrint('❌ Error fetching all products: $e');
    } finally {
      isLoadingAllProducts.value = false;
    }
  }

  /// ── 3. FETCH BRAND PRODUCTS (Popular Shoes Section) ──
  /// Only applies .eq('company_id', companyId) if a specific company is explicitly selected
  Future<void> fetchBrandProducts() async {
    isLoadingProducts.value = true;
    try {
      final activeCompanyId = selectedCompanyId.value;
      final bool isExplicitCompanySelected = activeCompanyId != null &&
          activeCompanyId.isNotEmpty &&
          activeCompanyId.toLowerCase() != 'all';

      final dynamic response;
      if (isExplicitCompanySelected) {
        debugPrint('⏳ Fetching brand products for company_id=$activeCompanyId...');
        response = await supabase
            .from('products')
            .select()
            .eq('company_id', activeCompanyId)
            .order('created_at', ascending: false);
      } else {
        debugPrint('⏳ Fetching popular products for all brands...');
        response = await supabase
            .from('products')
            .select()
            .order('created_at', ascending: false);
      }

      if (response is List) {
        final List<Product> fetchedProducts = response.map((json) {
          final compId = json['company_id']?.toString();
          final compName = getCompanyNameById(compId);
          return Product.fromSupabaseJson(
            Map<String, dynamic>.from(json),
            categoryName: compName,
          );
        }).toList();

        brandProducts.assignAll(fetchedProducts);
        debugPrint('✅ Fetched ${fetchedProducts.length} brand products.');
      }
    } catch (e) {
      debugPrint('❌ Error fetching brand products: $e');
      if (brandProducts.isEmpty && allProducts.isNotEmpty) {
        brandProducts.assignAll(allProducts);
      }
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Alias fetchProducts to fetchBrandProducts for any external callers
  Future<void> fetchProducts() => fetchBrandProducts();

  /// ── 4. FETCH NEW ARRIVALS (Completely Decoupled from Brand Selector) ──
  /// Fetches products where is_new_arrival = true, or latest products sorted by created_at
  Future<void> fetchNewArrivalProducts() async {
    isLoadingNewArrivals.value = true;
    try {
      debugPrint('⏳ Fetching New Arrivals independently...');
      List<dynamic> response = [];

      try {
        response = await supabase
            .from('products')
            .select()
            .eq('is_new_arrival', true)
            .order('created_at', ascending: false);
      } catch (err) {
        debugPrint('⚠️ Note on is_new_arrival column query: $err');
      }

      // If no explicit is_new_arrival items, fallback to latest products
      if (response.isEmpty) {
        response = await supabase
            .from('products')
            .select()
            .order('created_at', ascending: false)
            .limit(10);
      }

      final List<Product> fetchedNewArrivals = response.map((json) {
        final compId = json['company_id']?.toString();
        final compName = getCompanyNameById(compId);
        return Product.fromSupabaseJson(
          Map<String, dynamic>.from(json),
          categoryName: compName,
        );
      }).toList();

      newArrivalProducts.assignAll(fetchedNewArrivals);
      debugPrint('✅ Fetched ${fetchedNewArrivals.length} new arrival products.');
    } catch (e) {
      debugPrint('❌ Error fetching new arrival products: $e');
    } finally {
      isLoadingNewArrivals.value = false;
    }
  }

  /// ── 5. FETCH SPECIAL OFFERS / DISCOUNT PRODUCTS (Completely Decoupled) ──
  /// Fetches products where is_special = true, is_special_offer = true, or has_discount = true
  Future<void> fetchDiscountProducts() async {
    isLoadingDiscountProducts.value = true;
    try {
      debugPrint('⏳ Fetching Special Offers / Discount Deals independently...');
      List<dynamic> response = [];

      try {
        response = await supabase
            .from('products')
            .select()
            .or('is_special.eq.true,has_discount.eq.true,is_special_offer.eq.true')
            .order('created_at', ascending: false);
      } catch (err) {
        debugPrint('⚠️ Note on combined discount query: $err, falling back to is_special...');
        try {
          response = await supabase
              .from('products')
              .select()
              .eq('is_special', true);
        } catch (_) {
          try {
            response = await supabase
                .from('products')
                .select()
                .eq('has_discount', true);
          } catch (_) {
            response = [];
          }
        }
      }

      // If response is empty, select items with discount percentage > 0 or status containing 'special'
      if (response.isEmpty && allProducts.isNotEmpty) {
        final localSpecials = allProducts
            .where((p) => p.isSpecialOffer || p.hasDiscount || p.status.toLowerCase().contains('special'))
            .toList();
        if (localSpecials.isNotEmpty) {
          discountProducts.assignAll(localSpecials);
          isLoadingDiscountProducts.value = false;
          return;
        }
      }

      final List<Product> fetchedDiscounts = response.map((json) {
        final compId = json['company_id']?.toString();
        final compName = getCompanyNameById(compId);
        return Product.fromSupabaseJson(
          Map<String, dynamic>.from(json),
          categoryName: compName,
        );
      }).toList();

      discountProducts.assignAll(fetchedDiscounts);
      debugPrint('✅ Fetched ${fetchedDiscounts.length} special deal products.');
    } catch (e) {
      debugPrint('❌ Error fetching special deal products: $e');
    } finally {
      isLoadingDiscountProducts.value = false;
    }
  }

  /// Helper to get company name by company ID
  String getCompanyNameById(String? compId) {
    if (compId == null) return 'All Brands';
    final comp = companies.firstWhereOrNull(
      (c) => c['id']?.toString() == compId.toString(),
    );
    if (comp != null && comp['name'] != null) {
      return comp['name'].toString();
    }
    return 'Brand';
  }

  /// ── 6. UI STATE MANAGEMENT (Select Company Chip) ──
  /// When a brand is selected, it ONLY updates Popular Shoes (brandProducts).
  /// New Arrivals and Special Offers remain independent!
  void selectCompany(String? companyId) {
    selectedCompanyId.value = companyId;
    final compName = getCompanyNameById(companyId);
    selectedCategory.value = compName;
    fetchBrandProducts();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final newArrivalsCount = newArrivalProducts.length;
      if (newArrivalsCount <= 1) return;

      if (newArrivalsPageController.hasClients) {
        final currentPage = newArrivalsPageController.page?.round() ?? 0;
        final nextPage = currentPage + 1;

        if (nextPage >= newArrivalsCount) {
          newArrivalsPageController.jumpToPage(0);
        } else {
          newArrivalsPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    if (category.toLowerCase() == 'all' || category.toLowerCase() == 'all brands') {
      selectCompany(null);
      return;
    }
    final match = companies.firstWhereOrNull(
      (c) => (c['name'] ?? '').toString().toLowerCase() == category.toLowerCase(),
    );
    selectCompany(match != null ? match['id']?.toString() : null);
  }

  void toggleFavorite(String productId) {
    // Check across all lists
    for (var list in [allProducts, brandProducts, newArrivalProducts, discountProducts]) {
      final index = list.indexWhere((p) => p.id == productId);
      if (index != -1) {
        list[index].isFavorite.value = !list[index].isFavorite.value;
        list.refresh();
      }
    }
  }

  void addProduct(Product product) {
    allProducts.insert(0, product);
    brandProducts.insert(0, product);
    if (product.isNewArrival) newArrivalProducts.insert(0, product);
    if (product.isSpecialOffer || product.hasDiscount) discountProducts.insert(0, product);
    allProducts.refresh();
    brandProducts.refresh();
  }

  void updateProduct(Product updatedProduct) {
    for (var list in [allProducts, brandProducts, newArrivalProducts, discountProducts]) {
      final index = list.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        list[index] = updatedProduct;
        list.refresh();
      }
    }
  }

  void deleteProduct(String productId) {
    allProducts.removeWhere((p) => p.id == productId);
    brandProducts.removeWhere((p) => p.id == productId);
    newArrivalProducts.removeWhere((p) => p.id == productId);
    discountProducts.removeWhere((p) => p.id == productId);
    allProducts.refresh();
    brandProducts.refresh();
  }

  // Filtered products list (returns current brand products list)
  List<Product> get filteredProducts => brandProducts;

  // List of favorite products (checked from allProducts)
  List<Product> get favoriteProducts {
    return allProducts.where((p) => p.isFavorite.value).toList();
  }
}
