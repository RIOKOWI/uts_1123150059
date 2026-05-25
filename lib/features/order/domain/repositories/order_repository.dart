import 'package:uts_1123150059/features/order/data/models/order_model.dart';

/// Abstract repository untuk operasi pesanan
/// Kontrak antara domain dan data layer
abstract class OrderRepository {
  /// Checkout - buat pesanan baru
  Future<OrderModel> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  });

  /// Ambil daftar pesanan user
  Future<List<OrderModel>> getMyOrders({int page, int limit});

  /// Ambil detail satu pesanan
  Future<OrderModel> getOrderDetail(int orderId);

  /// Cek status pembayaran
  Future<OrderModel> checkPaymentStatus(int orderId);
}