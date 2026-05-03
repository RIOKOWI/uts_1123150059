import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';

abstract class CartRepository {
  // Get all cart items
  Future<List<CartItemModel>> getCart();

  // Add item to cart
  Future<CartItemModel> addToCart(
    int productId,
    int quantity,
  );

  // Update cart item quantity
  Future<CartItemModel> updateCartItem(
    int cartItemId,
    int quantity,
  );

  // Delete specific cart item
  Future<void> deleteCartItem(int cartItemId);

  // Clear all cart items
  Future<void> clearCart();
}
