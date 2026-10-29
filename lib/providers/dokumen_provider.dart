import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_dokumen_model.dart';
import '../repositories/dokumen_repository.dart';

class DokumenProvider extends ChangeNotifier {
  final DokumenRepository _repository;

  DokumenProvider({DokumenRepository? repository})
      : _repository = repository ?? DokumenRepository();

  List<PermohonanDokumenModel> _items = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;

  List<PermohonanDokumenModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;

  Future<void> fetchDokumen(int permohonanId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getDokumen(permohonanId);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Dokumen';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDokumen({
    required int permohonanId,
    required String jenisDokumen,
    String? filePath,
    String? fileName,
    String? linkUrl,
    Uint8List? fileBytes,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final newDoc = await _repository.uploadDokumen(
        permohonanId: permohonanId,
        jenisDokumen: jenisDokumen,
        filePath: filePath,
        fileName: fileName,
        linkUrl: linkUrl,
        fileBytes: fileBytes,
      );
      _items.insert(0, newDoc);
      _isUploading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isUploading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Mengupload Dokumen';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDokumen({
    required int permohonanId,
    required int dokumenId,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteDokumen(
        permohonanId: permohonanId,
        dokumenId: dokumenId,
      );
      _items.removeWhere((d) => d.id == dokumenId);
      _isUploading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isUploading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menghapus Dokumen';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}
