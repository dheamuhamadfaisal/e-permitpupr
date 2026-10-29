// ============================================================
// api_exception.dart — Sistem Error Handling Terpusat
// ============================================================
//
// File ini menyediakan:
// 1. Kelas ApiException — standar exception untuk semua error API
// 2. NetworkException & TimeoutException — turunan untuk error jaringan
// 3. Extension ApiExceptionUi — helper untuk menampilkan error ke UI
//    (bottom sheet error, snackbar sukses, info, peringatan)
// ============================================================

import 'package:flutter/material.dart';

/// Exception standar untuk semua error yang berasal dari API backend.
///
/// Semua error HTTP (4xx, 5xx) dan network error dikonversi ke [ApiException]
/// oleh [_ErrorInterceptor] di DioClient, sehingga developer tidak perlu
/// parsing manual di setiap service atau repository.
///
/// Contoh penggunaan:
/// ```dart
/// try {
///   final user = await authRepository.login(...);
/// } on ApiException catch (e) {
///   print(e.message);           // Pesan yang bisa ditampilkan ke user
///   print(e.isValidationError); // true jika status 422
///   print(e.getFieldError('email')); // Error per field form
/// }
/// ```
class ApiException implements Exception {
  /// Pesan error yang ramah pengguna (siap ditampilkan di UI).
  final String message;

  /// HTTP status code dari response (null jika error jaringan/timeout).
  final int? statusCode;

  /// Map berisi error validasi per-field (hanya ada jika status 422).
  /// Format: { "email": ["Email sudah terdaftar."], "password": [...] }
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  // ---------------------------------------------------------------------------
  // Helper getter untuk memeriksa jenis error
  // ---------------------------------------------------------------------------

  /// True jika error adalah validasi form (HTTP 422 Unprocessable Content).
  /// Error ini biasanya berisi detail per-field di [errors].
  bool get isValidationError => statusCode == 422;

  /// True jika error adalah unauthorized (HTTP 401).
  /// Biasanya token expired atau tidak valid — user perlu login ulang.
  bool get isUnauthorized => statusCode == 401;

  /// True jika error adalah forbidden (HTTP 403).
  /// User sudah login tapi tidak punya hak akses ke resource tersebut.
  bool get isForbidden => statusCode == 403;

  /// True jika resource tidak ditemukan (HTTP 404).
  bool get isNotFound => statusCode == 404;

  /// True jika terjadi kesalahan di sisi server (HTTP 500 ke atas).
  bool get isServerError => statusCode != null && statusCode! >= 500;

  // ---------------------------------------------------------------------------
  // Helper untuk mengambil pesan error field tertentu
  // ---------------------------------------------------------------------------

  /// Mengambil pesan error validasi untuk field tertentu.
  ///
  /// Digunakan untuk menampilkan pesan di bawah field form.
  ///
  /// Contoh:
  /// ```dart
  /// final emailError = exception.getFieldError('email');
  /// // Returns: "Email sudah terdaftar." atau null
  /// ```
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    // Laravel mengembalikan array of strings: ["pesan 1", "pesan 2"]
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString(); // Ambil pesan pertama saja
    }
    // Kadang berupa string langsung
    if (fieldErrors is String) return fieldErrors;
    return null;
  }

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}

// ---------------------------------------------------------------------------
// Subkelas exception khusus untuk kondisi jaringan
// ---------------------------------------------------------------------------

/// Exception untuk kondisi tidak ada koneksi internet.
///
/// Dikirim oleh _ErrorInterceptor saat DioExceptionType.connectionError.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Tidak Ada Koneksi Internet. Periksa Jaringan Anda.',
    super.statusCode,
  });
}

/// Exception untuk kondisi request timeout (melebihi batas waktu).
///
/// Dikirim oleh _ErrorInterceptor saat connectionTimeout, sendTimeout,
/// atau receiveTimeout.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Koneksi Timeout. Coba Lagi Beberapa Saat.',
    super.statusCode,
  });
}

// ---------------------------------------------------------------------------
// Extension untuk menampilkan error dan notifikasi ke UI
// ---------------------------------------------------------------------------

/// Extension pada [BuildContext] untuk menyederhanakan tampilan error dan notifikasi.
///
/// Dengan extension ini, kode di widget menjadi lebih ringkas:
/// ```dart
/// context.showApiError(error);            // Bottom sheet error
/// context.showSuccessMessage('Berhasil'); // Snackbar hijau di atas
/// context.showInfoMessage('Info...');     // Snackbar biru
/// context.showWarningMessage('Hati-hati'); // Snackbar oranye
/// ```
extension ApiExceptionUi on BuildContext {

  // ---------------------------------------------------------------------------
  // showApiError — Bottom Sheet Error dengan gambar ilustrasi
  // ---------------------------------------------------------------------------

  /// Menampilkan modal bottom sheet berisi pesan error API.
  ///
  /// Cocok untuk error yang membutuhkan perhatian penuh pengguna,
  /// seperti server error, network error, atau error validasi kompleks.
  ///
  /// Fitur:
  /// - Gambar ilustrasi pekerja PUPR (assets/images/error_pekerja.png)
  /// - Judul "Oops, Terjadi Kesalahan"
  /// - Pesan error dari [ApiException.message]
  /// - Tombol "Tutup"
  void showApiError(ApiException error) {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol close di sudut kanan atas
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.black87, size: 22),
                ),
              ),
              // Gambar ilustrasi error
              Center(
                child: Image.asset(
                  'assets/images/error_pekerja.png',
                  width: 180,
                  fit: BoxFit.contain,
                  // Jika gambar tidak ditemukan, tampilkan ikon error sebagai fallback
                  errorBuilder: (context, err, stackTrace) => const Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(height: 0),
              // Judul error
              const Text(
                'Oops, Terjadi Kesalahan',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              // Pesan detail error dari ApiException
              Text(
                error.message,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              // Tombol tutup bottom sheet
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003399),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // showSuccessMessage — Snackbar hijau teal (muncul di atas layar)
  // ---------------------------------------------------------------------------

  /// Menampilkan snackbar notifikasi BERHASIL dengan desain modern.
  ///
  /// Fitur:
  /// - Ikon centang bulat
  /// - Label "Berhasil" + pesan detail
  /// - Warna teal profesional (#2A9D8F)
  /// - Muncul di atas layar (bukan bawah) dengan margin floating
  /// - Bisa di-dismiss ke atas
  /// - Otomatis hilang setelah 4 detik
  void showSuccessMessage(String message) {
    // Hitung posisi bottom agar snackbar muncul di dekat atas layar
    final bottomMargin = MediaQuery.of(this).size.height - 160;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar() // Sembunyikan snackbar yang sedang tampil (jika ada)
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              // Ikon centang dalam lingkaran semi-transparan
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Berhasil',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2A9D8F), // Teal profesional
          behavior: SnackBarBehavior.floating,        // Floating (tidak menempel dasar)
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.only(
            bottom: bottomMargin > 0 ? bottomMargin : 0, // Posisi mendekati atas
            left: 20,
            right: 20,
          ),
          dismissDirection: DismissDirection.up,  // Swipe ke atas untuk tutup
          elevation: 8,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // showInfoMessage — Snackbar biru (informasi netral)
  // ---------------------------------------------------------------------------

  /// Menampilkan snackbar notifikasi INFORMASI.
  ///
  /// Gunakan untuk informasi netral yang tidak berupa error atau sukses.
  /// Warna biru (#457B9D), durasi 3 detik.
  void showInfoMessage(String message) {
    final bottomMargin = MediaQuery.of(this).size.height - 160;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Informasi',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF457B9D), // Biru profesional
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.only(
            bottom: bottomMargin > 0 ? bottomMargin : 0,
            left: 20,
            right: 20,
          ),
          dismissDirection: DismissDirection.up,
          elevation: 8,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // showWarningMessage — Snackbar oranye (peringatan)
  // ---------------------------------------------------------------------------

  /// Menampilkan snackbar notifikasi PERINGATAN.
  ///
  /// Gunakan untuk kondisi yang membutuhkan perhatian user tapi bukan error kritis.
  /// Contoh: "Harap lengkapi profil sebelum mengajukan permohonan."
  /// Warna oranye (#F4A261), durasi 4 detik.
  void showWarningMessage(String message) {
    final bottomMargin = MediaQuery.of(this).size.height - 160;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Perhatian',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF4A261), // Oranye profesional
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.only(
            bottom: bottomMargin > 0 ? bottomMargin : 0,
            left: 20,
            right: 20,
          ),
          dismissDirection: DismissDirection.up,
          elevation: 8,
          duration: const Duration(seconds: 4),
        ),
      );
  }
}
