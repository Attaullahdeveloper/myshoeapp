import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int selectedSize;
  final String selectedUnit;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    this.selectedUnit = 'EU',
    this.quantity = 1,
  });

  double get originalPrice => product.price * quantity;
  double get totalPrice => product.finalPrice * quantity;
  double get totalDiscount => product.actualDiscountAmount * quantity;
  bool get hasDiscount => product.hasDiscount && totalDiscount > 0;
}
