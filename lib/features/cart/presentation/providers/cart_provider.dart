import 'package:flutter/foundation.dart';
import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';
import 'package:uts_1123150059/features/cart/domain/repositories/cart_repository_impl.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepositoryImpl _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;
  bool _isAdding = false; // flag khusus saat tambah ke cart

  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get error => _error;
  bool get isAdding => _isAdding;

  // Getter untuk badge di bottom nav
  int get itemCount => _cart?.itemCount ?? 0;
  double get totalPrice => _cart?.totalPrice ?? 0;
  List<CartItemModel> get items => _cart?.items ?? [];

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final items = await _repository.getCart();
      _cart = CartModel(
        items: items,
        itemCount: items.length,
        totalPrice: items.fold(0.0, (sum, item) => sum + item.calculatedSubtotal),
      );
      _status = CartStatus.loaded;
      _error = null;
    } catch (e) {
      _status = CartStatus.error;
      _error = 'Gagal memuat keranjang: ${e.toString()}';
      _cart = null;
    }
    notifyListeners();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    notifyListeners();

    try {
      await _repository.addToCart(productId, quantity);
      await fetchCart(); // Refresh data cart setelah berhasil
      _isAdding = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAdding = false;
      _error = 'Gagal menambahkan ke keranjang: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await fetchCart(); // Refresh data setelah update
    } catch (e) {
      _error = 'Gagal memperbarui item: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      await fetchCart(); // Refresh data setelah hapus
    } catch (e) {
      _error = 'Gagal menghapus item: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      // Langsung set state ke kosong tanpa fetch ulang — lebih cepat
      _cart = const CartModel(items: [], itemCount: 0, totalPrice: 0);
      _status = CartStatus.loaded;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal mengosongkan keranjang: ${e.toString()}';
      notifyListeners();
    }
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}