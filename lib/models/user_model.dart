// ============================================================
// user_model.dart — Model Data User / Akun
// ============================================================
//
// Model ini merepresentasikan data user yang dikembalikan oleh
// backend Laravel Sanctum dari endpoint:
// - POST /api/auth/login → field 'data.user'
// - GET  /api/auth/me    → field 'data.user'
//
// Satu user bisa memiliki satu atau lebih role (melalui tabel pivot
// role_user di database). Contoh role: pemohon, operator, petugas,
// verifikator, admin.
// ============================================================

import 'role_model.dart';

/// Model User — sesuai response backend Laravel Sanctum.
///
/// Struktur JSON dari API:
/// ```json
/// {
///   "id": 1,
///   "name": "Budi Santoso",
///   "alamat": "Jl. Merdeka No. 10, Garut",
///   "phone": "081234567890",
///   "email": "budi@example.com",
///   "avatar": "avatars/budi.jpg",
///   "avatar_url": "http://127.0.0.1:8000/storage/avatars/budi.jpg",
///   "is_active": true,
///   "roles": [
///     { "id": 1, "name": "Pemohon", "slug": "pemohon" }
///   ]
/// }
/// ```
class UserModel {
  /// ID unik user di database (primary key)
  final int id;

  /// Nama lengkap user
  final String name;

  /// Alamat domisili user (nullable — mungkin belum diisi)
  final String? alamat;

  /// Nomor telepon/HP user (nullable)
  final String? phone;

  /// Alamat email (digunakan sebagai username login)
  final String email;

  /// Nama file avatar yang disimpan di storage backend (path relatif)
  final String? avatar;

  /// URL lengkap foto avatar yang bisa langsung digunakan di NetworkImage
  /// Contoh: 'http://127.0.0.1:8000/storage/avatars/budi.jpg'
  final String? avatarUrl;

  /// Status aktif/nonaktif akun (false = akun dinonaktifkan oleh admin)
  final bool isActive;

  /// Daftar role yang dimiliki user (bisa lebih dari satu, biasanya satu)
  final List<RoleModel> roles;

  const UserModel({
    required this.id,
    required this.name,
    this.alamat,
    this.phone,
    required this.email,
    this.avatar,
    this.avatarUrl,
    this.isActive = true,
    this.roles = const [],
  });

  // ---------------------------------------------------------------------------
  // fromJson — Parsing data dari response JSON API
  // ---------------------------------------------------------------------------

  /// Membuat instance [UserModel] dari Map JSON response API.
  ///
  /// Aman terhadap:
  /// - Field yang null (gunakan null-safe default)
  /// - Field 'roles' yang kosong atau null
  /// - Tipe data yang tidak konsisten dari API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse daftar role — jika kosong atau null, kembalikan list kosong
    List<RoleModel> rolesList = [];
    final rolesData = json['roles'];
    if (rolesData is List) {
      rolesList = rolesData
          .whereType<Map<String, dynamic>>() // Filter hanya Map yang valid
          .map((r) => RoleModel.fromJson(r))  // Konversi ke RoleModel
          .toList();
    }

    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      alamat: json['alamat'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      roles: rolesList,
    );
  }

  // ---------------------------------------------------------------------------
  // toJson — Konversi ke Map untuk dikirim ke API (jika perlu)
  // ---------------------------------------------------------------------------

  /// Konversi model ke Map JSON.
  /// Hanya menyertakan field yang tidak null (menggunakan collection if).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (alamat != null) 'alamat': alamat,
      if (phone != null) 'phone': phone,
      'email': email,
      'is_active': isActive,
      'roles': roles.map((r) => r.toJson()).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Helper: Role-based checks (pemeriksaan role pengguna)
  // ---------------------------------------------------------------------------

  /// Mengambil role pertama dari daftar roles.
  ///
  /// Umumnya satu user hanya punya satu role di sistem ini.
  /// Jika user tidak punya role, mengembalikan null.
  RoleModel? get primaryRole => roles.isNotEmpty ? roles.first : null;

  /// Slug (kode pendek) dari role pertama, digunakan untuk routing.
  /// Contoh: 'pemohon', 'operator', 'petugas', 'verifikator', 'admin'
  String? get primaryRoleSlug => primaryRole?.slug;

  /// Memeriksa apakah user memiliki role tertentu berdasarkan slug.
  bool hasRole(String slug) => roles.any((r) => r.slug == slug);

  // Shortcut getter untuk memeriksa role secara langsung
  bool get isPemohon    => hasRole('pemohon');     // Masyarakat pengaju permohonan
  bool get isOperator   => hasRole('operator');    // Staf administrasi PUPR
  bool get isPetugas    => hasRole('petugas');     // Teknisi lapangan PUPR
  bool get isVerifikator => hasRole('verifikator'); // Kepala bidang/dinas
  bool get isAdmin      => hasRole('admin');        // Admin IT sistem

  /// Nama role untuk ditampilkan di UI (Profil, Drawer, dll.)
  /// Contoh: "Pemohon", "Operator", "Petugas Tata Ruang"
  String get displayRole => primaryRole?.name ?? 'User';

  // ---------------------------------------------------------------------------
  // Override standar Dart
  // ---------------------------------------------------------------------------

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, roles: $roles)';

  /// Dua user dianggap sama jika memiliki ID yang sama
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ---------------------------------------------------------------------------
  // copyWith — Membuat salinan dengan beberapa field diubah
  // ---------------------------------------------------------------------------

  /// Membuat instance baru dengan beberapa field diubah.
  ///
  /// Digunakan saat update profil — tidak perlu membuat objek dari nol.
  ///
  /// Contoh:
  /// ```dart
  /// final updatedUser = currentUser.copyWith(name: 'Nama Baru');
  /// ```
  UserModel copyWith({
    int? id,
    String? name,
    String? alamat,
    String? phone,
    String? email,
    bool? isActive,
    List<RoleModel>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,           // Gunakan nilai baru jika ada, else nilai lama
      name: name ?? this.name,
      alamat: alamat ?? this.alamat,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
    );
  }
}
