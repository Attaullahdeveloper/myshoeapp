import 'dart:convert';
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
  final bool isSpecialOffer;
  final String description;
  final List<int> sizes;
  final List<String> colors;
  final List<String> galleryImages;
  final List<StockBatch> stockBatches;

  final String? companyId;
  final String status;
  final String availabilityStatus; // 'in_stock' | 'out_of_stock'
  final bool isAvailable;
  final bool hasDiscount;
  final double discountPercentage;
  final double discountedPrice;

  Product({
    required this.id,
    this.companyId,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.rating,
    bool isFavorite = false,
    this.isBestSeller = false,
    this.isNewArrival = false,
    this.isSpecialOffer = false,
    this.status = 'New Arrival',
    this.availabilityStatus = 'in_stock',
    this.isAvailable = true,
    this.hasDiscount = false,
    this.discountPercentage = 0.0,
    this.discountedPrice = 0.0,
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

  double get finalPrice {
    if (hasDiscount) {
      if (discountedPrice > 0) return discountedPrice;
      if (discountPercentage > 0) return (price - (price * discountPercentage / 100)).clamp(0.0, double.infinity);
    }
    return price;
  }

  double get actualDiscountAmount {
    if (hasDiscount) {
      final diff = price - finalPrice;
      return diff > 0 ? diff : 0.0;
    }
    return 0.0;
  }

  bool get isOutOfStock =>
      availabilityStatus.toLowerCase() == 'out_of_stock' || !isAvailable;

  bool get isInStock => !isOutOfStock;

  bool get isAvailableStatus => isInStock && totalStock > 0;

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
    String? companyId,
    String? name,
    String? category,
    double? price,
    String? image,
    double? rating,
    bool? isFavorite,
    bool? isBestSeller,
    bool? isNewArrival,
    bool? isSpecialOffer,
    String? status,
    String? availabilityStatus,
    bool? isAvailable,
    bool? hasDiscount,
    double? discountPercentage,
    double? discountedPrice,
    String? description,
    List<int>? sizes,
    List<String>? colors,
    List<String>? galleryImages,
    List<StockBatch>? stockBatches,
  }) {
    final p = Product(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite.value,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isSpecialOffer: isSpecialOffer ?? this.isSpecialOffer,
      status: status ?? this.status,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      isAvailable: isAvailable ?? this.isAvailable,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      description: description ?? this.description,
      sizes: sizes ?? List.from(this.sizes),
      colors: colors ?? List.from(this.colors),
      galleryImages: galleryImages ?? List.from(this.galleryImages),
      stockBatches: stockBatches ?? List.from(this.stockBatches),
    );
    return p;
  }

  factory Product.fromSupabaseJson(Map<String, dynamic> json, {String? categoryName}) {
    List<String> imgUrls = [];
    final rawImg = json['product_img_url'];
    if (rawImg is List) {
      imgUrls = List<String>.from(rawImg);
    } else if (rawImg is String && rawImg.isNotEmpty) {
      if (rawImg.startsWith('[')) {
        try {
          final parsed = jsonDecode(rawImg);
          if (parsed is List) imgUrls = List<String>.from(parsed);
        } catch (_) {
          imgUrls = [rawImg];
        }
      } else {
        imgUrls = [rawImg];
      }
    }

    // Safely parse sizes (handles List or String JSON)
    List<int> szList = [38, 39, 40, 41, 42];
    dynamic rawSizes = json['sizes'];
    if (rawSizes is String && rawSizes.startsWith('[')) {
      try { rawSizes = jsonDecode(rawSizes); } catch (_) {}
    }
    if (rawSizes is List) {
      szList = rawSizes.map((e) => int.tryParse(e.toString()) ?? 40).toList();
    }

    // Safely parse colors (handles List or String JSON)
    List<String> colList = ['#1A2530', '#5B9EE1'];
    dynamic rawColors = json['colors'];
    if (rawColors is String && rawColors.startsWith('[')) {
      try { rawColors = jsonDecode(rawColors); } catch (_) {}
    }
    if (rawColors is List) {
      colList = rawColors.map((e) => e.toString()).toList();
    } else if (rawColors is String && rawColors.isNotEmpty) {
      colList = [rawColors];
    }

    final double salePrice = (json['sale_price'] as num?)?.toDouble() ?? 0.0;
    final double purPrice = (json['purchase_price'] as num?)?.toDouble() ?? (salePrice * 0.6);
    final int qty = (json['stock_quantity'] as num?)?.toInt() ?? 50;

    String parsedCategory = categoryName ?? '';
    if (parsedCategory.isEmpty && json['companies'] != null && json['companies'] is Map) {
      parsedCategory = json['companies']['name']?.toString() ?? '';
    }
    if (parsedCategory.isEmpty) {
      parsedCategory = 'Shoes';
    }

    final bool isBest = json['is_best_seller'] ?? false;
    final bool isNew = json['is_new_arrival'] ?? false;
    final bool isSpec = json['is_special'] ?? json['is_special_offer'] ?? false;
    final String statusParsed = json['status']?.toString() ??
        (isSpec ? 'Special Deal' : (isBest ? 'Best Seller' : 'New Arrival'));
    final bool avail = json['is_available'] ?? json['in_stock'] ?? true;
    String availStatus =
        json['availability_status']?.toString().toLowerCase().trim() ?? '';
    if (availStatus.isEmpty) {
      availStatus = (avail == false || json['in_stock'] == false)
          ? 'out_of_stock'
          : 'in_stock';
    }

    final bool discApplied = json['has_discount'] ?? false;
    final double discPct = (json['discount_percentage'] as num?)?.toDouble() ?? 0.0;
    final double calcDiscPrice = (json['discounted_price'] as num?)?.toDouble() ??
        (discApplied && discPct > 0 ? salePrice - (salePrice * (discPct / 100)) : salePrice);

    return Product(
      id: json['prod_id']?.toString() ?? '',
      companyId: json['company_id']?.toString(),
      name: json['title']?.toString() ?? '',
      category: parsedCategory,
      price: salePrice,
      image: imgUrls.isNotEmpty ? imgUrls.first : '',
      rating: 4.7,
      isBestSeller: isBest || statusParsed.toLowerCase().contains('best'),
      isNewArrival: isNew || statusParsed.toLowerCase().contains('new'),
      isSpecialOffer: isSpec || statusParsed.toLowerCase().contains('special'),
      status: statusParsed,
      availabilityStatus: availStatus,
      isAvailable: avail,
      hasDiscount: discApplied,
      discountPercentage: discPct,
      discountedPrice: calcDiscPrice,
      description: json['description']?.toString() ?? '',
      sizes: szList,
      colors: colList,
      galleryImages: imgUrls,
      stockBatches: [
        StockBatch(
          id: 'batch_${json['prod_id']}',
          batchNumber: 'BATCH-DEFAULT',
          purchasePrice: purPrice,
          salePrice: salePrice,
          quantity: qty,
          entryDate: DateTime.now(),
          supplier: 'Direct Supplier',
        )
      ],
    );
  }
}



