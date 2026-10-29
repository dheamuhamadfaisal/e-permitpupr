class ProfilDinasModel {
  final int id;
  final String namaDinas;
  final String subNama;
  final String visi;
  final List<String> misi;
  final String alamat;
  final String telepon;
  final String email;
  final String? foto;
  final String? fotoUrl;

  const ProfilDinasModel({
    required this.id,
    required this.namaDinas,
    required this.subNama,
    required this.visi,
    required this.misi,
    required this.alamat,
    required this.telepon,
    required this.email,
    this.foto,
    this.fotoUrl,
  });

  factory ProfilDinasModel.fromJson(Map<String, dynamic> json) {
    List<String> listMisi = [];
    if (json['misi'] is List) {
      listMisi = (json['misi'] as List).map((m) => m.toString()).toList();
    }

    return ProfilDinasModel(
      id: json['id'] as int? ?? 1,
      namaDinas: json['nama_dinas'] as String? ?? 'Dinas PUPR Kabupaten Garut',
      subNama: json['sub_nama'] as String? ?? 'Dinas Pekerjaan Umum dan Penataan Ruang',
      visi: json['visi'] as String? ?? '',
      misi: listMisi,
      alamat: json['alamat'] as String? ?? '',
      telepon: json['telepon'] as String? ?? '',
      email: json['email'] as String? ?? '',
      foto: json['foto'] as String?,
      fotoUrl: json['foto_url'] as String?,
    );
  }
}
