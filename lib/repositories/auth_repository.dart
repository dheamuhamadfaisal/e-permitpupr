import '../core/storage/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Business logic layer untuk authentication.
///
/// Bertanggung jawab untuk:
/// - Koordinasi antara [AuthService] dan [TokenStorage]
/// - Memastikan token disimpan setelah login/register
/// - Memastikan token dihapus setelah logout
/// - TIDAK menyimpan password di storage
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  /// Register pemohon baru.
  ///
  /// Flow:
  /// 1. Kirim data ke API
  /// 2. Terima token dari response
  /// 3. Simpan token ke TokenStorage (bukan password)
  /// 4. Return UserModel
  Future<UserModel> register({
    required String name,
    required String alamat,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // Panggil service — password HANYA dikirim ke server, tidak disimpan lokal
    final result = await _authService.register(
      name: name,
      alamat: alamat,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    // Tidak otomatis login (tidak menyimpan token ke storage)

    return result.user;
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Login dengan email dan password.
  ///
  /// Flow:
  /// 1. Kirim email + password ke API
  /// 2. Terima token dari response
  /// 3. Simpan token ke TokenStorage
  /// 4. Panggil /api/auth/me untuk mendapatkan data user terbaru
  /// 5. Return UserModel
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Kirim ke server — password TIDAK disimpan setelahnya
    final result = await _authService.login(
      email: email,
      password: password,
    );

    // Simpan token Sanctum
    await TokenStorage.saveToken(result.token);

    // Ambil data user terbaru dari /api/auth/me
    // Ini memastikan data user selalu sinkron dengan server
    try {
      final freshUser = await _authService.me();
      return freshUser;
    } catch (_) {
      // Jika me() gagal, gunakan data dari login response
      return result.user;
    }
  }

  Future<UserModel> googleLogin({
    required String email,
    required String name,
    required String googleId,
    String? avatar,
  }) async {
    final result = await _authService.googleLogin(
      email: email,
      name: name,
      googleId: googleId,
      avatar: avatar,
    );

    await TokenStorage.saveToken(result.token);

    try {
      final freshUser = await _authService.me();
      return freshUser;
    } catch (_) {
      return result.user;
    }
  }

  // ---------------------------------------------------------------------------
  // Check Authentication (saat app dibuka)
  // ---------------------------------------------------------------------------

  /// Cek apakah user sudah login dan token masih valid.
  ///
  /// Flow:
  /// 1. Cek token di storage
  /// 2. Jika tidak ada token → return null
  /// 3. Jika ada token → panggil /api/auth/me
  /// 4. Jika me() berhasil → return UserModel
  /// 5. Jika me() gagal (401) → hapus token → return null
  Future<UserModel?> checkAuth() async {
    final hasToken = await TokenStorage.hasToken();
    if (!hasToken) return null;

    try {
      final user = await _authService.me();
      return user;
    } catch (_) {
      // Token sudah tidak valid — hapus dari storage
      await TokenStorage.clearToken();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Logout user.
  ///
  /// Flow:
  /// 1. Panggil POST /api/auth/logout ke server (opsional gagal)
  /// 2. Hapus token dari storage
  ///
  /// Jika API logout gagal karena token sudah invalid,
  /// token lokal TETAP dihapus.
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      // Selalu hapus token lokal, bahkan jika server error
      await TokenStorage.clearToken();
    }
  }

  Future<UserModel> uploadAvatar(String imagePath) async {
    return await _authService.uploadAvatar(imagePath);
  }
}
