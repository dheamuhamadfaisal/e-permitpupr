import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan token Sanctum secara lokal menggunakan SharedPreferences.
///
/// KEAMANAN:
/// - Hanya menyimpan token Sanctum, TIDAK menyimpan password
/// - Token tidak pernah ditampilkan ke UI
/// - Token otomatis dihapus saat logout
class TokenStorage {
  TokenStorage._();

  static const String _tokenKey = 'sanctum_token';

  /// Simpan token Sanctum setelah login/register berhasil.
  /// Password TIDAK boleh dikirim ke sini.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Ambil token yang tersimpan. Kembalikan null jika belum login.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Hapus token — dipanggil saat logout atau sesi expired.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Cek apakah token tersedia (user sudah pernah login).
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
