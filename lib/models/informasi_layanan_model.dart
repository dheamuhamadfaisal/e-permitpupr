class InformasiLayananModel {
  final int id;
  final String kode;
  final String nama;
  final String? deskripsi;
  final String? tentang;
  final List<String> alur;
  final List<String> persyaratan;

  InformasiLayananModel({
    required this.id,
    required this.kode,
    required this.nama,
    this.deskripsi,
    this.tentang,
    required this.alur,
    required this.persyaratan,
  });

  factory InformasiLayananModel.fromJson(Map<String, dynamic> json) {
    return InformasiLayananModel(
      id: json['id'],
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      tentang: json['tentang'],
      alur: (json['alur'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      persyaratan: (json['persyaratan'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
      'deskripsi': deskripsi,
      'tentang': tentang,
      'alur': alur,
      'persyaratan': persyaratan,
    };
  }
}
