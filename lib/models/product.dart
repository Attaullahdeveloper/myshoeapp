import 'package:get/get.dart';
import 'stock_batch.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String image;
  final double rating;
  final RxBool isFavorite;
  final bool isBestSeller;
  final bool isNewArrival;
  final String description;
  final List<int> sizes;
  final List<String> colors;
  final List<String> galleryImages;
  final List<StockBatch> stockBatches;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.rating,
    bool isFavorite = false,
    this.isBestSeller = false,
    this.isNewArrival = false,
    this.description = '',
    this.sizes = const [38, 39, 40, 41, 42, 43, 44],
    this.colors = const ['#1A2530', '#5B9EE1', '#E74C3C'],
    this.galleryImages = const [],
    this.stockBatches = const [],
  }) : isFavorite = isFavorite.obs;

  // Calculated Getters
  int get totalStock {
    if (stockBatches.isEmpty) return 30; // Default sample stock if no batch
    return stockBatches.fold(0, (sum, batch) => sum + batch.quantity);
  }

  double get latestPurchasePrice {
    if (stockBatches.isEmpty) return price * 0.6; // Default sample 60% of price
    return stockBatches.last.purchasePrice;
  }

  double get latestSalePrice {
    if (stockBatches.isEmpty) return price;
    return stockBatches.last.salePrice;
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? image,
    double? rating,
    bool? isFavorite,
    bool? isBestSeller,
    bool? isNewArrival,
    String? description,
    List<int>? sizes,
    List<String>? colors,
    List<String>? galleryImages,
    List<StockBatch>? stockBatches,
  }) {
    final p = Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite.value,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      description: description ?? this.description,
      sizes: sizes ?? List.from(this.sizes),
      colors: colors ?? List.from(this.colors),
      galleryImages: galleryImages ?? List.from(this.galleryImages),
      stockBatches: stockBatches ?? List.from(this.stockBatches),
    );
    return p;
  }
}


