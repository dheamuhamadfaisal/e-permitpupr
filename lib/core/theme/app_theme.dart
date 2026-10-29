// ============================================================
// app_theme.dart — Sistem Tema Global Aplikasi e-License PUPR Garut
// ============================================================
//
// File ini mendefinisikan seluruh palet warna dan konfigurasi tema
// yang digunakan secara konsisten di seluruh aplikasi.
//
// Filosofi desain:
// - Biru tua (#1D3B6F) = warna utama identitas Dinas PUPR
// - Kuning emas (#F5B800) = aksen resmi (tombol login, highlight)
// - Semua warna harus diambil dari AppTheme, bukan hard-code di widget
// ============================================================

import 'package:flutter/material.dart';

/// Kelas tema global aplikasi PUPR Perizinan (e-License PUPR Garut).
///
/// Menggunakan Material Design 3 (useMaterial3: true).
///
/// Cara penggunaan:
/// ```dart
/// // Di widget, akses warna:
/// color: AppTheme.primaryColor
///
/// // Di MaterialApp:
/// theme: AppTheme.lightTheme,
/// ```
class AppTheme {
  /// Private constructor — kelas ini tidak perlu diinstansiasi.
  AppTheme._();

  // ---------------------------------------------------------------------------
  // PALET WARNA — Identitas Visual Dinas PUPR Garut
  // ---------------------------------------------------------------------------

  /// Biru tua (#1D3B6F) — warna primer brand PUPR.
  /// Digunakan: AppBar, tombol utama, ikon aktif, header section.
  static const Color primaryColor = Color(0xFF1D3B6F);

  /// Biru agak terang (#2B5292) — digunakan untuk hover/active state
  /// atau elemen sekunder yang masih biru.
  static const Color primaryLight = Color(0xFF2B5292);

  /// Kuning Emas (#F5B800) — warna aksen khas PUPR.
  /// Digunakan: background tombol login, border aktif, highlight penting.
  static const Color goldColor = Color(0xFFF5B800);

  /// Oranye/Emas (#E89E00) — turunan goldColor untuk state hover/pressed.
  static const Color accentColor = Color(0xFFE89E00);

  /// Background utama scaffold (#F8FAFC) — off-white yang lembut.
  /// Lebih baik dari putih murni agar mata tidak lelah.
  static const Color backgroundColor = Color(0xFFF8FAFC);

  /// Warna permukaan card/container (#FFFFFF) — putih murni.
  static const Color surfaceColor = Color(0xFFFFFFFF);

  /// Warna teks utama (#1E293B) — hampir hitam (slate-900).
  /// Digunakan untuk judul, label form, teks penting.
  static const Color textPrimary = Color(0xFF1E293B);

  /// Warna teks sekunder (#64748B) — abu-abu (slate-500).
  /// Digunakan untuk placeholder, subtitle, hint text.
  static const Color textSecondary = Color(0xFF64748B);

  /// Warna border (#E2E8F0) — abu-abu sangat muda (slate-200).
  /// Digunakan untuk garis pembatas card, input field.
  static const Color borderColor = Color(0xFFE2E8F0);

  /// Warna error (#EF4444) — merah terang untuk pesan error.
  static const Color errorColor = Color(0xFFEF4444);

  /// Warna sukses (#10B981) — hijau teal untuk status berhasil.
  static const Color successColor = Color(0xFF10B981);

  // ---------------------------------------------------------------------------
  // LIGHT THEME — Tema utama aplikasi (mode terang)
  // ---------------------------------------------------------------------------

  /// Mengembalikan [ThemeData] lengkap untuk mode terang.
  ///
  /// Komponen yang dikonfigurasi:
  /// - ColorScheme: palet warna Material 3
  /// - AppBar: biru tua dengan judul putih
  /// - ElevatedButton: background kuning emas, teks biru tua
  /// - InputDecoration: gaya underline bukan outline
  /// - Card: sudut bulat, shadow tipis
  static ThemeData get lightTheme {
    return ThemeData(
      // Aktifkan Material Design 3 (versi terbaru dari Google)
      useMaterial3: true,

      // Buat color scheme dari warna seed (primer)
      // Material 3 akan menghasilkan palet warna otomatis dari seedColor
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,    // Warna primer (biru tua)
        secondary: goldColor,     // Warna sekunder (emas)
        surface: surfaceColor,    // Permukaan card/dialog
        error: errorColor,        // Warna pesan error
      ),

      // Background seluruh Scaffold
      scaffoldBackgroundColor: backgroundColor,

      // -----------------------------------------------------------------------
      // Konfigurasi AppBar
      // -----------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,      // Background biru tua
        foregroundColor: Colors.white,      // Ikon dan teks putih
        elevation: 0,                       // Tanpa bayangan (flat design)
        centerTitle: true,                  // Judul selalu di tengah
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,      // Semi-bold
        ),
        iconTheme: IconThemeData(color: Colors.white), // Ikon back/menu putih
      ),

      // -----------------------------------------------------------------------
      // Konfigurasi ElevatedButton (tombol utama)
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,       // Background kuning emas
          foregroundColor: primaryColor,    // Teks biru tua (kontras dengan emas)
          elevation: 0,                     // Flat (tanpa bayangan)
          minimumSize: const Size(double.infinity, 50), // Full width, tinggi 50px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Sudut bulat
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Konfigurasi Input Field (TextField, TextFormField)
      // Menggunakan gaya underline (bukan outline box) untuk kesan minimalis
      // -----------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: false,                       // Tanpa background fill
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),

        // Border bawah saat field tidak aktif (abu-abu muda)
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        // Border bawah saat field aktif/dipilih (biru tua, lebih tebal)
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        // Border bawah saat ada error validasi (merah)
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 1.2),
        ),
        // Border bawah saat aktif + ada error
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 2),
        ),

        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),  // Label abu-abu
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14), // Hint lebih muda
        prefixIconColor: primaryColor,   // Ikon di kiri field: biru tua
        suffixIconColor: textSecondary,  // Ikon di kanan field: abu-abu
      ),

      // -----------------------------------------------------------------------
      // Konfigurasi Card (Container berisi konten dengan sudut bulat)
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: surfaceColor,                         // Background putih
        elevation: 1,                                // Bayangan tipis
        shadowColor: Colors.black.withValues(alpha: 0.05), // Shadow hampir transparan
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),   // Sudut bulat 16px
          side: const BorderSide(color: borderColor), // Border abu-abu muda
        ),
      ),
    );
  }
}
