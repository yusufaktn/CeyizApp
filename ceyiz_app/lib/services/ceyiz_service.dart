import 'dart:io';

import '../models/ceyiz_item_model.dart';
import 'local_storage_service.dart';

class CeyizService {
  final LocalStorageService _storage;
  final String _itemsKey = 'ceyiz_items';
  final String _categoriesKey = 'ceyiz_categories';

  CeyizService({required LocalStorageService storage}) : _storage = storage;

  Future<List<CeyizItemModel>> getItems() async {
    final itemsJson = await _storage.getJsonList(_itemsKey);
    final items = itemsJson.map((json) => CeyizItemModel.fromJson(json)).toList();
    print('CeyizService.getItems: Retrieved ${items.length} items from storage');
    for (var item in items) {
      print('  - Item: ${item.id}, ${item.name}, isPurchased: ${item.isPurchased}');
    }
    return items;
  }

  Future<List<String>> getCategories() async {
    final categories = await _storage.getStringList(_categoriesKey);
    if (categories.isEmpty) {
      // Varsayılan kategorileri ekle
      final defaultCategories = [
        'Mutfak',
        'Banyo',
        'Yatak Odası',
        'Oturma Odası',
        'Elektrikli Ev Aletleri',
        'Diğer'
      ];
      await _storage.saveStringList(_categoriesKey, defaultCategories);
      return defaultCategories;
    }
    return categories;
  }

  Future<void> addCategory(String category) async {
    final categories = await getCategories();
    if (!categories.contains(category)) {
      categories.add(category);
      await _storage.saveStringList(_categoriesKey, categories);
    }
  }

  Future<void> removeCategory(String category) async {
    final categories = await getCategories();
    if (categories.contains(category)) {
      categories.remove(category);
      await _storage.saveStringList(_categoriesKey, categories);
    }
  }

  Future<void> addItem(CeyizItemModel item) async {
    final items = await getItems();
    print('CeyizService.addItem: Adding item: ${item.id}, ${item.name}');
    items.add(item);
    await _saveItems(items);

    // Kategori yoksa ekle
    final categories = await getCategories();
    if (!categories.contains(item.category)) {
      await addCategory(item.category);
    }

    print('CeyizService.addItem: Item added successfully');
  }

  Future<void> updateItem(CeyizItemModel updatedItem) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      print(
          'CeyizService.updateItem: Updating item ID: ${updatedItem.id}, name: ${updatedItem.name}');
      print('CeyizService.updateItem: Photos before update: ${items[index].photoUrls}');
      print('CeyizService.updateItem: Photos after update: ${updatedItem.photoUrls}');

      // Fotoğraf URL'lerini kontrol et
      if (updatedItem.photoUrls.isNotEmpty) {
        print('CeyizService.updateItem: Checking photo files existence...');
        for (var photoUrl in updatedItem.photoUrls) {
          final file = File(photoUrl);
          final exists = await file.exists();
          print('CeyizService.updateItem: Photo $photoUrl exists: $exists');
          if (exists) {
            final size = await file.length();
            print('CeyizService.updateItem: Photo $photoUrl size: $size bytes');
          }
        }
      }

      items[index] = updatedItem;
      await _saveItems(items);

      // Güncelleme sonrası doğrulama
      final updatedItems = await getItems();
      final updatedIndex = updatedItems.indexWhere((item) => item.id == updatedItem.id);
      if (updatedIndex != -1) {
        print('CeyizService.updateItem: Verification - Item found after update');
        print(
            'CeyizService.updateItem: Verification - Photos after storage: ${updatedItems[updatedIndex].photoUrls}');
      } else {
        print('CeyizService.updateItem: Verification ERROR - Item not found after update!');
      }

      // Kategori yoksa ekle
      final categories = await getCategories();
      if (!categories.contains(updatedItem.category)) {
        await addCategory(updatedItem.category);
      }

      print('CeyizService.updateItem: Item updated successfully');
    } else {
      print('CeyizService.updateItem: ERROR - Item not found with ID: ${updatedItem.id}');
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id);
    await _saveItems(items);
  }

  Future<void> _saveItems(List<CeyizItemModel> items) async {
    final itemsJson = items.map((item) => item.toJson()).toList();
    await _storage.saveJsonList(_itemsKey, itemsJson);
    print('CeyizService._saveItems: Saved ${items.length} items to storage');
  }
}
