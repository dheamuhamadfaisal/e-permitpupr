// ============================================================
// api_constants.dart — Konfigurasi URL API Terpusat
// ============================================================
//
// ATURAN PENTING:
// - JANGAN pernah hard-code URL API di file lain.
// - Semua endpoint dan Base URL harus diambil dari file ini.
// - Jika backend pindah alamat, cukup ubah di sini saja.
// ============================================================

import 'package:flutter/foundation.dart';

/// Kelas konfigurasi API yang bersifat terpusat (centralized).
///
/// Semua Base URL dan endpoint REST API Laravel backend
/// didefinisikan di sini sebagai konstanta atau getter statis.
///
/// Penggunaan:
/// ```dart
/// final response = await dio.post(ApiConstants.login, data: {...});
/// ```
class ApiConstants {
  /// Private constructor — kelas ini tidak boleh di-instansiasi,
  /// semua propertinya adalah static.
  ApiConstants._();

  // ---------------------------------------------------------------------------
  // BASE URL — Otomatis menyesuaikan platform yang menjalankan aplikasi
  // ---------------------------------------------------------------------------

  /// [baseUrl] mengembalikan URL server backend Laravel berdasarkan platform.
  ///
  /// Kenapa berbeda per platform?
  /// - Android Emulator: tidak bisa akses `localhost` langsung, butuh IP khusus
  ///   `10.0.2.2` yang merupakan alias host komputer dari dalam emulator.
  /// - iOS Simulator & Desktop: bisa akses `127.0.0.1` langsung.
  /// - Physical Device (HP sungguhan): harus menggunakan IP komputer di jaringan
  ///   yang sama, contoh: `http://192.168.1.19:8000`.
  ///
  /// Cara koneksi yang disarankan untuk Android physical device:
  /// 1. **USB (Recommended)**: `adb reverse tcp:8000 tcp:8000`
  ///    lalu gunakan `127.0.0.1:8000`
  /// 2. **Wi-Fi**: ganti dengan IP komputer di jaringan lokal
  static String get baseUrl {
    // Jika berjalan di Web (browser), gunakan localhost langsung
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Untuk platform native, cek platform secara eksplisit
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Opsi 1 (Aktif): USB + adb reverse — paling stabil, tanpa konfigurasi jaringan
        return 'http://127.0.0.1:8000';

        // Opsi 2 (Non-aktif): Wi-Fi tanpa kabel USB
        // Uncomment baris di bawah jika tidak menggunakan kabel USB
        // Ganti dengan IP laptop Anda di jaringan Wi-Fi saat ini:
        // return 'http://192.168.1.19:8000';

      case TargetPlatform.iOS:
        // iOS Simulator dapat langsung mengakses localhost komputer
        return 'http://127.0.0.1:8000';

      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Desktop dapat akses localhost secara langsung
        return 'http://127.0.0.1:8000';

      default:
        return 'http://127.0.0.1:8000';
    }
  }

  // ---------------------------------------------------------------------------
  // TIMEOUT CONFIGURATION
  // Durasi maksimum untuk berbagai fase komunikasi HTTP
  // ---------------------------------------------------------------------------

  /// Batas waktu untuk membuat koneksi TCP ke server (30 detik)
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Batas waktu untuk menerima response dari server setelah koneksi terbuat (30 detik)
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Batas waktu untuk mengirim data ke server (30 detik) — penting untuk upload file
  static const Duration sendTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // AUTHENTICATION ENDPOINTS (Public — tidak membutuhkan token)
  // ---------------------------------------------------------------------------

  /// `POST /api/auth/register`
  /// Registrasi akun baru sebagai Pemohon.
  /// Body: name, alamat, phone, email, password, password_confirmation
  static const String register = '/api/auth/register';

  /// `POST /api/auth/login`
  /// Login untuk semua role (pemohon, operator, petugas, verifikator, admin).
  /// Body: email, password
  /// Response: { user, token }
  static const String login = '/api/auth/login';

  /// `POST /api/auth/google`
  /// Login atau registrasi otomatis menggunakan akun Google.
  /// Body: email, name, google_id, avatar (opsional)
  static const String googleLogin = '/api/auth/google';

  // ---------------------------------------------------------------------------
  // AUTHENTICATION ENDPOINTS (Private — membutuhkan token Bearer Sanctum)
  // ---------------------------------------------------------------------------

  /// `GET /api/auth/me`
  /// Mengambil data profil user yang sedang login berdasarkan token.
  /// Digunakan saat splash screen untuk validasi sesi.
  static const String me = '/api/auth/me';

  /// `POST /api/auth/logout`
  /// Logout: menghapus token Sanctum dari database server.
  /// Setelah ini, token yang sama tidak bisa digunakan lagi.
  static const String logout = '/api/auth/logout';

  // ---------------------------------------------------------------------------
  // PROFILE ENDPOINTS (Private — semua role bisa mengakses)
  // ---------------------------------------------------------------------------

  /// `GET /api/profile`
  /// Tampilkan data profil user yang sedang login.
  static const String profile = '/api/profile';

  /// `PUT /api/profile`
  /// Update profil user: name, alamat, phone, email.
  /// Body: field yang ingin diubah saja (partial update).
  static const String profileUpdate = '/api/profile';

  /// `PUT /api/profile/password`
  /// Ganti password user yang sedang login.
  /// Body: current_password, password, password_confirmation
  static const String profilePassword = '/api/profile/password';
}
