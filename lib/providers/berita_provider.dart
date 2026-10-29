import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/berita_model.dart';
import '../repositories/berita_repository.dart';

class BeritaProvider extends ChangeNotifier {
  final BeritaRepository _repository;

  BeritaProvider({BeritaRepository? repository})
      : _repository = repository ?? BeritaRepository();

  List<BeritaModel> _sliderItems = [];
  List<BeritaModel> _newsItems = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  List<BeritaModel> get sliderItems => _sliderItems;
  List<BeritaModel> get newsItems => _newsItems;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  Future<void> fetchHomeBerita() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sliderRes = await _repository.getBerita(kategori: 'informasi_terkini', perPage: 5);
      final newsRes = await _repository.getBerita(kategori: 'berita', perPage: 10);

      _sliderItems = sliderRes.items;
      _newsItems = newsRes.items;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Berita';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBerita({
    required String judul,
    String? ringkasan,
    required String konten,
    required String kategori,
    String? imagePath,
    String? linkUrl,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createBerita(
        judul: judul,
        ringkasan: ringkasan,
        konten: konten,
        kategori: kategori,
        imagePath: imagePath,
        linkUrl: linkUrl,
      );
      _isActionLoading = false;
      fetchHomeBerita();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menerbitkan Berita';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBerita({
    required int id,
    String? judul,
    String? ringkasan,
    String? konten,
    String? kategori,
    String? imagePath,
    String? linkUrl,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateBerita(
        id,
        judul: judul,
        ringkasan: ringkasan,
        konten: konten,
        kategori: kategori,
        imagePath: imagePath,
        linkUrl: linkUrl,
      );
      _isActionLoading = false;
      fetchHomeBerita();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Memperbarui Berita';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBerita(int id) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteBerita(id);
      _sliderItems.removeWhere((b) => b.id == id);
      _newsItems.removeWhere((b) => b.id == id);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menghapus Berita';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
