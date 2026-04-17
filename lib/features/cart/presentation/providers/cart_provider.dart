import 'package:flutter/foundation.dart';
import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Tambah barang ke cart
  void addItem(String productId, String productName, double price, {String? imageUrl}) {
    final existingItem = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: productName,
        price: price,
        quantity: 0,
        imageUrl: imageUrl,
      ),
    );

    if (existingItem.quantity == 0) {
      _items.add(existingItem.copyWith(quantity: 1));
    } else {
      final index = _items.indexOf(existingItem);
      _items[index] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    }

    notifyListeners();
  }

  /// Hapus barang dari cart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Update quantity barang
  void updateItemQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  /// Clear semua item
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
