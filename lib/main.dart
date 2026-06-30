import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_1123150059/core/constants/app_strings.dart';
import 'package:uts_1123150059/core/providers/theme_provider.dart';
import 'package:uts_1123150059/core/routes/app_router.dart';
import 'package:uts_1123150059/core/services/global_institute_pay_service.dart';
import 'package:uts_1123150059/core/services/secure_storage.dart';
import 'package:uts_1123150059/core/theme/app_theme.dart';
import 'package:uts_1123150059/features/auth/presentation/providers/auth_provider.dart';
import 'package:uts_1123150059/features/dashboard/presentation/providers/product_provider.dart';
import 'package:uts_1123150059/features/cart/presentation/providers/cart_provider.dart';
import 'package:uts_1123150059/features/order/presentation/providers/order_provider.dart';
import 'package:uts_1123150059/features/order/presentation/pages/payment_pending_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// // Inisialisasi GlobalInstitutePayService untuk deep-link handling.
  /// //
  /// // Service ini akan:
  /// // 1. Menangkap deep-link masuk saat app dibuka via deeplink (cold start)
  /// // 2. Mendengarkan stream deep-link saat app sudah berjalan (warm start)
  /// // 3. Menyediakan callback untuk PaymentPendingPage
  await GlobalInstitutePayService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: themeProvider.themeMode,
      /// // Initial route menggunakan SplashPage untuk handle cold-start callback.
      /// // SplashPage akan cek auth token dan cold-start callback sebelum redirect.
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// // Cek cold-start callback sebelum auth check.
  /// //
  /// // Handle kasus dimana:
  /// // 1. App dibuka via deep-link callback dari Gocap
  /// // 2. Payment sudah sukses, tapi app dibuka langsung via deeplink
  Future<void> _checkAuth() async {
    // Animasi splash singkat
    await Future.delayed(const Duration(milliseconds: 500));

    // Cek cold-start callback SEBELUM auth check
    // Ini handle kasus app dibuka via deeplink callback setelah payment success
    final pendingCallback = GlobalInstitutePayService().consumePendingCallback();
    if (pendingCallback != null && pendingCallback.isSuccess) {
      debugPrint('[SplashPage] Cold-start callback sukses ditemukan: $pendingCallback');
      // Ambil stored order dan navigasi langsung ke OrderSuccessPage
      final pendingOrder = await PaymentPendingPage.consumePendingOrder();
      if (pendingOrder != null && mounted) {
        debugPrint('[SplashPage] Navigasi langsung ke OrderSuccessPage dengan stored order');
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.orderSuccess,
          (route) => route.settings.name == AppRouter.dashboard,
          arguments: pendingOrder,
        );
        return;
      }
    }

    if (!mounted) return;

    final token = await SecureStorage.getToken();
    final route = token != null ? AppRouter.dashboard : AppRouter.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
