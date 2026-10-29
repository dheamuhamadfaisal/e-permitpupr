// ============================================================
// dio_client.dart — HTTP Client Terpusat dengan Interceptor
// ============================================================
//
// File ini menyediakan satu instance Dio yang digunakan oleh
// SEMUA service di aplikasi. Pendekatan ini disebut Singleton.
//
// Fitur yang sudah tersedia:
// - Authorization: Bearer {token} otomatis di setiap request (jika ada token)
// - Accept: application/json selalu ada di header
// - Error handling terpusat: semua error HTTP dikonversi ke ApiException
// - Timeout konfigurasi: connect, receive, send
// - Extension helper: postFormData untuk upload file multipart
// ============================================================

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import '../utils/api_exception.dart';

/// Client HTTP terpusat berbasis [Dio] dengan interceptor otomatis.
///
/// Pola Singleton digunakan agar hanya ada satu instance Dio di seluruh
/// aplikasi. Ini menghemat memori dan memastikan konfigurasi konsisten.
///
/// Cara penggunaan di Service:
/// ```dart
/// class AuthService {
///   final Dio _dio = DioClient.instance;
///   // ...
/// }
/// ```
class DioClient {
  /// Private constructor — mencegah instansiasi dari luar kelas.
  DioClient._();

  /// Instance Dio tunggal (nullable, lazy initialization).
  /// Akan dibuat saat pertama kali diakses melalui getter [instance].
  static Dio? _instance;

  /// Getter yang mengembalikan instance Dio.
  ///
  /// Jika belum ada (_instance null), buat dulu via [_createDio].
  /// Pattern ini disebut "lazy singleton".
  static Dio get instance {
    _instance ??= _createDio(); // Buat instance jika belum ada
    return _instance!;
  }

  /// Factory method untuk membuat dan mengkonfigurasi instance Dio baru.
  ///
  /// Konfigurasi yang diterapkan:
  /// - Base URL dari [ApiConstants.baseUrl]
  /// - Timeout: connect, receive, send (masing-masing 30 detik)
  /// - Default headers: Accept: application/json, Content-Type: application/json
  /// - Interceptor: _AuthInterceptor (tambah token) + _ErrorInterceptor (handle error)
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,          // URL server Laravel backend
        connectTimeout: ApiConstants.connectTimeout,  // Batas waktu koneksi
        receiveTimeout: ApiConstants.receiveTimeout,  // Batas waktu terima data
        sendTimeout: ApiConstants.sendTimeout,        // Batas waktu kirim data
        headers: {
          'Accept': 'application/json',         // Backend mengirim response JSON
          'Content-Type': 'application/json',   // Kita kirim body berformat JSON
        },
      ),
    );

    // Pasang dua interceptor secara berurutan:
    // 1. _AuthInterceptor: dipanggil SEBELUM request dikirim (tambah token)
    // 2. _ErrorInterceptor: dipanggil saat ada ERROR dari response
    dio.interceptors.addAll([
      _AuthInterceptor(),   // Otomatis sisipkan token di setiap request
      _ErrorInterceptor(),  // Konversi semua error ke ApiException
    ]);

    return dio;
  }

  /// Reset instance Dio (nullkan kembali).
  ///
  /// Berguna untuk:
  /// - Unit testing (agar setiap test punya instance bersih)
  /// - Setelah logout (agar konfigurasi token tidak bocor ke sesi berikutnya)
  static void reset() {
    _instance = null;
  }
}

// ---------------------------------------------------------------------------
// Auth Interceptor — Otomatis tambahkan Bearer Token ke setiap request
// ---------------------------------------------------------------------------

/// Interceptor yang dipanggil SEBELUM setiap HTTP request dikirim.
///
/// Tugasnya: membaca token dari [TokenStorage] dan menambahkannya
/// ke header `Authorization: Bearer {token}`.
///
/// Jika tidak ada token (user belum login), header Authorization
/// tidak ditambahkan — request tetap dikirim tanpa token
/// (untuk endpoint publik seperti login/register).
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ambil token Sanctum dari penyimpanan lokal (SharedPreferences)
    final token = await TokenStorage.getToken();

    // Jika token ada dan tidak kosong, sisipkan ke header Authorization
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Pastikan header Accept selalu ada (backend Laravel butuh ini)
    options.headers['Accept'] = 'application/json';

    // Lanjutkan request ke server
    handler.next(options);
  }
}

// ---------------------------------------------------------------------------
// Error Interceptor — Konversi semua HTTP error ke ApiException
// ---------------------------------------------------------------------------

/// Interceptor yang dipanggil saat terjadi ERROR dari response HTTP.
///
/// Tugasnya: mengubah berbagai jenis error Dio (timeout, no internet,
/// HTTP 4xx/5xx) menjadi [ApiException] yang mudah ditangkap di repository
/// atau provider dengan `on ApiException catch (e)`.
///
/// Tanpa interceptor ini, developer harus menangani setiap jenis error
/// secara manual di setiap service — sangat repetitif.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException exception;

    switch (err.type) {
      // Timeout: koneksi, pengiriman, atau penerimaan melebihi batas waktu
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = const TimeoutException();

      // Tidak ada koneksi internet atau server tidak bisa dijangkau
      case DioExceptionType.connectionError:
        exception = const NetworkException();

      // Server mengembalikan response dengan status code 4xx atau 5xx
      case DioExceptionType.badResponse:
        exception = _handleBadResponse(err.response);

      // Error lainnya yang tidak terduga (SSL error, dll.)
      default:
        exception = ApiException(
          message: 'Terjadi Kesalahan Tidak Terduga.',
          statusCode: err.response?.statusCode,
        );
    }

    // Bungkus exception sebagai error Dio agar bisa di-catch di service/repository
    // dengan: on DioException catch (e) { if (e.error is ApiException) ... }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,        // ApiException disimpan di field 'error'
        type: err.type,
        response: err.response,
      ),
    );
  }

  /// Memproses response HTTP yang mengembalikan status error (4xx, 5xx).
  ///
  /// Mengekstrak pesan error dari body response Laravel (format JSON),
  /// atau menggunakan pesan default berdasarkan status code.
  ApiException _handleBadResponse(Response? response) {
    // Jika tidak ada response sama sekali (server down total)
    if (response == null) {
      return const ApiException(message: 'Tidak Ada Respons dari Server.');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    // Coba ambil pesan error dari body JSON response backend Laravel
    String message = _extractMessage(data, statusCode);

    // Coba ambil detail error validasi (field-level errors untuk form)
    Map<String, dynamic>? errors = _extractErrors(data);

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors, // null jika bukan error validasi
    );
  }

  /// Mengekstrak pesan error dari body response JSON Laravel.
  ///
  /// Laravel mengembalikan format:
  /// ```json
  /// { "success": false, "message": "Pesan error di sini" }
  /// ```
  ///
  /// Jika tidak ada field 'message', gunakan pesan default per status code.
  String _extractMessage(dynamic data, int? statusCode) {
    // Cek apakah response body adalah Map JSON
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message') && data['message'] is String) {
        final msg = data['message'] as String;
        if (msg.isNotEmpty) {
          // Deteksi error koneksi database (XAMPP/MySQL belum nyala)
          // Ubah pesan teknis menjadi pesan yang ramah pengguna
          if (msg.contains('SQLSTATE[HY000] [2002]') ||
              msg.contains('No connection could be made')) {
            return 'Gagal terhubung ke database. Pastikan server database Anda (seperti XAMPP/MySQL) sudah menyala.';
          }
          // Error SQL lainnya
          if (msg.contains('SQLSTATE')) {
            return 'Terjadi gangguan pada database server.';
          }
          return msg; // Gunakan pesan asli dari server
        }
      }
    }

    // Pesan default berdasarkan HTTP status code
    return switch (statusCode) {
      400 => 'Permintaan Tidak Valid.',
      401 => 'Sesi Berakhir. Silakan Login Kembali.',       // Token expired/invalid
      403 => 'Anda Tidak Memiliki Akses Ke Halaman Ini.',  // Role tidak sesuai
      404 => 'Data Tidak Ditemukan.',
      422 => 'Data yang Dimasukkan Tidak Valid.',           // Validation error
      500 => 'Terjadi Kesalahan Pada Server.',
      _   => 'Terjadi Kesalahan. Kode: $statusCode',
    };
  }

  /// Mengekstrak detail error validasi per-field dari response Laravel.
  ///
  /// Laravel mengembalikan format:
  /// ```json
  /// {
  ///   "errors": {
  ///     "email": ["Email sudah terdaftar."],
  ///     "password": ["Password minimal 8 karakter."]
  ///   }
  /// }
  /// ```
  ///
  /// Data ini digunakan untuk menampilkan pesan error di bawah masing-masing
  /// field form menggunakan [ApiException.getFieldError].
  Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) return errors;
    }
    return null; // Tidak ada error per-field
  }
}

// ---------------------------------------------------------------------------
// Extension DioClientExtension — Helper untuk upload file multipart
// ---------------------------------------------------------------------------

/// Extension pada [Dio] untuk menyederhanakan pengiriman data multipart/form-data.
///
/// Digunakan untuk upload file (foto, PDF, dll.) ke backend Laravel.
///
/// Contoh penggunaan:
/// ```dart
/// await _dio.postFormData(
///   '/api/permohonan/dokumen',
///   data: {
///     'jenis_dokumen': 'KTP',
///     'file': await MultipartFile.fromFile(filePath),
///   },
/// );
/// ```
extension DioClientExtension on Dio {
  /// Helper method untuk POST multipart/form-data.
  ///
  /// Secara otomatis mengatur Content-Type ke 'multipart/form-data'.
  /// Data harus berisi [MultipartFile] untuk file, atau String untuk teks.
  Future<Response> postFormData(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    return post(
      path,
      data: FormData.fromMap(data), // Konversi Map menjadi FormData
      options: Options(contentType: 'multipart/form-data'), // Override content type
    );
  }
}
