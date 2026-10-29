import 'dart:typed_data';
import '../models/permohonan_dokumen_model.dart';
import '../services/dokumen_service.dart';

class DokumenRepository {
  final DokumenService _service;

  DokumenRepository({DokumenService? service})
      : _service = service ?? DokumenService();

  Future<List<PermohonanDokumenModel>> getDokumen(int permohonanId) {
    return _service.getDokumen(permohonanId);
  }

  Future<PermohonanDokumenModel> uploadDokumen({
    required int permohonanId,
    required String jenisDokumen,
    String? filePath,
    String? fileName,
    String? linkUrl,
    Uint8List? fileBytes,
  }) {
    return _service.uploadDokumen(
      permohonanId: permohonanId,
      jenisDokumen: jenisDokumen,
      filePath: filePath,
      fileName: fileName,
      linkUrl: linkUrl,
      fileBytes: fileBytes,
    );
  }

  Future<void> deleteDokumen({
    required int permohonanId,
    required int dokumenId,
  }) {
    return _service.deleteDokumen(
      permohonanId: permohonanId,
      dokumenId: dokumenId,
    );
  }
}
