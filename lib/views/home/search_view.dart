import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/responsive_text.dart';
import 'home_view.dart';
import 'product_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  final List<String> _recentSearches = const [
    'Nike Air Max Shoes',
    'Nike Jordan Shoes',
    'Nike Air Force Shoes',
    'Nike Club Max Shoes',
    'Snakers Nike Shoes',
    'Regular Shoes',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus search text field on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── TOP BAR (Back Button <, Title "Search", Action "Cancel") ────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
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

                  // Center Title
                  ResponsiveText(
                    'Search',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                    usePlayfair: true,
                  ),

                  // Cancel Button
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _focusNode.unfocus();
                    },
                    child: const ResponsiveText(
                      'Cancel',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onboardingBtn,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── SEARCH INPUT TEXT FIELD ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingTitle,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Your Shoes',
                    hintStyle: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.shade400,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── RECENT SEARCHES OR SEARCH RESULTS CONTENT ────────────────────
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildRecentSearchesList(size)
                  : _buildSearchResultsGrid(controller, size),
            ),
          ],
        ),
      ),
    );
  }

  // ── RECENT SEARCH HISTORY LIST MATCHING MOCKUP ────────────────────────────
  Widget _buildRecentSearchesList(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Shoes',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.onboardingTitle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final searchItem = _recentSearches[index];
                return GestureDetector(
                  onTap: () {
                    _searchController.text = searchItem;
                    setState(() {
                      _searchQuery = searchItem;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        ResponsiveText(
                          searchItem,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onboardingTitle.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTERED SEARCH RESULTS GRID WITH STAGGERED ANIMATIONS ────────────────
  Widget _buildSearchResultsGrid(HomeController controller, Size size) {
    final query = _searchQuery.toLowerCase();
    final sourceList = controller.allProducts.isNotEmpty
        ? controller.allProducts
        : controller.products;
    final matchingProducts = sourceList.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
    }).toList();

    if (matchingProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            ResponsiveText(
              'No shoes found for "$_searchQuery"',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingSub,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: matchingProducts.length,
      itemBuilder: (context, index) {
        final product = matchingProducts[index];
        return ScaleFadeShuffleWidget(
          index: index,
          child: _buildSearchResultCard(product),
        );
      },
    );
  }

  Widget _buildSearchResultCard(Product product) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailView(
            product: product,
            heroTag: 'search_result_${product.id}',
          )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'search_result_${product.id}',
                  child: product.image.startsWith('http')
                      ? Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const ShimmerImageLoader(
                              width: 110,
                              height: 90,
                              borderRadius: 12,
                            );
                          },
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/shoe_nike_1.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          product.image,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              'BEST SELLER',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onboardingBtn,
            ),
            const SizedBox(height: 2),
            ResponsiveText(
              product.name,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.onboardingTitle,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            ResponsiveText(
              "Men's Shoes",
              fontSize: 11,
              color: AppColors.onboardingSub,
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              '\$${product.price.toStringAsFixed(2)}',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.onboardingTitle,
            ),
          ],
        ),
      ),
    );
  }
}
