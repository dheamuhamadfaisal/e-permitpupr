// ============================================================
// permohonan_model.dart — Model Data Permohonan Perizinan
// ============================================================
//
// Model ini adalah model UTAMA dan paling kompleks di aplikasi.
// Merepresentasikan satu permohonan perizinan dari seorang pemohon,
// beserta semua data terkait (jenis perizinan, pelaksana, dokumen,
// riwayat status).
//
// Alur status permohonan (SOP Bidang Tata Ruang PUPR Garut):
//
//   [Pemohon] Buat Draft
//        ↓
//   [Pemohon] Submit → status: 'diajukan'
//        ↓
//   [Operator] Validasi kelengkapan → status: 'dalam_validasi_kelengkapan'
//        ↓ (Jika lengkap)
//   [Petugas] Kunjungan lapangan → status: 'perlu_kunjungan_lapangan'
//        ↓
//   [Petugas] Analisis & Rekomendasi → status: 'dalam_analisis'
//        ↓
//   [Verifikator] Keputusan akhir
//        ↓ SETUJU             ↓ TOLAK
//   status: 'siap_terbit'   status: 'ditolak_permanen'
//        ↓
//   [Operator] Terbitkan surat → status: 'terbit'
//
//   ⚠️ Jika perlu revisi: status: 'perlu_revisi'
//      Pemohon bisa revisi maksimal 3 kali (percobaan_revisi ≤ 3)
// ============================================================

import 'package:flutter/material.dart';
import 'jenis_perizinan_model.dart';
import 'permohonan_dokumen_model.dart';
import 'permohonan_history_model.dart';
import 'user_model.dart';

/// Model Permohonan — persis sesuai response API Backend Laravel.
///
/// Digunakan di seluruh alur perizinan:
/// - Pemohon: membuat, mengedit, mengajukan, melihat status
/// - Operator: memvalidasi administrasi, menerbitkan surat
/// - Petugas: survey lapangan, analisis teknis, rekomendasi
/// - Verifikator: keputusan akhir (setujui/tolak)
/// - Admin: monitoring semua permohonan
class PermohonanModel {
  /// ID permohonan di database
  final int id;

  /// Nomor unik permohonan (format: PM-YYYY-XXXXX)
  /// Contoh: PM-2026-00001
  final String nomorPermohonan;

  /// ID user pemohon (foreign key ke tabel users)
  final int userId;

  /// ID operator yang ditugaskan (nullable — belum ditugaskan jika null)
  final int? operatorId;

  /// ID petugas yang ditugaskan untuk survey lapangan (nullable)
  final int? petugasId;

  /// ID verifikator yang ditugaskan untuk keputusan akhir (nullable)
  final int? verifikatorId;

  /// ID jenis perizinan yang dipilih (KRK, Siteplan, PBG, dll.)
  final int jenisPerizinanId;

  /// ID permohonan KRK yang sudah terbit — WAJIB untuk pengajuan Siteplan
  /// (nullable — hanya ada untuk permohonan bertipe Siteplan)
  final int? krkTerkaitId;

  /// Tanggal permohonan resmi diajukan (null jika masih draft)
  final String? tanggalPengajuan;

  /// Tanggal keputusan akhir diambil (null jika belum ada keputusan)
  final String? tanggalKeputusan;

  /// Status permohonan saat ini (lihat konstanta STATUS_* di bawah)
  final String status;

  /// Jumlah percobaan revisi yang sudah dilakukan pemohon (maks. 3)
  final int percobaanRevisi;

  /// Batas waktu revisi — pemohon harus submit ulang sebelum tanggal ini
  final String? batasWaktuRevisi;

  /// Catatan penolakan dari verifikator (alasan permohonan ditolak)
  final String? catatanPenolakan;

  /// Daftar nama field yang perlu diperbaiki saat revisi
  /// Contoh: ["nama_perusahaan", "alamat_lengkap"]
  final List<String> fieldBermasalah;

  /// Nama file surat perizinan yang diterbitkan (path relatif di storage)
  final String? fileSuratTerbit;

  /// URL lengkap untuk mengunduh surat perizinan
  final String? fileSuratTerbitUrl;

  // --- Data identitas pemohon / perusahaan ---
  final String? namaPerusahaan;    // Nama perusahaan/instansi (jika ada)
  final String? namaDirektur;      // Nama direktur/penanggung jawab
  final String? noHpPenanggungJawab; // No. HP yang bisa dihubungi
  final String? rencanaKegiatan;   // Deskripsi rencana kegiatan/pembangunan
  final String? alamatLengkap;     // Alamat lokasi yang dimohonkan
  final String? luasArea;          // Luas area dalam satuan meter persegi
  final String? keterangan;        // Keterangan tambahan dari pemohon

  // --- Catatan dari petugas lapangan ---
  final String? catatanOperator;   // Catatan hasil validasi administrasi
  final String? catatanTeknis;     // Catatan teknis dari petugas lapangan
  final String? hasilSurvey;       // Hasil pengamatan survey lapangan
  final String? fileHasilSurvey;   // File laporan survey (path relatif)
  final String? fileHasilSurveyUrl; // URL download laporan survey
  final String? rekomendasiPetugas; // Rekomendasi petugas (setuju/tidak)
  final String? catatanVerifikator; // Catatan keputusan verifikator

  final String createdAt; // Waktu permohonan dibuat di sistem
  final String updatedAt; // Waktu terakhir data permohonan diubah

  // --- Relasi (data join dari tabel lain) ---
  final JenisPerizinanModel? jenisPerizinan; // Detail jenis perizinan
  final PermohonanModel? krkTerkait;         // Data KRK yang terkait (untuk Siteplan)
  final UserModel? pemohon;                  // Data user pemohon
  final UserModel? operator;                 // Data user operator
  final UserModel? petugas;                  // Data user petugas
  final UserModel? verifikator;              // Data user verifikator
  final List<PermohonanHistoryModel> histories; // Audit trail / riwayat status
  final List<PermohonanDokumenModel> dokumen;   // Daftar dokumen yang diupload

  const PermohonanModel({
    required this.id,
    required this.nomorPermohonan,
    required this.userId,
    this.operatorId,
    this.petugasId,
    this.verifikatorId,
    required this.jenisPerizinanId,
    this.krkTerkaitId,
    this.tanggalPengajuan,
    this.tanggalKeputusan,
    required this.status,
    this.percobaanRevisi = 0,
    this.batasWaktuRevisi,
    this.catatanPenolakan,
    this.fieldBermasalah = const [],
    this.fileSuratTerbit,
    this.fileSuratTerbitUrl,
    this.namaPerusahaan,
    this.namaDirektur,
    this.noHpPenanggungJawab,
    this.rencanaKegiatan,
    this.alamatLengkap,
    this.luasArea,
    this.keterangan,
    this.catatanOperator,
    this.catatanTeknis,
    this.hasilSurvey,
    this.fileHasilSurvey,
    this.fileHasilSurveyUrl,
    this.rekomendasiPetugas,
    this.catatanVerifikator,
    required this.createdAt,
    required this.updatedAt,
    this.jenisPerizinan,
    this.krkTerkait,
    this.pemohon,
    this.operator,
    this.petugas,
    this.verifikator,
    this.histories = const [],
    this.dokumen = const [],
  });

  // ---------------------------------------------------------------------------
  // Konstanta Status Permohonan (SOP Baru Bidang Tata Ruang PUPR Garut)
  // Perubahan status ini dicatat di tabel permohonan_histories (audit trail)
  // ---------------------------------------------------------------------------

  /// Permohonan baru dibuat, belum diajukan secara resmi
  static const String statusDraft = 'draft';

  /// Permohonan sudah disubmit oleh pemohon, menunggu tindakan operator
  static const String statusDiajukan = 'diajukan';

  /// Operator sedang memvalidasi kelengkapan dokumen administrasi
  static const String statusDalamValidasiKelengkapan = 'dalam_validasi_kelengkapan';

  /// Petugas perlu melakukan kunjungan/survey ke lokasi
  static const String statusPerluKunjunganLapangan = 'perlu_kunjungan_lapangan';

  /// Petugas sedang melakukan analisis dan membuat rekomendasi
  static const String statusDalamAnalisis = 'dalam_analisis';

  /// Verifikator sudah setuju, surat siap diterbitkan oleh operator
  static const String statusSiapTerbit = 'siap_terbit';

  /// Surat perizinan sudah diterbitkan dan bisa diunduh
  static const String statusTerbit = 'terbit';

  /// Permohonan dikembalikan ke pemohon untuk diperbaiki
  static const String statusPerluRevisi = 'perlu_revisi';

  /// Permohonan ditolak secara permanen (tidak bisa revisi lagi)
  static const String statusDitolakPermanen = 'ditolak_permanen';

  // ---------------------------------------------------------------------------
  // fromJson — Parsing dari response JSON API
  // ---------------------------------------------------------------------------

  /// Membuat instance [PermohonanModel] dari response JSON API.
  ///
  /// Menangani parsing untuk semua relasi (nested objects):
  /// - jenisPerizinan, krkTerkait, pemohon, operator, petugas, verifikator
  /// - histories (list audit trail)
  /// - dokumen (list file yang diupload)
  /// - fieldBermasalah (bisa berupa List atau String)
  factory PermohonanModel.fromJson(Map<String, dynamic> json) {
    // Parse daftar riwayat status (audit trail)
    List<PermohonanHistoryModel> listHistories = [];
    if (json['histories'] is List) {
      listHistories = (json['histories'] as List)
          .whereType<Map<String, dynamic>>()
          .map((h) => PermohonanHistoryModel.fromJson(h))
          .toList();
    }

    // Parse daftar dokumen yang diupload
    List<PermohonanDokumenModel> listDokumen = [];
    if (json['dokumen'] is List) {
      listDokumen = (json['dokumen'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => PermohonanDokumenModel.fromJson(d))
          .toList();
    }

    // Parse daftar field bermasalah (bisa berupa List atau String tunggal)
    List<String> listFieldBermasalah = [];
    if (json['field_bermasalah'] is List) {
      listFieldBermasalah = (json['field_bermasalah'] as List)
          .map((f) => f.toString())
          .toList();
    } else if (json['field_bermasalah'] is String) {
      // Jika string tunggal, bungkus dalam list
      listFieldBermasalah = [json['field_bermasalah'].toString()];
    }

    return PermohonanModel(
      id: json['id'] as int? ?? 0,
      nomorPermohonan: json['nomor_permohonan'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      operatorId: json['operator_id'] as int?,
      petugasId: json['petugas_id'] as int?,
      verifikatorId: json['verifikator_id'] as int?,
      jenisPerizinanId: json['jenis_perizinan_id'] as int? ?? 0,
      krkTerkaitId: json['krk_terkait_id'] as int?,
      tanggalPengajuan: json['tanggal_pengajuan'] as String?,
      tanggalKeputusan: json['tanggal_keputusan'] as String?,
      status: json['status'] as String? ?? statusDraft,
      percobaanRevisi: json['percobaan_revisi'] as int? ?? 0,
      batasWaktuRevisi: json['batas_waktu_revisi'] as String?,
      catatanPenolakan: json['catatan_penolakan'] as String?,
      fieldBermasalah: listFieldBermasalah,
      fileSuratTerbit: json['file_surat_terbit'] as String?,
      fileSuratTerbitUrl: json['file_surat_terbit_url'] as String?,
      namaPerusahaan: json['nama_perusahaan'] as String?,
      namaDirektur: json['nama_direktur'] as String?,
      noHpPenanggungJawab: json['no_hp_penanggung_jawab'] as String?,
      rencanaKegiatan: json['rencana_kegiatan'] as String?,
      alamatLengkap: json['alamat_lengkap'] as String?,
      luasArea: json['luas_area'] as String?,
      keterangan: json['keterangan'] as String?,
      catatanOperator: json['catatan_operator'] as String?,
      catatanTeknis: json['catatan_teknis'] as String?,
      hasilSurvey: json['hasil_survey'] as String?,
      fileHasilSurvey: json['file_hasil_survey'] as String?,
      fileHasilSurveyUrl: json['file_hasil_survey_url'] as String?,
      rekomendasiPetugas: json['rekomendasi_petugas'] as String?,
      catatanVerifikator: json['catatan_verifikator'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      // Parse relasi jika ada dan bertipe Map yang valid
      jenisPerizinan: json['jenis_perizinan'] != null && json['jenis_perizinan'] is Map<String, dynamic>
          ? JenisPerizinanModel.fromJson(json['jenis_perizinan'] as Map<String, dynamic>)
          : null,
      krkTerkait: json['krk_terkait'] != null && json['krk_terkait'] is Map<String, dynamic>
          ? PermohonanModel.fromJson(json['krk_terkait'] as Map<String, dynamic>)
          : null,
      pemohon: json['pemohon'] != null && json['pemohon'] is Map<String, dynamic>
          ? UserModel.fromJson(json['pemohon'] as Map<String, dynamic>)
          : null,
      operator: json['operator'] != null && json['operator'] is Map<String, dynamic>
          ? UserModel.fromJson(json['operator'] as Map<String, dynamic>)
          : null,
      petugas: json['petugas'] != null && json['petugas'] is Map<String, dynamic>
          ? UserModel.fromJson(json['petugas'] as Map<String, dynamic>)
          : null,
      verifikator: json['verifikator'] != null && json['verifikator'] is Map<String, dynamic>
          ? UserModel.fromJson(json['verifikator'] as Map<String, dynamic>)
          : null,
      histories: listHistories,
      dokumen: listDokumen,
    );
  }

  // ---------------------------------------------------------------------------
  // toJson — Serialisasi ke Map
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_permohonan': nomorPermohonan,
      'user_id': userId,
      if (operatorId != null) 'operator_id': operatorId,
      if (petugasId != null) 'petugas_id': petugasId,
      if (verifikatorId != null) 'verifikator_id': verifikatorId,
      'jenis_perizinan_id': jenisPerizinanId,
      if (krkTerkaitId != null) 'krk_terkait_id': krkTerkaitId,
      if (tanggalPengajuan != null) 'tanggal_pengajuan': tanggalPengajuan,
      if (tanggalKeputusan != null) 'tanggal_keputusan': tanggalKeputusan,
      'status': status,
      'percobaan_revisi': percobaanRevisi,
      if (batasWaktuRevisi != null) 'batas_waktu_revisi': batasWaktuRevisi,
      if (catatanPenolakan != null) 'catatan_penolakan': catatanPenolakan,
      'field_bermasalah': fieldBermasalah,
      if (namaPerusahaan != null) 'nama_perusahaan': namaPerusahaan,
      if (namaDirektur != null) 'nama_direktur': namaDirektur,
      if (noHpPenanggungJawab != null) 'no_hp_penanggung_jawab': noHpPenanggungJawab,
      if (rencanaKegiatan != null) 'rencana_kegiatan': rencanaKegiatan,
      if (alamatLengkap != null) 'alamat_lengkap': alamatLengkap,
      if (luasArea != null) 'luas_area': luasArea,
      if (keterangan != null) 'keterangan': keterangan,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // ---------------------------------------------------------------------------
  // Helper getters — Pengecekan status yang sering digunakan
  // ---------------------------------------------------------------------------

  /// True jika permohonan sudah terbit (surat perizinan sudah keluar).
  /// Termasuk alias dari status lama: 'disetujui', 'selesai'
  bool get isTerbit => status == statusTerbit || status == 'disetujui' || status == 'selesai';

  /// True jika permohonan memerlukan revisi dari pemohon.
  /// Termasuk alias dari status lama: 'tidak_lengkap', 'revisi'
  bool get isPerluRevisi => status == statusPerluRevisi || status == 'tidak_lengkap' || status == 'revisi';

  /// True jika permohonan ditolak secara permanen (tidak bisa revisi/ajukan ulang)
  bool get isDitolakPermanen => status == statusDitolakPermanen || status == 'ditolak';

  /// True jika batas waktu revisi sudah terlewati.
  /// Menghitung dari [batasWaktuRevisi] dibandingkan dengan waktu sekarang.
  bool get isRevisiExpired {
    if (batasWaktuRevisi == null) return false;
    final deadline = DateTime.tryParse(batasWaktuRevisi!);
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline); // Sudah melewati deadline
  }

  /// True jika pemohon masih bisa mengedit permohonan ini.
  /// Syarat: status draft ATAU (perlu revisi DAN belum expired)
  bool get isEditableByPemohon => status == statusDraft || (isPerluRevisi && !isRevisiExpired);

  /// True jika pemohon bisa mengajukan (submit) permohonan ini.
  /// Sama dengan isEditableByPemohon — harus bisa edit dulu sebelum submit
  bool get isSubmittable => status == statusDraft || (isPerluRevisi && !isRevisiExpired);

  // ---------------------------------------------------------------------------
  // statusLabel — Label teks untuk ditampilkan di UI
  // ---------------------------------------------------------------------------

  /// Menghasilkan teks label yang ramah pengguna dari nilai [status].
  ///
  /// Menangani semua status termasuk alias dari sistem lama.
  String get statusLabel {
    switch (status) {
      case statusDraft:
        return 'Draft';
      case statusDiajukan:
        return 'Diajukan';
      case statusDalamValidasiKelengkapan:
      case 'pemeriksaan_administrasi': // Alias status lama
      case 'pemeriksaan_teknis':       // Alias status lama
        return 'Dalam Validasi Kelengkapan';
      case statusPerluKunjunganLapangan:
      case 'survey':                   // Alias status lama
        return 'Kunjungan Lapangan';
      case statusDalamAnalisis:
      case 'rekomendasi':              // Alias status lama
      case 'menunggu_verifikasi':      // Alias status lama
        return 'Dalam Analisis';
      case statusPerluRevisi:
      case 'tidak_lengkap':            // Alias status lama
      case 'revisi':                   // Alias status lama
        return 'Perlu Revisi';
      case statusTerbit:
      case 'disetujui':                // Alias status lama
      case 'selesai':                  // Alias status lama
        return 'Surat Terbit';
      case statusDitolakPermanen:
      case 'ditolak':                  // Alias status lama
        return 'Ditolak Permanen';
      default:
        // Fallback: ubah underscore jadi spasi dan huruf kapital semua
        return status.toUpperCase().replaceAll('_', ' ');
    }
  }

  // ---------------------------------------------------------------------------
  // statusColor — Warna badge status untuk ditampilkan di UI
  // ---------------------------------------------------------------------------

  /// Menghasilkan warna yang sesuai dengan status permohonan.
  ///
  /// Konvensi warna:
  /// - Abu-abu    : Draft (belum diajukan)
  /// - Biru       : Sedang diproses
  /// - Oranye     : Perlu tindakan dari pemohon (revisi)
  /// - Hijau      : Selesai/Terbit (sukses)
  /// - Merah      : Ditolak (gagal)
  Color get statusColor {
    switch (status) {
      case statusDraft:
        return const Color(0xFF64748B); // Abu-abu — belum aktif

      case statusDiajukan:
      case statusDalamValidasiKelengkapan:
      case statusPerluKunjunganLapangan:
      case statusDalamAnalisis:
        return const Color(0xFF0284C7); // Biru — sedang diproses

      case statusPerluRevisi:
        return const Color(0xFFEA580C); // Oranye — butuh perhatian pemohon

      case statusTerbit:
        return const Color(0xFF16A34A); // Hijau — berhasil

      case statusDitolakPermanen:
        return const Color(0xFFDC2626); // Merah — ditolak

      default:
        return const Color(0xFF64748B); // Default: abu-abu
    }
  }
}
