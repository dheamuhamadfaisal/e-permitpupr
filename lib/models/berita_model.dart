class BeritaModel {
  final int id;
  final String judul;
  final String? ringkasan;
  final String konten;
  final String kategori; // 'informasi_terkini' atau 'berita'
  final String? gambar;
  final String? gambarUrl;
  final String? linkUrl;
  final String? penulisNama;
  final String createdAt;

  const BeritaModel({
    required this.id,
    required this.judul,
    this.ringkasan,
    required this.konten,
    required this.kategori,
    this.gambar,
    this.gambarUrl,
    this.linkUrl,
    this.penulisNama,
    required this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    String? penulis;
    if (json['penulis'] is Map<String, dynamic>) {
      penulis = json['penulis']['name'] as String?;
    }

    return BeritaModel(
      id: json['id'] as int? ?? 0,
      judul: json['judul'] as String? ?? '',
      ringkasan: json['ringkasan'] as String?,
      konten: json['konten'] as String? ?? '',
      kategori: json['kategori'] as String? ?? 'berita',
      gambar: json['gambar'] as String?,
      gambarUrl: json['gambar_url'] as String?,
      linkUrl: json['link_url'] as String?,
      penulisNama: penulis,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
