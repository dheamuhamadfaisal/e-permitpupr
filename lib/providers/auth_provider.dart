import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../core/utils/api_exception.dart';

/// Status authentication untuk state management.
enum AuthStatus {
  /// Sedang memeriksa token (splash screen)
  checking,

  /// Belum login — tampilkan LoginScreen
  unauthenticated,

  /// Sudah login — tampilkan HomeScreen/Dashboard
  authenticated,

  /// Sedang proses login/register/logout
  loading,
}

/// Provider untuk state authentication.
///
/// Digunakan oleh:
/// - SplashScreen: cek token saat app dibuka
/// - LoginScreen: form login
/// - RegisterScreen: form register
/// - GoRouter: route guard berdasarkan status
///
/// Menyimpan: [user] dan [status].
/// TIDAK menyimpan password.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  AuthStatus _status = AuthStatus.checking;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isChecking => _status == AuthStatus.checking;

  // ---------------------------------------------------------------------------
  // Check auth saat app dibuka (Splash)
  // ---------------------------------------------------------------------------

  /// Dipanggil dari SplashScreen.
  /// Cek token → validate dengan /api/auth/me.
  Future<void> checkAuth() async {
    _setStatus(AuthStatus.checking);

    try {
      final user = await _repository.checkAuth();

      if (user != null) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
      } else {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (_) {
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Login dengan email dan password.
  /// Password TIDAK disimpan di provider.
  ///
  /// Return true jika berhasil, false jika gagal.
  /// Gunakan [errorMessage] untuk menampilkan pesan error.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    _clearError();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
        // password tidak disimpan setelah dikirim ke repository
      );

      _user = user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi Kesalahan. Silakan Coba Lagi.';
      _setStatus(AuthStatus.unauthenticated);
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> loginWithGoogle({
    required String email,
    required String name,
    required String googleId,
    String? avatar,
  }) async {
    _setLoading();
    _clearError();

    try {
      final user = await _repository.googleLogin(
        email: email,
        name: name,
        googleId: googleId,
        avatar: avatar,
      );

      _user = user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi Kesalahan Saat Login Dengan Google.';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  /// Register pemohon baru.
  /// Role otomatis: pemohon (diset di backend).
  /// Tidak ada pilihan role di form register.
  ///
  /// Return true jika berhasil.
  Future<bool> register({
    required String name,
    required String alamat,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading();
    _clearError();

    try {
      await _repository.register(
        name: name,
        alamat: alamat,
        phone: phone,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      // Jangan otomatis login setelah register
      _setStatus(AuthStatus.unauthenticated);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setStatus(AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi Kesalahan. Silakan Coba Lagi.';
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Logout: hapus token, hapus session user, kembali ke Login.
  Future<void> logout() async {
    _setLoading();

    try {
      await _repository.logout();
    } finally {
      // Selalu hapus data user dari memory, bahkan jika server error
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  /// Upload foto profil user
  Future<bool> uploadAvatar(String imagePath) async {
    try {
      final updatedUser = await _repository.uploadAvatar(imagePath);
      _user = updatedUser;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Gagal Mengunggah Foto Profil.';
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
