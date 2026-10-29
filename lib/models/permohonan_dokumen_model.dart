/// Model PermohonanDokumen — sesuai response API Backend Laravel.
class PermohonanDokumenModel {
  final int id;
  final int permohonanId;
  final String jenisDokumen;
  final String namaFile;
  final String path;
  final String mimeType;
  final int ukuran;
  final String statusVerifikasi;
  final String? catatan;
  final String? url;
  final String createdAt;
  final String updatedAt;

  const PermohonanDokumenModel({
    required this.id,
    required this.permohonanId,
    required this.jenisDokumen,
    required this.namaFile,
    required this.path,
    required this.mimeType,
    required this.ukuran,
    required this.statusVerifikasi,
    this.catatan,
    this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  String get filePath => url ?? path;

  static const String statusPending = 'pending';
  static const String statusDiterima = 'diterima';
  static const String statusDitolak = 'ditolak';

  factory PermohonanDokumenModel.fromJson(Map<String, dynamic> json) {
    return PermohonanDokumenModel(
      id: json['id'] as int? ?? 0,
      permohonanId: json['permohonan_id'] as int? ?? 0,
      jenisDokumen: json['jenis_dokumen'] as String? ?? '',
      namaFile: json['nama_file'] as String? ?? '',
      path: json['path'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? '',
      ukuran: json['ukuran'] as int? ?? 0,
      statusVerifikasi: json['status_verifikasi'] as String? ?? statusPending,
      catatan: json['catatan'] as String?,
      url: json['url'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permohonan_id': permohonanId,
      'jenis_dokumen': jenisDokumen,
      'nama_file': namaFile,
      'path': path,
      'mime_type': mimeType,
      'ukuran': ukuran,
      'status_verifikasi': statusVerifikasi,
      if (catatan != null) 'catatan': catatan,
      if (url != null) 'url': url,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get ukuranReadable {
    if (ukuran >= 1048576) {
      return '${(ukuran / 1048576).toStringAsFixed(2)} MB';
    }
    if (ukuran >= 1024) {
      return '${(ukuran / 1024).toStringAsFixed(2)} KB';
    }
    return '$ukuran B';
  }

  bool get isPdf => mimeType.contains('pdf') || namaFile.toLowerCase().endsWith('.pdf');
  bool get isImage =>
      mimeType.contains('image') ||
      namaFile.toLowerCase().endsWith('.jpg') ||
      namaFile.toLowerCase().endsWith('.jpeg') ||
      namaFile.toLowerCase().endsWith('.png');
  bool get isUrl => mimeType == 'url' || namaFile == 'Link Google Drive';
  bool get isArchive => namaFile.toLowerCase().endsWith('.zip') || namaFile.toLowerCase().endsWith('.rar');
  bool get isMapFile =>
      namaFile.toLowerCase().endsWith('.kml') ||
      namaFile.toLowerCase().endsWith('.kmz') ||
      namaFile.toLowerCase().endsWith('.shp') ||
      namaFile.toLowerCase().endsWith('.dwg') ||
      namaFile.toLowerCase().endsWith('.dxf');
}
