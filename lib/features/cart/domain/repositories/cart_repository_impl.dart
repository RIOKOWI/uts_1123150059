import 'package:uts_1123150059/core/constants/api_constants.dart';
import 'package:uts_1123150059/core/services/dio_client.dart';
import 'package:uts_1123150059/features/cart/data/models/cart_item_model.dart';
import 'cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<List<CartItemModel>> getCart() async {
    final response = await DioClient.instance.get(
      ApiConstants.cart,
    );

    final List<dynamic> items = response.data['data']['items'] ?? [];
    return items
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CartItemModel> addToCart(
    int productId,
    int quantity,
  ) async {
    final response = await DioClient.instance.post(
      ApiConstants.cart,
      data: {
        'product_id': productId,
        'quantity': quantity,
      },
    );

    return CartItemModel.fromJson(response.data['data']);
  }

  @override
  Future<CartItemModel> updateCartItem(
    int cartItemId,
    int quantity,
  ) async {
    final response = await DioClient.instance.put(
      '${ApiConstants.cart}/$cartItemId',
      data: {
        'quantity': quantity,
      },
    );

    return CartItemModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteCartItem(int cartItemId) async {
    await DioClient.instance.delete(
      '${ApiConstants.cart}/$cartItemId',
    );
  }

  @override
  Future<void> clearCart() async {
    await DioClient.instance.delete(
      ApiConstants.cart,
    );
  }
}
