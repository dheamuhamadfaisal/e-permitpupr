import 'permohonan_model.dart';

/// Dashboard Data untuk Pemohon
class DashboardPemohonModel {
  final int totalPermohonan;
  final int draft;
  final int sedangDiproses;
  final int perluRevisi;
  final int disetujui;
  final int ditolak;
  final List<PermohonanModel> permohonanTerbaru;

  const DashboardPemohonModel({
    required this.totalPermohonan,
    required this.draft,
    required this.sedangDiproses,
    required this.perluRevisi,
    required this.disetujui,
    required this.ditolak,
    this.permohonanTerbaru = const [],
  });

  factory DashboardPemohonModel.fromJson(Map<String, dynamic> json) {
    List<PermohonanModel> terbaru = [];
    if (json['permohonan_terbaru'] is List) {
      terbaru = (json['permohonan_terbaru'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => PermohonanModel.fromJson(p))
          .toList();
    }

    return DashboardPemohonModel(
      totalPermohonan: json['total_permohonan'] as int? ?? 0,
      draft: json['draft'] as int? ?? 0,
      sedangDiproses: json['sedang_diproses'] as int? ?? 0,
      perluRevisi: json['perlu_revisi'] as int? ?? 0,
      disetujui: json['disetujui'] as int? ?? 0,
      ditolak: json['ditolak'] as int? ?? 0,
      permohonanTerbaru: terbaru,
    );
  }
}

/// Dashboard Data untuk Operator Bagian Umum (CMS)
class DashboardOperatorModel {
  final int totalBerita;
  final int infoLayanan;
  final int bannerAktif;
  final int profilDinas;

  const DashboardOperatorModel({
    required this.totalBerita,
    required this.infoLayanan,
    required this.bannerAktif,
    required this.profilDinas,
  });

  factory DashboardOperatorModel.fromJson(Map<String, dynamic> json) {
    return DashboardOperatorModel(
      totalBerita: json['total_berita'] as int? ?? 0,
      infoLayanan: json['info_layanan'] as int? ?? 0,
      bannerAktif: json['banner_aktif'] as int? ?? 0,
      profilDinas: json['profil_dinas'] as int? ?? 0,
    );
  }
}

/// Dashboard Data untuk Petugas Tata Ruang
class DashboardPetugasModel {
  final int totalPermohonan;
  final int diajukan;
  final int perluKunjunganLapangan;
  final int dalamAnalisis;
  final int siapTerbit;
  final int terbit;
  final int perluRevisi;
  final int ditolakPermanen;
  final int krkCount;
  final int siteplanCount;
  final List<PermohonanModel> permohonanTerbaru;

  const DashboardPetugasModel({
    required this.totalPermohonan,
    required this.diajukan,
    required this.perluKunjunganLapangan,
    required this.dalamAnalisis,
    required this.siapTerbit,
    required this.terbit,
    required this.perluRevisi,
    required this.ditolakPermanen,
    required this.krkCount,
    required this.siteplanCount,
    this.permohonanTerbaru = const [],
  });

  factory DashboardPetugasModel.fromJson(Map<String, dynamic> json) {
    List<PermohonanModel> terbaru = [];
    if (json['permohonan_terbaru'] is List) {
      terbaru = (json['permohonan_terbaru'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => PermohonanModel.fromJson(p))
          .toList();
    }

    return DashboardPetugasModel(
      totalPermohonan: json['total_permohonan'] as int? ?? 0,
      diajukan: json['diajukan'] as int? ?? 0,
      perluKunjunganLapangan: json['perlu_kunjungan_lapangan'] as int? ?? json['survey'] as int? ?? 0,
      dalamAnalisis: json['dalam_analisis'] as int? ?? json['rekomendasi'] as int? ?? 0,
      siapTerbit: json['siap_terbit'] as int? ?? 0,
      terbit: json['terbit'] as int? ?? json['selesai_teknis'] as int? ?? 0,
      perluRevisi: json['perlu_revisi'] as int? ?? 0,
      ditolakPermanen: json['ditolak_permanen'] as int? ?? 0,
      krkCount: json['krk_count'] as int? ?? 0,
      siteplanCount: json['siteplan_count'] as int? ?? 0,
      permohonanTerbaru: terbaru,
    );
  }
}

/// Dashboard Data untuk Verifikator (Kabid / Kadis)
class DashboardVerifikatorModel {
  final int menungguVerifikasi;
  final int disetujui;
  final int ditolak;
  final int perluRevisi;
  final List<PermohonanModel> permohonanTerbaru;

  const DashboardVerifikatorModel({
    required this.menungguVerifikasi,
    required this.disetujui,
    required this.ditolak,
    required this.perluRevisi,
    this.permohonanTerbaru = const [],
  });

  factory DashboardVerifikatorModel.fromJson(Map<String, dynamic> json) {
    List<PermohonanModel> terbaru = [];
    if (json['permohonan_terbaru'] is List) {
      terbaru = (json['permohonan_terbaru'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => PermohonanModel.fromJson(p))
          .toList();
    }

    return DashboardVerifikatorModel(
      menungguVerifikasi: json['menunggu_verifikasi'] as int? ?? 0,
      disetujui: json['disetujui'] as int? ?? 0,
      ditolak: json['ditolak'] as int? ?? 0,
      perluRevisi: json['perlu_revisi'] as int? ?? 0,
      permohonanTerbaru: terbaru,
    );
  }
}

/// Dashboard Data untuk Admin IT
class DashboardAdminModel {
  final int totalUser;
  final int totalPemohon;
  final int totalOperator;
  final int totalPetugas;
  final int totalVerifikator;
  final int totalPermohonan;
  final Map<String, int> statistikStatus;
  final List<Map<String, dynamic>> statistikJenis;

  const DashboardAdminModel({
    required this.totalUser,
    required this.totalPemohon,
    required this.totalOperator,
    required this.totalPetugas,
    required this.totalVerifikator,
    required this.totalPermohonan,
    this.statistikStatus = const {},
    this.statistikJenis = const [],
  });

  factory DashboardAdminModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> statusMap = {};
    if (json['statistik_status'] is Map) {
      (json['statistik_status'] as Map).forEach((key, val) {
        statusMap[key.toString()] = (val as int? ?? 0);
      });
    }

    List<Map<String, dynamic>> jenisList = [];
    if (json['statistik_jenis'] is List) {
      jenisList = (json['statistik_jenis'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return DashboardAdminModel(
      totalUser: json['total_user'] as int? ?? 0,
      totalPemohon: json['total_pemohon'] as int? ?? 0,
      totalOperator: json['total_operator'] as int? ?? 0,
      totalPetugas: json['total_petugas'] as int? ?? 0,
      totalVerifikator: json['total_verifikator'] as int? ?? 0,
      totalPermohonan: json['total_permohonan'] as int? ?? 0,
      statistikStatus: statusMap,
      statistikJenis: jenisList,
    );
  }
}
