import 'dart:io';

import 'package:uuid/uuid.dart';

import '../models/bohca_item_model.dart';
import '../services/bohca_service.dart';
import '../services/photo_service.dart';
import 'base_item_view_model.dart';

class BohcaViewModel extends BaseItemViewModel {
  final BohcaService _bohcaService;

  BohcaViewModel({
    required BohcaService bohcaService,
    required PhotoService photoService,
  })  : _bohcaService = bohcaService,
        super(photoService: photoService);

  @override
  Future<void> loadItems() async {
    setLoading(true);
    try {
      final items = await _bohcaService.getItems();
      setItems(items);
      setLoading(false);
    } catch (e) {
      setError('Öğeler yüklenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> loadCategories() async {
    try {
      final categories = await _bohcaService.getCategories();
      setCategories(categories);
      notifyListeners();
    } catch (e) {
      setError('Kategoriler yüklenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> addItem(
    String name,
    String description,
    String category,
    double price,
  ) async {
    setLoading(true);
    try {
      final item = BohcaItemModel(
        id: const Uuid().v4(),
        name: name,
        description: description,
        category: category,
        price: price,
        photoUrls: List<String>.from(tempPhotos),
        createdAt: DateTime.now(),
      );

      await _bohcaService.addItem(item);
      items.add(item);
      clearTempPhotos();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setError('Öğe eklenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> updateItem(dynamic item) async {
    if (item is! BohcaItemModel) {
      throw ArgumentError('Item must be a BohcaItemModel');
    }

    setLoading(true);
    try {
      await _bohcaService.updateItem(item);
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
      }
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setError('Öğe güncellenirken bir hata oluştu: $e');
    }
  }

  @override
  Future<void> updateItemInStorage(dynamic item) async {
    if (item is! BohcaItemModel) {
      throw ArgumentError('Item must be a BohcaItemModel');
    }
    await _bohcaService.updateItem(item);
  }

  @override
  Future<void> deleteItem(String id) async {
    setLoading(true);
    try {
      await _bohcaService.deleteItem(id);
      items.removeWhere((item) => item.id == id);
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setError('Öğe silinirken bir hata oluştu: $e');
    }
  }

  Future<void> togglePurchaseStatus(String id) async {
    try {
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = items[index];
        final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
        await _bohcaService.updateItem(updatedItem);
        items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      setError('Satın alma durumu güncellenirken bir hata oluştu: $e');
    }
  }

  Future<void> addPhotoToItem(String id, File photo) async {
    try {
      final photoUrl = await photoService.savePhoto(photo);
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = items[index];
        final updatedPhotoUrls = [...item.photoUrls, photoUrl];
        final updatedItem = item.copyWith(photoUrls: updatedPhotoUrls);
        await _bohcaService.updateItem(updatedItem);
        items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      setError('Fotoğraf eklenirken bir hata oluştu: $e');
    }
  }

  Future<void> removePhotoFromItem(String id, String photoUrl) async {
    try {
      await photoService.deletePhoto(photoUrl);
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = items[index];
        final updatedPhotoUrls = item.photoUrls.where((url) => url != photoUrl).toList();
        final updatedItem = item.copyWith(photoUrls: updatedPhotoUrls);
        await _bohcaService.updateItem(updatedItem);
        items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      setError('Fotoğraf silinirken bir hata oluştu: $e');
    }
  }

  Future<void> addTempPhoto(File photo) async {
    try {
      final photoUrl = await photoService.savePhoto(photo);
      tempPhotos.add(photoUrl);
      notifyListeners();
    } catch (e) {
      setError('Geçici fotoğraf eklenirken bir hata oluştu: $e');
    }
  }

  Future<void> removeTempPhoto(String photoUrl) async {
    try {
      await photoService.deletePhoto(photoUrl);
      tempPhotos.remove(photoUrl);
      notifyListeners();
    } catch (e) {
      setError('Geçici fotoğraf silinirken bir hata oluştu: $e');
    }
  }

  void clearTempPhotos() {
    tempPhotos.clear();
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    await _bohcaService.addCategory(category);
    await loadCategories();
    notifyListeners();
  }

  Future<void> removeCategory(String category) async {
    await _bohcaService.removeCategory(category);
    await loadCategories();
    notifyListeners();
  }
}
