import 'package:flutter/material.dart';
import '../models/informasi_layanan_model.dart';
import '../services/informasi_layanan_service.dart';

class InformasiLayananProvider with ChangeNotifier {
  final InformasiLayananService _service = InformasiLayananService();

  List<InformasiLayananModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<InformasiLayananModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInformasiLayanan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.fetchInformasiLayanan();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInformasiLayanan(int id, String? deskripsi, String? tentang, List<String>? alur) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _service.updateInformasiLayanan(id, deskripsi, tentang, alur);
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
