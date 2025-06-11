import 'dart:io';

import 'package:flutter/material.dart';

import '../services/photo_service.dart';

abstract class BaseItemViewModel extends ChangeNotifier {
  final PhotoService _photoService;

  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  List<String> _categories = [];
  List<String> _tempPhotos = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;
  bool _isFiltered = false;

  BaseItemViewModel({
    required PhotoService photoService,
  }) : _photoService = photoService;

  List<dynamic> get items => _isFiltered ? _filteredItems : _items;
  List<String> get categories => _categories;
  List<String> get tempPhotos => _tempPhotos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  int get totalItems => items.length;
  int get purchasedItems => items.where((item) => item.isPurchased).length;
  double get totalPrice => items.fold(0, (sum, item) => sum + item.price);
  double get purchaseProgress => totalItems == 0 ? 0 : purchasedItems / totalItems;

  Future<void> init() async {
    await loadItems();
    await loadCategories();
  }

  Future<void> loadItems();
  Future<void> loadCategories();

  Future<void> addItem(
    String name,
    String description,
    String category,
    double price,
  );

  Future<void> updateItem(dynamic item);
  Future<void> deleteItem(String id);

  Future<void> togglePurchaseStatus(String id) async {
    try {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
        await updateItemInStorage(updatedItem);
        _items[index] = updatedItem;

        // Filtrelenmiş listeyi de güncelle
        if (_isFiltered) {
          final filteredIndex = _filteredItems.indexWhere((item) => item.id == id);
          if (filteredIndex != -1) {
            _filteredItems[filteredIndex] = updatedItem;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      setError('Satın alma durumu güncellenirken bir hata oluştu: $e');
    }
  }

  Future<void> updateItemInStorage(dynamic item);

  Future<void> addPhotoToItem(String id, File photo) async {
    try {
      print('BaseItemViewModel.addPhotoToItem: Fotoğraf ekleniyor...');
      print('BaseItemViewModel.addPhotoToItem: Item ID: $id');
      print('BaseItemViewModel.addPhotoToItem: Fotoğraf yolu: ${photo.path}');

      // Fotoğraf dosyasının var olup olmadığını kontrol et
      if (!await photo.exists()) {
        print('BaseItemViewModel.addPhotoToItem: ERROR - Photo file does not exist: ${photo.path}');
        setError('Fotoğraf dosyası bulunamadı: ${photo.path}');
        return;
      }

      print(
          'BaseItemViewModel.addPhotoToItem: Photo file exists and has size: ${await photo.length()} bytes');

      if (_items.isEmpty) {
        print(
            'BaseItemViewModel.addPhotoToItem: WARNING - Items list is empty, fetching items from storage...');
        await loadItems();
      }

      // ID'ye sahip öğe var mı kontrol et
      final index = _items.indexWhere((item) => item.id == id);
      if (index == -1) {
        print('BaseItemViewModel.addPhotoToItem: ERROR - Item with ID $id not found');
        setError('Öğe bulunamadı (ID: $id)');
        return;
      }

      print('BaseItemViewModel.addPhotoToItem: Item found at index $index: ${_items[index].id}');

      // Fotoğrafı kaydet
      print('BaseItemViewModel.addPhotoToItem: Saving photo...');
      final photoUrl = await _photoService.savePhoto(photo);
      print('BaseItemViewModel.addPhotoToItem: Fotoğraf kaydedildi: $photoUrl');
      print('BaseItemViewModel.addPhotoToItem: Kaydedilen dosya mevcut mu: ${await File(photoUrl).exists()}');

      // Kaydedilen fotoğraf dosyasının var olup olmadığını kontrol et
      final savedPhotoFile = File(photoUrl);
      if (!await savedPhotoFile.exists()) {
        print(
            'BaseItemViewModel.addPhotoToItem: ERROR - Saved photo file does not exist: $photoUrl');
        setError('Kaydedilen fotoğraf dosyası bulunamadı: $photoUrl');
        return;
      }

      print(
          'BaseItemViewModel.addPhotoToItem: Saved photo file exists and has size: ${await savedPhotoFile.length()} bytes');

      final item = _items[index];
      print('BaseItemViewModel.addPhotoToItem: Mevcut fotoğraf URL\'leri: ${item.photoUrls}');

      final updatedPhotoUrls = [...item.photoUrls, photoUrl];
      print('BaseItemViewModel.addPhotoToItem: Güncellenmiş fotoğraf URL\'leri: $updatedPhotoUrls');

      final updatedItem = item.copyWith(photoUrls: updatedPhotoUrls);
      print('BaseItemViewModel.addPhotoToItem: Updating item in storage...');

      // Önce listeyi güncelle
      _items[index] = updatedItem;
      print('BaseItemViewModel.addPhotoToItem: Local items list updated');

      // Filtrelenmiş listeyi de güncelle
      if (_isFiltered) {
        final filteredIndex = _filteredItems.indexWhere((item) => item.id == id);
        if (filteredIndex != -1) {
          _filteredItems[filteredIndex] = updatedItem;
        }
      }

      // UI'ı güncelle
      notifyListeners();
      print('BaseItemViewModel.addPhotoToItem: Notified listeners about the update');

      // Sonra storage'ı güncelle
      await updateItemInStorage(updatedItem);
      print('BaseItemViewModel.addPhotoToItem: Item updated in storage successfully');
      print('BaseItemViewModel.addPhotoToItem: Notified listeners about the update');
    } catch (e) {
      print('BaseItemViewModel.addPhotoToItem: ERROR - $e');
      setError('Fotoğraf eklenirken bir hata oluştu: $e');
    }
  }

  Future<void> removePhotoFromItem(String id, String photoUrl) async {
    try {
      await _photoService.deletePhoto(photoUrl);
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        final updatedPhotoUrls = item.photoUrls.where((url) => url != photoUrl).toList();
        final updatedItem = item.copyWith(photoUrls: updatedPhotoUrls);
        await updateItemInStorage(updatedItem);
        _items[index] = updatedItem;

        // Filtrelenmiş listeyi de güncelle
        if (_isFiltered) {
          final filteredIndex = _filteredItems.indexWhere((item) => item.id == id);
          if (filteredIndex != -1) {
            _filteredItems[filteredIndex] = updatedItem;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      setError('Fotoğraf silinirken bir hata oluştu: $e');
    }
  }

  Future<void> addTempPhoto(File photo) async {
    try {
      final photoUrl = await _photoService.savePhoto(photo);
      _tempPhotos.add(photoUrl);
      notifyListeners();
    } catch (e) {
      setError('Geçici fotoğraf eklenirken bir hata oluştu: $e');
    }
  }

  Future<void> removeTempPhoto(String photoUrl) async {
    try {
      await _photoService.deletePhoto(photoUrl);
      _tempPhotos.remove(photoUrl);
      notifyListeners();
    } catch (e) {
      setError('Geçici fotoğraf silinirken bir hata oluştu: $e');
    }
  }

  void clearTempPhotos() {
    _tempPhotos.clear();
    notifyListeners();
  }

  // Sıralama metodları
  void sortByName() {
    _items.sort((a, b) => a.name.compareTo(b.name));
    if (_isFiltered) {
      _filteredItems.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  void sortByPriceAscending() {
    _items.sort((a, b) => a.price.compareTo(b.price));
    if (_isFiltered) {
      _filteredItems.sort((a, b) => a.price.compareTo(b.price));
    }
    notifyListeners();
  }

  void sortByPriceDescending() {
    _items.sort((a, b) => b.price.compareTo(a.price));
    if (_isFiltered) {
      _filteredItems.sort((a, b) => b.price.compareTo(a.price));
    }
    notifyListeners();
  }

  void sortByCategory() {
    _items.sort((a, b) => a.category.compareTo(b.category));
    if (_isFiltered) {
      _filteredItems.sort((a, b) => a.category.compareTo(b.category));
    }
    notifyListeners();
  }

  // Filtreleme metodları
  void filterAll() {
    _isFiltered = false;
    _filteredItems = [];
    notifyListeners();
  }

  void filterPurchased() {
    _isFiltered = true;
    _filteredItems = _items.where((item) => item.isPurchased).toList();
    notifyListeners();
  }

  void filterNotPurchased() {
    _isFiltered = true;
    _filteredItems = _items.where((item) => !item.isPurchased).toList();
    notifyListeners();
  }

  // Protected methods for subclasses to use
  @protected
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @protected
  void setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    _hasError = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  // Alt sınıfların items listesini güncellemesi için yardımcı metot
  void setItems(List<dynamic> items) {
    _items = items;
    if (_isFiltered) {
      _applyCurrentFilter();
    }
  }

  // Mevcut filtreyi yeniden uygula
  void _applyCurrentFilter() {
    if (_isFiltered) {
      if (_filteredItems.isNotEmpty && _filteredItems.first.isPurchased) {
        _filteredItems = _items.where((item) => item.isPurchased).toList();
      } else {
        _filteredItems = _items.where((item) => !item.isPurchased).toList();
      }
    }
  }

  // Alt sınıfların kategorileri güncellemesi için yardımcı metot
  void setCategories(List<String> categories) {
    _categories = categories;
  }

  // Provide protected access to photoService for subclasses
  @protected
  PhotoService get photoService => _photoService;
}
