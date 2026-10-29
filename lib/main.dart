// ============================================================
// main.dart — Titik masuk (entry point) aplikasi Flutter
// Aplikasi: e-License PUPR Garut (Sistem Perizinan Tata Ruang)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

/// Fungsi [main] adalah titik pertama yang dieksekusi saat aplikasi dibuka.
///
/// Urutan inisialisasi:
/// 1. [WidgetsFlutterBinding.ensureInitialized] — wajib dipanggil sebelum
///    operasi async apa pun di dalam main(), agar Flutter binding siap digunakan.
/// 2. Paksa orientasi layar portrait — aplikasi perizinan ini tidak mendukung
///    landscape agar tampilan konsisten di semua perangkat.
/// 3. Konfigurasi status bar — transparan agar tampilan lebih premium.
/// 4. [runApp] — jalankan root widget [PuprPerizinanApp].
void main() async {
  // Wajib dipanggil sebelum menggunakan plugin atau operasi async di main()
  WidgetsFlutterBinding.ensureInitialized();

  // Paksa orientasi portrait untuk aplikasi perizinan
  // Alasan: Layout UI dirancang hanya untuk portrait, landscape bisa merusak tampilan
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,    // Portrait normal
    DeviceOrientation.portraitDown,  // Portrait terbalik (untuk aksesibilitas)
  ]);

  // Konfigurasi tampilan status bar (bar di bagian atas layar)
  // statusBarColor: transparan agar warna AppBar terlihat penuh ke atas
  // statusBarIconBrightness: dark agar ikon (wifi, baterai, jam) terlihat di latar terang
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Jalankan root widget aplikasi
  runApp(const PuprPerizinanApp());
}
