import 'package:flutter/foundation.dart';
import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';
import 'package:uts_1123150059/features/cart/domain/repositories/cart_repository_impl.dart';

class CartProvider extends ChangeNotifier {
  final CartRepositoryImpl _repository = CartRepositoryImpl();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Load cart from API
  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getCart();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat keranjang: ${e.toString()}';
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<void> addItem(int productId, int quantity) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newItem = await _repository.addToCart(productId, quantity);
      // Find and update existing item or add new one
      final existingIndex =
          _items.indexWhere((item) => item.productId == productId);
      if (existingIndex != -1) {
        _items[existingIndex] = newItem;
      } else {
        _items.add(newItem);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan ke keranjang: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeItem(int cartItemId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCartItem(cartItemId);
      _items.removeWhere((item) => item.id == cartItemId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal menghapus item: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedItem = await _repository.updateCartItem(cartItemId, quantity);
      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _items[index] = updatedItem;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui item: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.clearCart();
      _items.clear();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal mengosongkan keranjang: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
