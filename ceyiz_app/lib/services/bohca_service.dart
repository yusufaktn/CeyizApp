import '../models/bohca_item_model.dart';
import 'local_storage_service.dart';

class BohcaService {
  final LocalStorageService _storage;
  final String _itemsKey = 'bohca_items';
  final String _categoriesKey = 'bohca_categories';

  BohcaService({required LocalStorageService storage}) : _storage = storage;

  Future<List<BohcaItemModel>> getItems() async {
    final itemsJson = await _storage.getJsonList(_itemsKey);
    return itemsJson.map((json) => BohcaItemModel.fromJson(json)).toList();
  }

  Future<List<String>> getCategories() async {
    final categories = await _storage.getStringList(_categoriesKey);
    if (categories.isEmpty) {
      // Varsayılan kategorileri ekle
      final defaultCategories = ['Giyim', 'Aksesuar', 'Çanta', 'Ayakkabı', 'Kozmetik', 'Diğer'];
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

  Future<void> addItem(BohcaItemModel item) async {
    final items = await getItems();
    items.add(item);
    await _saveItems(items);

    // Kategori yoksa ekle
    final categories = await getCategories();
    if (!categories.contains(item.category)) {
      await addCategory(item.category);
    }
  }

  Future<void> updateItem(BohcaItemModel updatedItem) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      print(
          'BohcaService.updateItem: Updating item ID: ${updatedItem.id}, name: ${updatedItem.name}');
      print('BohcaService.updateItem: Photos before update: ${items[index].photoUrls}');
      print('BohcaService.updateItem: Photos after update: ${updatedItem.photoUrls}');

      items[index] = updatedItem;
      await _saveItems(items);

      // Kategori yoksa ekle
      final categories = await getCategories();
      if (!categories.contains(updatedItem.category)) {
        await addCategory(updatedItem.category);
      }

      print('BohcaService.updateItem: Item updated successfully');
    } else {
      print('BohcaService.updateItem: ERROR - Item not found with ID: ${updatedItem.id}');
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id);
    await _saveItems(items);
  }

  Future<void> _saveItems(List<BohcaItemModel> items) async {
    final itemsJson = items.map((item) => item.toJson()).toList();
    await _storage.saveJsonList(_itemsKey, itemsJson);
  }
}
