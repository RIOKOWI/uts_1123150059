import 'package:flutter/material.dart';
import 'package:uts_1123150059/core/guards/auth_guard.dart';
import 'package:uts_1123150059/features/auth/presentation/pages/login_page.dart';
import 'package:uts_1123150059/features/auth/presentation/pages/register_page.dart';
import 'package:uts_1123150059/features/auth/presentation/pages/verify_email_page.dart';
import 'package:uts_1123150059/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:uts_1123150059/features/order/data/models/order_model.dart';
import 'package:uts_1123150059/features/cart/presentation/pages/cart_page.dart';
import 'package:uts_1123150059/features/cart/presentation/pages/checkout_page.dart';
import 'package:uts_1123150059/features/order/presentation/pages/my_orders_page.dart';
import 'package:uts_1123150059/features/order/presentation/pages/order_success_page.dart';
import 'package:uts_1123150059/features/order/presentation/pages/payment_pending_page.dart';
import 'package:uts_1123150059/main.dart';

/// // Route constants untuk navigasi aplikasi.
/// //
/// // Rute yang tersedia:
/// // - `splash`: Halaman splash (cek auth + cold-start callback)
/// // - `login`: Halaman login
/// // - `register`: Halaman registrasi
/// // - `verifyEmail`: Halaman verifikasi email
/// // - `dashboard`: Halaman utama (butuh auth)
/// // - `cart`: Halaman keranjang
/// // - `checkout`: Halaman checkout
/// // - `myOrders`: Halaman daftar pesanan
/// // - `orderSuccess`: Halaman sukses pesanan (butuh argument: OrderModel)
/// // - `paymentPending`: Halaman pembayaran pending (butuh argument: OrderModel)
class AppRouter {
  /// // Splash page route - handle auth check dan cold-start callback
  static const String splash = '/';

  /// // Halaman login
  static const String login = '/login';

  /// // Halaman registrasi
  static const String register = '/register';

  /// // Halaman verifikasi email
  static const String verifyEmail = '/verify-email';

  /// // Halaman dashboard (butuh auth)
  static const String dashboard = '/dashboard';

  /// // Halaman keranjang
  static const String cart = '/cart';

  /// // Halaman checkout
  static const String checkout = '/checkout';

  /// // Halaman daftar pesanan saya
  static const String myOrders = '/my-orders';

  /// // Halaman sukses pesanan (argument: OrderModel)
  static const String orderSuccess = '/order-success';

  /// // Halaman pembayaran pending (argument: OrderModel)
  static const String paymentPending = '/payment-pending';

  /// // Map route ke widget builder.
  /// //
  /// // Routes dengan argument:
  /// // - `orderSuccess`: membutuhkan `OrderModel` sebagai argument
  /// // - `paymentPending`: membutuhkan `OrderModel` sebagai argument
  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    verifyEmail: (_) => const VerifyEmailPage(),
    dashboard: (_) => const AuthGuard(child: DashboardPage()),
    cart: (_) => const CartPage(),
    checkout: (_) => const CheckoutPage(),
    myOrders: (_) => const MyOrdersPage(),
    orderSuccess: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return OrderSuccessPage(order: order);
    },
    paymentPending: (context) {
      final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
      return PaymentPendingPage(order: order);
    },
  };
}