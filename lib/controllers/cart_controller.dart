import 'dart:async';
import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController extends GetxController {
  static CartController get to => Get.find<CartController>();

  final RxList<CartItem> _items = <CartItem>[].obs;
  final StreamController<List<CartItem>> _cartStreamController =
      StreamController<List<CartItem>>.broadcast();

  Stream<List<CartItem>> get cartStream => _cartStreamController.stream;
  List<CartItem> get items => _items;

  @override
  void onInit() {
    super.onInit();
    _loadSampleCartItems();
    _emitCart();
  }

  @override
  void onClose() {
    _cartStreamController.close();
    super.onClose();
  }

  void _loadSampleCartItems() {
    // Cart is empty by default on application restart until user adds items
    _items.clear();
  }

  void clearCart() {
    _items.clear();
    _emitCart();
  }

  void _emitCart() {
    if (!_cartStreamController.isClosed) {
      _cartStreamController.add(List<CartItem>.unmodifiable(_items));
    }
  }

  void addToCart(Product product, {int selectedSize = 40, String selectedUnit = 'EU'}) {
    final itemId = '${product.id}_$selectedSize';
    final index = _items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      _items[index].quantity += 1;
      _items.refresh();
    } else {
      _items.add(
        CartItem(
          id: itemId,
          product: product,
          selectedSize: selectedSize,
          selectedUnit: selectedUnit,
          quantity: 1,
        ),
      );
    }
    _emitCart();
  }

  void incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      _items[index].quantity += 1;
      _items.refresh();
      _emitCart();
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
        _items.refresh();
      } else {
        _items.removeAt(index);
      }
      _emitCart();
    }
  }

  void removeFromCart(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    _emitCart();
  }

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  double get shippingCost => _items.isEmpty ? 0.0 : 40.90;

  double get totalCost => subtotal + shippingCost;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
}
