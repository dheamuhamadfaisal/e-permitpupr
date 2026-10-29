# 🏗️ E-Permit PUPR (Aplikasi Perizinan Tata Ruang)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/Provider-6.1.2-blue?style=for-the-badge)](https://pub.dev/packages/provider)
[![HTTP Client](https://img.shields.io/badge/Dio-5.7.0-%232D3748?style=for-the-badge)](https://pub.dev/packages/dio)
[![Navigation](https://img.shields.io/badge/Go__Router-14.6.2-%2302569B?style=for-the-badge)](https://pub.dev/packages/go_router)

Aplikasi mobile berbasis **Flutter** untuk digitalisasi dan pengelolaan layanan perizinan tata ruang pada **Dinas Pekerjaan Umum dan Penataan Ruang (PUPR)**. Dirancang untuk mempermudah masyarakat dalam mengajukan perizinan secara transparan, akurat, dan terintegrasi dengan RESTful API backend (Laravel Sanctum).

---

## 📑 Daftar Isi
- [✨ Fitur Utama](#-fitur-utama)
- [👥 Multi-Role & Hak Akses](#-multi-role--hak-akses)
- [🛠️ Teknologi & Dependensi](#️-teknologi--dependensi)
- [📂 Struktur Folder Project](#-struktur-folder-project)
- [🚀 Cara Menjalankan Aplikasi](#-cara-menjalankan-aplikasi)
- [🌐 Konfigurasi Jaringan & Backend API](#-konfigurasi-jaringan--backend-api)
- [👨‍💻 Pengembang & Kerja Praktik](#-pengembang--kerja-praktik)

---

## ✨ Fitur Utama

- 🔐 **Autentikasi Aman & Fleksibel**: Login email/password dan integrasi Google Sign-In dengan token Bearer (Laravel Sanctum).
- 📝 **Pengajuan Permohonan Multi-Step**: Formulir interaktif pengajuan perizinan tata ruang (KRK, Site Plan, PKKPR, dsb.).
- 📁 **Manajemen Berkas & Dokumen Lengkap**:
  - Upload file (PDF, Gambar, DWG, SHP, KML, KMZ) dengan validasi ukuran & format berkas.
  - Dukungan integrasi tautan Cloud Storage / Google Drive publik yang tervalidasi.
  - Fitur **Simpan Draft** permohonan otomatis untuk kemudahan pengguna.
- 🔍 **Tracking Status Real-Time**: Pelacakan status permohonan dari verifikasi, tinjauan teknis, validasi petugas, hingga penerbitan dokumen izin.
- 🔔 **Notifikasi & Riwayat**: Update berkala mengenai progres dan riwayat permohonan.
- 📊 **Monitoring & Manajemen Data**: Dashboard informatif untuk pemohon maupun pengelola dinas.

---

## 👥 Multi-Role & Hak Akses

Aplikasi ini mendukung 5 role pengguna dengan alur kerja yang terstruktur:

| Role | Tanggung Jawab & Fitur Utama |
| :--- | :--- |
| **Pemohon** | Registrasi, pengajuan perizinan, simpan draft, lacak status permohonan, unduh dokumen SK/izin permohonan. |
| **Verifikator** | Pemeriksaan berkas dan validasi kelengkapan dokumen persyaratan pemohon. |
| **Petugas Teknis** | Peninjauan teknis lapangan, input berita acara, dan validasi persyaratan teknis perizinan. |
| **Operator** | Pengelolaan operasional permohonan masuk dan koordinasi berkas. |
| **Admin** | Manajemen pengguna (*user management*), master data jenis perizinan, dan monitoring seluruh permohonan. |

---

## 🛠️ Teknologi & Dependensi

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.11.0`)
- **State Management**: `provider: ^6.1.2`
- **Routing**: `go_router: ^14.6.2`
- **Networking**: `dio: ^5.7.0` (REST API & Upload Multipart)
- **Local Storage**: `shared_preferences: ^2.3.3` (Penyimpanan Token & Sesi)
- **Autentikasi**: `google_sign_in: ^6.2.1` & `firebase_core: 2.32.0`
- **Media & File Handling**:
  - `file_picker: ^8.1.7`
  - `image_picker: ^1.2.3`
  - `image_cropper: ^12.2.1`
  - `open_filex: ^4.7.0`
  - `path_provider: ^2.1.6`
- **UI Components & Utilities**:
  - `curved_navigation_bar: ^1.0.6`
  - `cupertino_icons: ^1.0.8`
  - `intl: ^0.20.2` (Format tanggal, mata uang, dan waktu Indonesia)
  - `url_launcher: ^6.3.1`

---

## 📂 Struktur Folder Project

```text
lib/
├── app.dart                   # Root MaterialApp & konfigurasi tema global
├── main.dart                  # Entry point aplikasi & inisialisasi service
├── firebase_options.dart      # Konfigurasi Firebase
├── core/                      # Fondasi & utilitas umum
│   ├── constants/             # Konfigurasi URL API & konstanta sistem
│   ├── theme/                 # Palet warna & tipografi aplikasi
│   └── utils/                 # Helper, formater, dan custom exceptions
├── features/                  # Modul fitur berbasis domain
│   ├── admin/                 # Screen & widget kelola perizinan & pengguna
│   ├── auth/                  # Login, register, forgot password
│   ├── dashboard/             # Dashboard dinamis per role
│   ├── navigation/            # Bottom navigation bar & wrapper
│   ├── notification/          # Halaman pemberitahuan & notifikasi
│   ├── operator/              # Fitur operasional perizinan
│   ├── pemohon/               # Form pengajuan, tracking, & detail berkas
│   ├── petugas/               # Fitur pemeriksaan teknis petugas
│   ├── profile/               # Pengaturan akun, ganti password, & biodata
│   └── verifikator/           # Verifikasi dokumen berkas
├── models/                    # Data transfer object (DTO) & deserialisasi JSON
├── providers/                 # State management (ChangeNotifier)
├── repositories/              # Abstraksi data layer & komunikasi API
├── routes/                    # Definisi rute GoRouter & middleware proteksi role
├── services/                  # Integrasi API Dio & native device service
└── widgets/                   # Komponen UI modular & reusable
```

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Prasyarat
- Pastikan sudah menginstal **Flutter SDK** (versi 3.11.0 atau lebih baru)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Git terpasang di komputer

### 2. Kloning Repository
```bash
git clone https://github.com/dheamuhamadfaisal/e-permitpupr.git
cd e-permitpupr
```

### 3. Pasang Dependensi
```bash
flutter pub get
```

### 4. Menjalankan Aplikasi
Jalankan aplikasi di perangkat Android fisik atau emulator:
```bash
flutter run
```

---

## 🌐 Konfigurasi Jaringan & Backend API

File konfigurasi API terpusat berada di:
`lib/core/constants/api_constants.dart`

### Menghubungkan ke Backend Lokal (Laravel):

1. **Menggunakan Kabel USB (Rekomendasi via ADB Reverse)**:
   Jalankan perintah ini di terminal agar HP dapat mengakses server lokal laptop via `127.0.0.1:8000`:
   ```bash
   adb reverse tcp:8000 tcp:8000
   ```
2. **Menggunakan Jaringan Wi-Fi yang Sama**:
   Ganti IP pada `api_constants.dart` dengan alamat IP lokal komputer Anda (contoh: `http://192.168.1.x:8000`).

---

## 👨‍💻 Pengembang & Kerja Praktik

Aplikasi ini dikembangkan dalam rangka pelaksanaan **Kerja Praktik (KP)**:
- **Pengembang**: [Dhea Muhamad Faisal](https://github.com/dheamuhamadfaisal)
- **Instansi**: Dinas Pekerjaan Umum dan Penataan Ruang (PUPR)
- **Tahun**: 2026
