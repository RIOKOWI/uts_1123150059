import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

// ── Log helper ────────────────────────────────────────────────
/// // Log helper untuk debugging deeplink
void _log(String tag, String message) {
  debugPrint('[Warmindo/$tag] $message');
}

// ── Model callback ────────────────────────────────────────────

/// // Model data callback dari Gocap
class PaymentCallbackData {
  /// // Status pembayaran: 'success', 'failed', 'pending', 'cancelled'
  final String status;

  /// // Reference ID untuk tracking transaksi
  final String? reference;

  /// // Transaction ID dari Gocap
  final String? transactionId;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  /// // Returns true jika pembayaran berhasil
  bool get isSuccess => status == 'success';

  @override
  String toString() =>
      'PaymentCallbackData(status=$status, reference=$reference, transactionId=$transactionId)';
}

// ── Service ────────────────────────────────────────────────────

/// // Service untuk menangani deeplink callback dari Gocap.
/// //
/// // Gunakan service ini di aplikasi Warmindo untuk:
/// // 1. Menerima callback setelah pembayaran selesai di Gocap
/// // 2. Mendengarkan stream callback untuk update real-time
/// // 3. Menangani cold-start scenario (app dibuka via deeplink langsung)
/// //
/// // Contoh penggunaan:
/// // ```dart
/// // // Initialize di main.dart atau di awal aplikasi
/// // await GlobalInstitutePayService().init();
/// //
/// // // Listen callback di PaymentPendingPage
/// // GlobalInstitutePayService().onCallback.listen((data) {
/// //   if (data.isSuccess) {
/// //     // Navigasi ke halaman sukses
/// //   }
/// // });
/// // ```
class GlobalInstitutePayService {
  static final GlobalInstitutePayService _instance =
      GlobalInstitutePayService._();
  factory GlobalInstitutePayService() => _instance;
  GlobalInstitutePayService._();

  static const _tag = 'GlobalInstitutePay';

  /// // Stream untuk mendengarkan callback pembayaran
  /// // Subscribe ke stream ini untuk menerima update pembayaran real-time
  final _callbackController = StreamController<PaymentCallbackData>.broadcast();
  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  /// // Simpan callback cold-start yang belum dibaca
  PaymentCallbackData? _pendingCallback;

  /// // Ambil callback cold-start, dikosongkan setelah dibaca (consume-once).
  /// //
  /// // Gunakan di SplashPage untuk handle kasus app dibuka via deeplink langsung.
  /// //
  /// // Contoh:
  /// // ```dart
  /// // final callback = GlobalInstitutePayService().consumePendingCallback();
  /// // if (callback != null && callback.isSuccess) {
  /// //   // Handle payment success
  /// // }
  /// // ```
  PaymentCallbackData? consumePendingCallback() {
    final data = _pendingCallback;
    _pendingCallback = null;
    if (data != null) {
      _log(_tag, ' Mengonsumsi pending cold-start callback: $data');
    }
    return data;
  }

  // ── Init ────────────────────────────────────────────────────

  /// // Inisialisasi service dan mulai mendengarkan deeplink masuk.
  /// //
  /// // Panggil method ini sekali saat aplikasi start (di main.dart atau HomePage).
  /// //
  /// // Handle dua kasus:
  /// // 1. Cold start - app dibuka via deeplink saat app belum berjalan
  /// // 2. Warm start - app sudah berjalan, deeplink masuk via stream
  Future<void> init() async {
    _log(_tag, ' Inisialisasi GlobalInstitutePayService...');

    final appLinks = AppLinks();

    // Kasus 1: cold start — app dibuka oleh deeplink
    try {
      _log(_tag, ' Mengambil initial link (cold start)...');
      final uri = await appLinks.getInitialLink();
      if (uri != null) {
        _log(_tag, ' Initial link ditemukan: $uri');
        _handleUri(uri, isColdStart: true);
      } else {
        _log(_tag, ' Tidak ada initial link (app dibuka normal)');
      }
    } catch (e) {
      _log(_tag, ' Error saat getInitialLink: $e');
    }

    // Kasus 2: app sudah berjalan — deeplink masuk via stream
    _log(_tag, ' Memulai listener uriLinkStream...');
    appLinks.uriLinkStream.listen(
      (uri) {
        _log(_tag, ' URI masuk via stream: $uri');
        _handleUri(uri);
      },
      onError: (Object e) {
        _log(_tag, ' Error pada uriLinkStream: $e');
      },
    );

    _log(_tag, ' Inisialisasi selesai.');
  }

  // ── Handle URI masuk ─────────────────────────────────────────

  /// // Proses URI yang masuk dari deeplink.
  /// //
  /// // Format URI yang diharapkan:
  /// // `gocap://payment-callback?status=success&reference=INV-123&transaction_id=TRX-456`
  /// //
  /// // Parameter URI:
  /// // - `status` (required): 'success', 'failed', 'pending', 'cancelled'
  /// // - `reference` (optional): Reference ID pesanan
  /// // - `transaction_id` (optional): Transaction ID dari Gocap
  void _handleUri(Uri uri, {bool isColdStart = false}) {
    _log(
      _tag,
      ' Handle URI | scheme=${uri.scheme} host=${uri.host} '
      'path=${uri.path} params=${uri.queryParameters} | coldStart=$isColdStart',
    );

    // Filter: hanya proses callback Gocap
    if (uri.scheme != 'warmindo') {
      _log(_tag, 'abaikan — bukan skema warmindo (scheme=${uri.scheme})');
      return;
    }
    if (uri.host != 'payment-callback') {
      _log(
        _tag,
        'abaikan — bukan host payment-callback (host=${uri.host})',
      );
      return;
    }

    final data = PaymentCallbackData(
      status: uri.queryParameters['status'] ?? 'unknown',
      reference: uri.queryParameters['reference'],
      transactionId: uri.queryParameters['transaction_id'],
    );

    _log(_tag, ' Callback diterima: $data');

    if (isColdStart) {
      _pendingCallback = data;
      _log(_tag, ' Disimpan sebagai pending cold-start callback');
    }

    _callbackController.add(data);
    _log(_tag, ' Event dikirim ke stream (subscriber aktif)');
  }

  // ── Build URL keluar ─────────────────────────────────────────

  /// Membangun URL deeplink ke Gocap sesuai spesifikasi.
  static String buildDeeplinkUrl({
    required int orderId,
    required double amount,
    String? description,
  }) {
    const scheme = 'gocap';
    const host = 'pay';
    final desc = (description != null && description.isNotEmpty)
        ? description
        : 'Order #$orderId';
    const callbackUrl = 'warmindo://payment-callback';

    _log(_tag, ' Membangun deeplink URL:');
    _log(_tag, 'merchant_id : MCH_WARMINDO');
    _log(_tag, 'merchant_name: Warmindo');
    _log(_tag, 'amount : ${amount.toInt()}');
    _log(_tag, 'description : $desc');
    _log(_tag, 'reference : INV-$orderId');
    _log(_tag, 'callback : $callbackUrl');

    final uri = Uri(
      scheme: scheme,
      host: host,
      queryParameters: {
        'merchant_id': 'MCH_WARMINDO',
        'merchant_name': 'Warmindo',
        'amount': amount.toInt().toString(),
        'description': desc,
        'reference': 'INV-$orderId',
        'callback': callbackUrl,
      },
    );

    final result = uri.toString();
    _log(_tag, ' URL lengkap (sebelum launch): $result');
    return result;
  }
}
