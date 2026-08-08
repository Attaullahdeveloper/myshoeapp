import 'package:get/get.dart';

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
  }) : isFavorite = isFavorite.obs;
}
