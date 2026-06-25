import 'package:equatable/equatable.dart';

/// Model untuk item dalam pesanan
class OrderItemModel extends Equatable {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? json['productName'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
        'subtotal': subtotal,
      };

  @override
  List<Object?> get props => [productId, productName, price, quantity, subtotal];
}

/// Model untuk pesanan keseluruhan
class OrderModel extends Equatable {
  final int id;
  final double totalAmount;
  final String status; // 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
  final String shippingAddress;
  final String notes;
  final String paymentMethod; // 'gopay' | 'bank_transfer' | 'virtual_account'
  final List<OrderItemModel> items;
  final String createdAt;
  final String? vaNumber;
  final String? gopayDeeplink;
  /// // URL callback untuk Dompet Kampus Global (deep-link return URL)
  /// //
  /// // Format: `gocap://payment-callback?status=...&reference=...&transaction_id=...`
  /// //
  /// // Parameter:
  /// // - `status`: 'success' | 'failed' | 'pending' | 'cancelled'
  /// // - `reference`: Reference ID pesanan (INV-{orderId})
  /// // - `transaction_id`: Transaction ID dari Dompet Kampus Global
  /// //
  /// // Contoh URI lengkap:
  /// // `gocap://payment-callback?status=success&reference=INV-123&transaction_id=TRX-456`
  final String? callbackUrl;

  const OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.notes,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
    this.vaNumber,
    this.gopayDeeplink,
    this.callbackUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: (json['ID'] as num?)?.toInt() ?? json['id'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ??
          (json['totalAmount'] as num?)?.toDouble() ??
          0.0,
      status: json['status'] as String? ?? 'pending',
      shippingAddress: json['shipping_address'] as String? ??
          json['shippingAddress'] as String? ??
          '',
      notes: json['notes'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ??
          json['paymentMethod'] as String? ??
          '',
      items: itemsList,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      vaNumber: json['va_number'] as String? ?? json['vaNumber'] as String?,
      gopayDeeplink: json['gopay_deeplink'] as String? ?? json['gopayDeeplink'] as String?,
      callbackUrl: json['callback_url'] as String? ?? json['callbackUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'total_amount': totalAmount,
        'status': status,
        'shipping_address': shippingAddress,
        'notes': notes,
        'payment_method': paymentMethod,
        'items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt,
        if (vaNumber != null) 'va_number': vaNumber,
        if (gopayDeeplink != null) 'gopay_deeplink': gopayDeeplink,
        if (callbackUrl != null) 'callback_url': callbackUrl,
      };

  @override
  List<Object?> get props => [
        id,
        totalAmount,
        status,
        shippingAddress,
        notes,
        paymentMethod,
        items,
        createdAt,
        vaNumber,
        gopayDeeplink,
        callbackUrl,
      ];
}