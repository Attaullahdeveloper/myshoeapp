import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';

class HomeController extends GetxController {
  // Bottom Bar tab selection
  final RxInt selectedIndex = 0.obs;

  // Brand Category selection
  final RxString selectedCategory = 'Nike'.obs;

  // List of all mock products
  final RxList<Product> products = <Product>[].obs;

  // List of brands with their asset paths
  final List<Map<String, String>> brands = [
    {'name': 'Nike', 'logo': 'assets/images/brand_nike.png'},
    {'name': 'Puma', 'logo': 'assets/images/brand_puma.png'},
    {'name': 'Adidas', 'logo': 'assets/images/brand_adidas.png'},
    {'name': 'Converse', 'logo': 'assets/images/brand_converse.png'},
    {'name': 'UA', 'logo': 'assets/images/brand_ua.png'},
  ];

  late PageController newArrivalsPageController;
  final Map<String, ScrollController> brandScrollControllers = {};
  Timer? _autoScrollTimer;

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
    _loadMockProducts();
    _startAutoScroll();
  }

  @override
  void onClose() {
    newArrivalsPageController.dispose();
    for (var controller in brandScrollControllers.values) {
      controller.dispose();
    }
    _autoScrollTimer?.cancel();
    super.onClose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final newArrivalsCount = newArrivalProducts.length;
      if (newArrivalsCount <= 1) return;

      if (newArrivalsPageController.hasClients) {
        final currentPage = newArrivalsPageController.page?.round() ?? 0;
        final nextPage = currentPage + 1;

        if (nextPage >= newArrivalsCount) {
          // Instant Jump back to the start (Clean & Simple, no back-scroll animation)
          newArrivalsPageController.jumpToPage(0);
        } else {
          // Smooth slide forward to the next page
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
  }

  void toggleFavorite(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index].isFavorite.value = !products[index].isFavorite.value;
      products.refresh(); // Notify listeners of list changes
    }
  }

  void addProduct(Product product) {
    products.insert(0, product);
    products.refresh();
  }

  void updateProduct(Product updatedProduct) {
    final index = products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      products[index] = updatedProduct;
      products.refresh();
    }
  }

  void deleteProduct(String productId) {
    products.removeWhere((p) => p.id == productId);
    products.refresh();
  }

  // Filtered products list based on selected category
  List<Product> get filteredProducts {
    return products.where((p) => p.category.toLowerCase() == selectedCategory.value.toLowerCase()).toList();
  }

  // List of favorite products
  List<Product> get favoriteProducts {
    return products.where((p) => p.isFavorite.value).toList();
  }

  // List of new arrivals products
  List<Product> get newArrivalProducts {
    return products.where((p) => p.isNewArrival).toList();
  }

  void _loadMockProducts() {
    products.assignAll([
      Product(
        id: 'nike_1',
        name: 'Nike Jordan',
        category: 'Nike',
        price: 240.00,
        image: 'assets/images/shoe_nike_1.png',
        rating: 4.8,
        isBestSeller: true,
        description: 'The Nike Air Max 270 delivers visible air under every step. Updated for modern comfort, it nods to the original 1991 Air Max 180.',
      ),
      Product(
        id: 'nike_2',
        name: 'Nike Max',
        category: 'Nike',
        price: 180.00,
        image: 'assets/images/shoe_nike_2.png',
        rating: 4.5,
        isBestSeller: true,
        description: 'The Nike Joyride Run Flyknit is designed to help make running feel easier and give your legs a day off. Tiny foam beads underfoot conform to your foot.',
      ),
      Product(
        id: 'nike_3',
        name: 'Nike Air Max 90',
        category: 'Nike',
        price: 210.00,
        image: 'assets/images/shoe_nike_3.png',
        rating: 4.7,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Clean lines, versatile and timeless. The peoples shoe returns with the Nike Air Max 90, featuring the iconic Waffle sole.',
      ),
      Product(
        id: 'nike_4',
        name: 'Nike VaporMax',
        category: 'Nike',
        price: 220.00,
        image: 'assets/images/shoe_nike_2.png',
        rating: 4.6,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Features a revolutionary VaporMax Air cushioning system from heel to toe, delivering an incredibly light, bouncy ride.',
      ),
      Product(
        id: 'nike_5',
        name: 'Nike Air Force 1',
        category: 'Nike',
        price: 130.00,
        image: 'assets/images/shoe_nike_1.png',
        rating: 4.8,
        isBestSeller: true,
        isNewArrival: true,
        description: 'The legend lives on in the Nike Air Force 1, featuring classic court style and premium Air cushioning.',
      ),
      Product(
        id: 'puma_1',
        name: 'Puma RS-X Bold',
        category: 'Puma',
        price: 150.00,
        image: 'assets/images/shoe_nike_1.png',
        rating: 4.3,
        isBestSeller: true,
        description: 'X marks extreme. Exaggerated. RS-X Bold features chunky retro silhouette with bold brandings and premium materials.',
      ),
      Product(
        id: 'puma_2',
        name: 'Puma Rider Play',
        category: 'Puma',
        price: 120.00,
        image: 'assets/images/shoe_nike_3.png',
        rating: 4.4,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Inspired by the Fast Rider from 1980, the Future Rider features a slim, shock-absorbing Federbein outsole and super-comfortable Rider Foam.',
      ),
      Product(
        id: 'adidas_1',
        name: 'Adidas Ultraboost',
        category: 'Adidas',
        price: 200.00,
        image: 'assets/images/boot.png',
        rating: 4.9,
        isBestSeller: true,
        description: 'Prototype after prototype. Innovation after innovation. Meet the pinnacle harmonization of weight, cushioning, and responsiveness.',
      ),
      Product(
        id: 'adidas_2',
        name: 'Adidas Stan Smith',
        category: 'Adidas',
        price: 95.00,
        image: 'assets/images/shoe_nike_2.png',
        rating: 4.7,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Timeless style. Clean design. Stan Smiths have been the gold standard of minimalist leather court sneakers for decades.',
      ),
      Product(
        id: 'converse_1',
        name: 'Converse Chuck Taylor',
        category: 'Converse',
        price: 90.00,
        image: 'assets/images/shoe_nike_2.png',
        rating: 4.6,
        isBestSeller: true,
        description: 'The definitive sneaker. Originally designed as a basketball shoe, the Chuck Taylor All Star is an emblem of casual style.',
      ),
      Product(
        id: 'converse_2',
        name: 'Converse Star Hike',
        category: 'Converse',
        price: 110.00,
        image: 'assets/images/shoe_nike_1.png',
        rating: 4.8,
        isBestSeller: true,
        isNewArrival: true,
        description: 'A chunky platform and jagged rubber sole put an unexpected twist on your everyday Chucks.',
      ),
      Product(
        id: 'ua_1',
        name: 'UA Hovr Phantom 2',
        category: 'UA',
        price: 160.00,
        image: 'assets/images/shoe_nike_1.png',
        rating: 4.4,
        isBestSeller: true,
        description: 'Under Armour HOVR technology provides zero gravity feel to maintain energy return that helps eliminate impact.',
      ),
      Product(
        id: 'ua_2',
        name: 'UA Curry Flow 8',
        category: 'UA',
        price: 170.00,
        image: 'assets/images/shoe_nike_3.png',
        rating: 4.8,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Features UA Flow cushioning technology, which is rubber-free, making the shoe lighter and ridiculously grippy.',
      ),
      Product(
        id: 'adidas_3',
        name: 'Adidas Response Red',
        category: 'Adidas',
        price: 145.00,
        image: 'assets/images/shoe_adidas_red.png',
        rating: 4.6,
        isBestSeller: true,
        isNewArrival: true,
        description: 'High-performance running shoe with breathable mesh and responsive cushioning in striking red colorway.',
      ),

      Product(
        id: 'nike_7',
        name: 'Nike Air Zoom Orange',
        category: 'Nike',
        price: 165.00,
        image: 'assets/images/shoe_nike_orange.png',
        rating: 4.5,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Eye-catching design meets ultimate comfort with Nike Air Zoom cushioning, styled in vivid white and orange.',
      ),
      Product(
        id: 'nike_8',
        name: 'Nike Air Max Blue',
        category: 'Nike',
        price: 195.00,
        image: 'assets/images/shoe_nike_blue.png',
        rating: 4.7,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Iconic Air Max cushioning with a fresh light blue upper and premium black accents.',
      ),
      Product(
        id: 'nike_9',
        name: 'Nike Air Zoom Pink',
        category: 'Nike',
        price: 155.00,
        image: 'assets/images/shoe_nike_pink.png',
        rating: 4.6,
        isBestSeller: true,
        isNewArrival: false,
        description: 'Dynamic support and lightweight responsiveness, wrapped in a bold pink mesh upper.',
      ),
      Product(
        id: 'nike_10',
        name: 'Nike Joyride Grey',
        category: 'Nike',
        price: 175.00,
        isNewArrival: true,
        image: 'assets/images/shoe_nike_grey.png',
        rating: 4.4,
        isBestSeller: true,
        description: 'Plush comfort with tiny foam beads underfoot, wrapped in a light grey and yellow colorway.',
      ),
      Product(
        id: 'nike_11',
        name: 'Nike Zoom Pink Grey',
        category: 'Nike',
        price: 185.00,
        image: 'assets/images/shoe_nike_pink_grey.png',
        rating: 4.6,
        isBestSeller: true,
        isNewArrival: true,
        description: 'Modern lifestyle running shoe featuring dual-density foam midsole and breathable pink-grey styling.',
      ),
    ]);
  }
}
