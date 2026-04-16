import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
}
