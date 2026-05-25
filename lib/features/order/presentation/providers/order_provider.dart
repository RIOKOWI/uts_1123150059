import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uts_1123150059/features/order/data/models/order_model.dart';
import 'package:uts_1123150059/features/order/domain/repositories/order_repository_impl.dart';

enum OrderStatus { initial, loading, success, error }

enum PaymentCheckStatus { idle, checking, paid, failed }

class OrderProvider extends ChangeNotifier {
  final OrderRepositoryImpl _repository = OrderRepositoryImpl();

  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderModel? _lastOrder;
  List<OrderModel> _orders = [];
  String? _error;

  // Payment polling
  Timer? _pollingTimer;
  PaymentCheckStatus _paymentCheckStatus = PaymentCheckStatus.idle;

  OrderStatus get checkoutStatus => _checkoutStatus;
  OrderModel? get lastOrder => _lastOrder;
  List<OrderModel> get orders => _orders;
  String? get error => _error;
  PaymentCheckStatus get paymentCheckStatus => _paymentCheckStatus;

  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _setLoading();
    try {
      _lastOrder = await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _checkoutStatus = OrderStatus.success;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal membuat pesanan: ${e.toString()}');
      return false;
    }
  }

  Future<void> fetchMyOrders({int page = 1, int limit = 10}) async {
    _setLoading();
    try {
      _orders = await _repository.getMyOrders(page: page, limit: limit);
      _checkoutStatus = OrderStatus.success;
      _error = null;
    } catch (e) {
      _setError('Gagal memuat pesanan: ${e.toString()}');
    }
  }

  Future<void> fetchOrderDetail(int orderId) async {
    _setLoading();
    try {
      _lastOrder = await _repository.getOrderDetail(orderId);
      _checkoutStatus = OrderStatus.success;
      _error = null;
    } catch (e) {
      _setError('Gagal memuat detail pesanan: ${e.toString()}');
    }
  }

  Future<void> checkPaymentStatus(int orderId) async {
    _paymentCheckStatus = PaymentCheckStatus.checking;
    notifyListeners();

    try {
      final order = await _repository.checkPaymentStatus(orderId);
      if (order.status == 'paid' || order.status == 'delivered' || order.status == 'processing') {
        _paymentCheckStatus = PaymentCheckStatus.paid;
        _lastOrder = order;
      } else {
        _paymentCheckStatus = PaymentCheckStatus.idle;
      }
      _error = null;
    } catch (e) {
      _paymentCheckStatus = PaymentCheckStatus.failed;
      _error = e.toString();
    }
    notifyListeners();
  }

  void startPaymentPolling(int orderId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkPaymentStatus(orderId);
    });
  }

  void stopPaymentPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void resetCheckout() {
    _checkoutStatus = OrderStatus.initial;
    _lastOrder = null;
    _error = null;
    _paymentCheckStatus = PaymentCheckStatus.idle;
    notifyListeners();
  }

  void _setLoading() {
    _checkoutStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _checkoutStatus = OrderStatus.error;
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}