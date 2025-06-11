import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<List<Map<String, dynamic>>> getJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(key) ?? [];
    print('LocalStorageService.getJsonList: Retrieved ${stringList.length} items for key: $key');

    try {
      final result =
          stringList.map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>).toList();
      print('LocalStorageService.getJsonList: Successfully parsed ${result.length} items');
      return result;
    } catch (e) {
      print('LocalStorageService.getJsonList: Error parsing JSON: $e');
      print('LocalStorageService.getJsonList: Raw data: $stringList');
      return [];
    }
  }

  Future<void> saveJsonList(String key, List<Map<String, dynamic>> jsonList) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final stringList = jsonList.map((json) => jsonEncode(json)).toList();
      print('LocalStorageService.saveJsonList: Saving ${stringList.length} items for key: $key');

      final result = await prefs.setStringList(key, stringList);
      print('LocalStorageService.saveJsonList: Save result: $result');
    } catch (e) {
      print('LocalStorageService.saveJsonList: Error saving data: $e');
      print('LocalStorageService.saveJsonList: Failed data: $jsonList');
      rethrow;
    }
  }

  Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList(key) ?? [];
    print('LocalStorageService.getStringList: Retrieved ${result.length} items for key: $key');
    return result;
  }

  Future<void> saveStringList(String key, List<String> stringList) async {
    final prefs = await SharedPreferences.getInstance();
    print('LocalStorageService.saveStringList: Saving ${stringList.length} items for key: $key');
    final result = await prefs.setStringList(key, stringList);
    print('LocalStorageService.saveStringList: Save result: $result');
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<int> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<double> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? 0.0;
  }

  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
