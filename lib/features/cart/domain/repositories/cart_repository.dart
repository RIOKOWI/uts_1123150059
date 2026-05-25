import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';

abstract class CartRepository {
  /// Ambil isi keranjang
  Future<List<CartItemModel>> getCart();

  /// Tambah produk ke keranjang
  Future<void> addToCart(int productId, int quantity);

  /// Update jumlah item
  Future<void> updateCartItem(int cartItemId, int quantity);

  /// Hapus satu item
  Future<void> removeCartItem(int cartItemId);

  /// Kosongkan keranjang
  Future<void> clearCart();
}