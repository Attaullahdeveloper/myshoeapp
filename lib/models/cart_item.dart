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

  double get totalPrice => product.price * quantity;
}
