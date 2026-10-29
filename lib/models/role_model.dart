// ============================================================
// role_model.dart — Model Role/Peran Pengguna
// ============================================================
//
// Sistem ini menggunakan RBAC (Role-Based Access Control).
// Setiap user ditetapkan satu role yang menentukan:
// - Halaman apa yang bisa diakses
// - Fitur apa yang tersedia
// - Endpoint API mana yang bisa dipanggil
//
// Daftar role yang ada di sistem:
// - pemohon    : Masyarakat yang mengajukan perizinan
// - operator   : Staf front-office / administrasi PUPR
// - petugas    : Teknisi / surveyor lapangan
// - verifikator: Kepala bidang atau kepala dinas (pengambil keputusan)
// - admin      : Admin IT yang mengelola user dan memantau sistem
// ============================================================

/// Model Role — sesuai response backend Laravel.
///
/// Relasi di database: Many-to-Many antara User dan Role
/// melalui tabel pivot `role_user`.
///
/// Format JSON dari API:
/// ```json
/// {
///   "id": 1,
///   "name": "Pemohon",
///   "slug": "pemohon",
///   "description": "Masyarakat yang mengajukan permohonan perizinan"
/// }
/// ```
class RoleModel {
  /// ID unik role di database (primary key)
  final int id;

  /// Nama role yang bisa ditampilkan ke pengguna.
  /// Contoh: "Pemohon", "Operator", "Petugas Tata Ruang"
  final String name;

  /// Identifikasi role dalam format lowercase dengan underscore.
  /// Digunakan untuk logika kondisional dan routing.
  /// Contoh: "pemohon", "operator", "petugas", "verifikator", "admin"
  final String slug;

  /// Deskripsi opsional tentang role ini (mungkin null)
  final String? description;

  const RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  // ---------------------------------------------------------------------------
  // fromJson — Parsing dari response JSON API
  // ---------------------------------------------------------------------------

  /// Membuat instance [RoleModel] dari Map JSON.
  ///
  /// Aman terhadap field null — setiap field punya nilai default.
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // toJson — Konversi ke Map untuk serialisasi
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      if (description != null) 'description': description, // Sertakan jika tidak null
    };
  }

  // ---------------------------------------------------------------------------
  // Helper getter — memeriksa jenis role berdasarkan slug
  // ---------------------------------------------------------------------------

  /// True jika role ini adalah Pemohon (masyarakat)
  bool get isPemohon    => slug == 'pemohon';

  /// True jika role ini adalah Operator (staf administrasi)
  bool get isOperator   => slug == 'operator';

  /// True jika role ini adalah Petugas (teknisi lapangan)
  bool get isPetugas    => slug == 'petugas';

  /// True jika role ini adalah Verifikator (kepala bidang/dinas)
  bool get isVerifikator => slug == 'verifikator';

  /// True jika role ini adalah Admin IT
  bool get isAdmin      => slug == 'admin';

  // ---------------------------------------------------------------------------
  // Override standar Dart
  // ---------------------------------------------------------------------------

  @override
  String toString() => 'RoleModel(id: $id, name: $name, slug: $slug)';

  /// Dua role dianggap sama jika ID-nya sama
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
