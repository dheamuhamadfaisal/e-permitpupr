import '../models/berita_model.dart';
import '../services/berita_service.dart';

class BeritaRepository {
  final BeritaService _service;

  BeritaRepository({BeritaService? service})
      : _service = service ?? BeritaService();

  Future<PaginatedBerita> getBerita({
    String? kategori,
    String? search,
    int page = 1,
    int perPage = 10,
  }) {
    return _service.getBerita(
      kategori: kategori,
      search: search,
      page: page,
      perPage: perPage,
    );
  }

  Future<BeritaModel> createBerita({
    required String judul,
    String? ringkasan,
    required String konten,
    required String kategori,
    String? imagePath,
    String? linkUrl,
  }) {
    return _service.createBerita(
      judul: judul,
      ringkasan: ringkasan,
      konten: konten,
      kategori: kategori,
      imagePath: imagePath,
      linkUrl: linkUrl,
    );
  }

  Future<BeritaModel> updateBerita(
    int id, {
    String? judul,
    String? ringkasan,
    String? konten,
    String? kategori,
    String? imagePath,
    String? linkUrl,
  }) {
    return _service.updateBerita(
      id,
      judul: judul,
      ringkasan: ringkasan,
      konten: konten,
      kategori: kategori,
      imagePath: imagePath,
      linkUrl: linkUrl,
    );
  }

  Future<void> deleteBerita(int id) => _service.deleteBerita(id);
}
