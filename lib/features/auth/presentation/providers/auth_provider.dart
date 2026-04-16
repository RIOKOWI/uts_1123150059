import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uts_1123150059/core/constants/app_constants.dart';
import 'package:uts_1123150059/core/service/secure_storage.dart';
import 'package:uts_1123150059/core/services/dio_client.dart';

enum AuthStatus {
  initial, // Belum ada action
  loading, // Proses berlangsung
  authenticated, // Login berhasil + token backend ada
  unauthenticated, // Belum login / logout
  emailNotVerified, // Login tapi email belum dikonfirmasi
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── State ───────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken; // Token dari backend (bukan Firebase token)
  String? _errorMessage;
  String? _tempEmail;
  String? _tempPassword;

  // ─── Getters ─────────────────────────────────────────────
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> register({name, email, password}) async {
    _setLoading(); // status = loading, notifyListeners()

    // STEP 1: Buat akun di Firebase
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _firebaseUser = credential.user;

    // STEP 2: Simpan nama di profil Firebase
    await _firebaseUser?.updateDisplayName(name);

    // STEP 3: Firebase kirim email verifikasi
    await _firebaseUser?.sendEmailVerification();

    // STEP 4: Simpan sementara untuk re-login nanti
    _tempEmail = email;
    _tempPassword = password;

    _status = AuthStatus.emailNotVerified;
    return true;
  }

  Future<bool> loginAfterEmailVerification() async {
    _setLoading();

    // STEP 1: Reload status user dari server Firebase
    await _firebaseUser?.reload();
    _firebaseUser = _auth.currentUser;

    if (!(_firebaseUser?.emailVerified ?? false)) {
      // Belum klik link → kembali ke halaman verify
      _status = AuthStatus.emailNotVerified;
      return false;
    }

    // STEP 2: Re-login untuk dapat fresh session & token
    final credential = await _auth.signInWithEmailAndPassword(
      email: _tempEmail!,
      password: _tempPassword!,
    );
    _firebaseUser = credential.user;
    _tempEmail = null; // Hapus credentials dari memory
    _tempPassword = null;

    // STEP 3: Kirim Firebase token ke backend → dapat JWT
    return await _verifyTokenToBackend();
  }

  Future<bool> _verifyTokenToBackend() async {
    // Ambil Firebase ID Token (expired tiap 1 jam)
    final firebaseToken = await _firebaseUser?.getIdToken();

    // POST ke backend — DioClient interceptor sudah handle logging
    final response = await DioClient.instance.post(
      AppConstants.verifyToken,
      data: {'firebase_token': firebaseToken},
    );

    // Backend return JWT milik sistem kita
    final data = response.data['data'] as Map<String, dynamic>;
    final backendToken = data['access_token'] as String;

    // Simpan aman di device (encrypted)
    await SecureStorage.saveToken(backendToken);

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }
}
