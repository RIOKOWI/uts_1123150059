import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';
import 'cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final List<CartItem> _localCart = [];

  @override
  Future<void> saveCart(List<CartItem> items) async {
    // Simulasi menyimpan ke database
    _localCart.clear();
    _localCart.addAll(items);
  }

  @override
  Future<List<CartItem>> loadCart() async {
    return _localCart;
  }

  @override
  Future<void> clearCart() async {
    _localCart.clear();
  }
}
