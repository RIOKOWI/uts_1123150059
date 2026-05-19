import 'package:equatable/equatable.dart';

/// Model untuk informasi produk di dalam item keranjang
/// Diparsing dari field 'product' di response API cart
class CartProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const CartProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      CartProductModel(
        id: (json['ID'] as num?)?.toInt() ?? json['id'] as int? ?? 0,
        // ^^^^^^^^^^^^^^^^^^^^ backend pakai 'ID' huruf kapital
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['image_url'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}

/// Model untuk setiap item di keranjang
class CartItemModel extends Equatable {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final CartProductModel product;
  final double subtotal;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
    required this.subtotal,
  });

  /// Fallback: jika subtotal dari API = 0, hitung sendiri dari price × quantity
  double get calculatedSubtotal => subtotal > 0 ? subtotal : product.price * quantity;

  /// Total harga untuk item ini (quantity × price)
  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final cartProduct = CartProductModel.fromJson(
      json['product'] as Map<String, dynamic>? ?? {},
    );
    final qty = (json['quantity'] as num?)?.toInt() ?? 0;

    // Prioritas: pakai total_price dari API jika > 0
    // Fallback: hitung sendiri dari price × quantity
    final apiSubtotal = (json['total_price'] as num?)?.toDouble() ?? 0.0;
    final calcSubtotal = apiSubtotal > 0 ? apiSubtotal : cartProduct.price * qty;

    return CartItemModel(
      id: (json['ID'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: qty,
      product: cartProduct,
      subtotal: calcSubtotal,
    );
  }

  /// Konversi ke JSON untuk body request (saat update/add)
  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };

  @override
  List<Object?> get props =>
      [id, userId, productId, quantity, product, subtotal];
}

/// Model untuk keseluruhan keranjang
/// Diparsing dari response GET /v1/cart
class CartModel extends Equatable {
  final List<CartItemModel> items;
  final int itemCount;
  final double totalPrice;

  const CartModel({
    required this.items,
    required this.itemCount,
    required this.totalPrice,
  });

  /// SELALU hitung total dari items — tidak percaya field 'total_price' dari API
  /// Ini memastikan hasil selalu akurat
  double get calculatedTotal =>
      items.fold(0.0, (sum, item) => sum + item.calculatedSubtotal);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Gunakan total_items dan total_price dari API
    final apiItemCount = (json['total_items'] as num?)?.toInt() ?? 0;
    final apiTotalPrice = (json['total_price'] as num?)?.toDouble() ?? 0.0;

    // Total dari API bisa dipakai, tapi kita juga hitung sendiri dari items
    // untuk memastikan consistency
    final calculatedTotal =
        itemsList.fold(0.0, (sum, item) => sum + item.calculatedSubtotal);

    return CartModel(
      items: itemsList,
      // Gunakan total_items dari API jika ada, fallback ke items.length
      itemCount: apiItemCount > 0 ? apiItemCount : itemsList.length,
      // Gunakan total_price dari API jika > 0, fallback ke calculated total
      totalPrice: apiTotalPrice > 0 ? apiTotalPrice : calculatedTotal,
    );
  }

  /// Model keranjang kosong
  static CartModel get empty => const CartModel(
        items: [],
        itemCount: 0,
        totalPrice: 0,
      );

  @override
  List<Object?> get props => [items, itemCount, totalPrice];
}

/// Alias untuk backward compatibility
typedef CartItem = CartItemModel;
