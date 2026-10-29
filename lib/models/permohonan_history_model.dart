import 'user_model.dart';

/// Model Riwayat Status Permohonan (Audit Trail).
class PermohonanHistoryModel {
  final int id;
  final int permohonanId;
  final int userId;
  final String? statusLama;
  final String statusBaru;
  final String? catatan;
  final String createdAt;
  final UserModel? aktor;

  const PermohonanHistoryModel({
    required this.id,
    required this.permohonanId,
    required this.userId,
    this.statusLama,
    required this.statusBaru,
    this.catatan,
    required this.createdAt,
    this.aktor,
  });

  factory PermohonanHistoryModel.fromJson(Map<String, dynamic> json) {
    return PermohonanHistoryModel(
      id: json['id'] as int? ?? 0,
      permohonanId: json['permohonan_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      statusLama: json['status_lama'] as String?,
      statusBaru: json['status_baru'] as String? ?? '',
      catatan: json['catatan'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      aktor: json['aktor'] != null && json['aktor'] is Map<String, dynamic>
          ? UserModel.fromJson(json['aktor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permohonan_id': permohonanId,
      'user_id': userId,
      if (statusLama != null) 'status_lama': statusLama,
      'status_baru': statusBaru,
      if (catatan != null) 'catatan': catatan,
      'created_at': createdAt,
      if (aktor != null) 'aktor': aktor!.toJson(),
    };
  }
}
