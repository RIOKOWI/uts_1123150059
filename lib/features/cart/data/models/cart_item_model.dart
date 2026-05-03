import 'package:equatable/equatable.dart';

class CartItemModel extends Equatable {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final ProductModel product;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: (json['ID'] as num?)?.toInt() ?? 0,
    userId: (json['user_id'] as num?)?.toInt() ?? 0,
    productId: (json['product_id'] as num?)?.toInt() ?? 0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    product: ProductModel.fromJson(json['product'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };

  @override
  List<Object?> get props => [id, userId, productId, quantity, product];
}

class ProductModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: (json['ID'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    category: json['category'] as String? ?? '',
    imageUrl: json['image_url'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? true,
  );

  @override
  List<Object?> get props =>
      [id, name, description, price, stock, category, imageUrl, isActive];
}

typedef CartItem = CartItemModel;
