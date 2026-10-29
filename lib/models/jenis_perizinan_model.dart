/// Model JenisPerizinan — sesuai response backend API.
///
/// Response:
/// ```json
/// {
///   "id": 1,
///   "kode": "KRK",
///   "nama": "Keterangan Rencana Kota",
///   "deskripsi": "...",
///   "persyaratan": ["KTP", "Sertifikat Tanah"],
///   "estimasi_waktu": 14,
///   "status": "aktif"
/// }
/// ```
class PersyaratanModel {
  final String nama;
  final bool isOpsional;
  final int maxSizeMb;
  final String? linkUrl;
  final String? allowedTypes;
  final bool allowLink;

  const PersyaratanModel({
    required this.nama,
    this.isOpsional = false,
    this.maxSizeMb = 5,
    this.linkUrl,
    this.allowedTypes,
    this.allowLink = false,
  });

  factory PersyaratanModel.fromJson(Map<String, dynamic> json) {
    bool parsedIsOpsional = false;
    if (json['is_opsional'] != null) {
      if (json['is_opsional'] is bool) {
        parsedIsOpsional = json['is_opsional'];
      } else if (json['is_opsional'] is String) {
        parsedIsOpsional = json['is_opsional'] == '1' || json['is_opsional'].toString().toLowerCase() == 'true';
      } else if (json['is_opsional'] is int) {
        parsedIsOpsional = json['is_opsional'] == 1;
      }
    }

    int parsedMaxSize = 5;
    if (json['max_size_mb'] != null) {
      if (json['max_size_mb'] is int) {
        parsedMaxSize = json['max_size_mb'];
      } else if (json['max_size_mb'] is String) {
        parsedMaxSize = int.tryParse(json['max_size_mb']) ?? 5;
      }
    }

    return PersyaratanModel(
      nama: json['nama']?.toString() ?? '',
      isOpsional: parsedIsOpsional,
      maxSizeMb: parsedMaxSize,
      linkUrl: json['link_url']?.toString(),
      allowedTypes: json['allowed_types']?.toString(),
      allowLink: json['allow_link'] == true || json['allow_link'] == 1 || json['allow_link'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'is_opsional': isOpsional,
      'max_size_mb': maxSizeMb,
      if (linkUrl != null) 'link_url': linkUrl,
      if (allowedTypes != null) 'allowed_types': allowedTypes,
      'allow_link': allowLink ? 1 : 0,
    };
  }
}

class JenisPerizinanModel {
  final int id;
  final String kode;
  final String nama;
  final String? deskripsi;
  final String? tentang;
  final List<PersyaratanModel> persyaratan;
  final List<String> alur;
  final int estimasiWaktu;
  final int maxFileSizeMb;
  final String status;
  final String? logoUrl;

  const JenisPerizinanModel({
    required this.id,
    required this.kode,
    required this.nama,
    this.deskripsi,
    this.tentang,
    this.persyaratan = const [],
    this.alur = const [],
    this.estimasiWaktu = 14,
    this.maxFileSizeMb = 5,
    this.status = 'aktif',
    this.logoUrl,
  });

  factory JenisPerizinanModel.fromJson(Map<String, dynamic> json) {
    List<PersyaratanModel> listPersyaratan = [];
    if (json['persyaratan'] is List) {
      listPersyaratan = (json['persyaratan'] as List).map((e) {
        if (e is Map<String, dynamic>) {
          return PersyaratanModel.fromJson(e);
        } else if (e is String) {
          // Fallback for old data if any
          bool isOpsional = e.toLowerCase().contains('opsional');
          String namaClean = e.replaceAll(RegExp(r'\s*\(?opsional\)?', caseSensitive: false), '').trim();
          return PersyaratanModel(
            nama: namaClean,
            isOpsional: isOpsional,
            maxSizeMb: json['max_file_size_mb'] as int? ?? 5,
          );
        }
        return const PersyaratanModel(nama: '');
      }).where((p) => p.nama.isNotEmpty).toList();
    }

    List<String> listAlur = [];
    if (json['alur'] is List) {
      listAlur = (json['alur'] as List).map((e) => e.toString()).toList();
    }

    return JenisPerizinanModel(
      id: json['id'] as int? ?? 0,
      kode: json['kode'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      deskripsi: json['deskripsi'] as String?,
      tentang: json['tentang'] as String?,
      persyaratan: listPersyaratan,
      alur: listAlur,
      estimasiWaktu: json['estimasi_waktu'] as int? ?? 14,
      maxFileSizeMb: json['max_file_size_mb'] as int? ?? 5,
      status: json['status'] as String? ?? 'aktif',
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
      'deskripsi': deskripsi,
      'tentang': tentang,
      'persyaratan': persyaratan.map((e) => e.toJson()).toList(),
      'alur': alur,
      'estimasi_waktu': estimasiWaktu,
      'max_file_size_mb': maxFileSizeMb,
      'status': status,
      'logo_url': logoUrl,
    };
  }

  bool get isKRK => kode.toUpperCase() == 'KRK';
  bool get isSitePlan => kode.toUpperCase() == 'SITEPLAN';
}
