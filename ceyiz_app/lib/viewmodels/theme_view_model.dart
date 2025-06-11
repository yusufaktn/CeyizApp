import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system; // Varsayılan değerle başlat
  bool _isLoading = true;

  ThemeViewModel() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themeKey);

      if (savedThemeMode == null) {
        // Eğer kayıtlı bir tema modu yoksa, sistem temasını kullan
        _themeMode = ThemeMode.system;
      } else {
        // Kayıtlı tema modunu yükle
        _themeMode = _parseThemeMode(savedThemeMode);
      }
    } catch (e) {
      debugPrint('Tema modu yüklenirken hata: $e');
      _themeMode = ThemeMode.system;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.toString());
    } catch (e) {
      debugPrint('Tema modu kaydedilirken hata: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // ThemeMode string'ini enum'a dönüştürür
  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
