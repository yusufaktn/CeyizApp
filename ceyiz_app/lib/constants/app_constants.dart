class AppConstants {
  // API Endpoint'leri
  static const String baseUrl = 'https://api.example.com';
  static const String ceyizEndpoint = '/ceyiz';
  static const String bohcaEndpoint = '/bohca';

  // Kategori listesi
  static const List<String> categories = [
    'Mobilya',
    'Elektrikli Ev Aletleri',
    'Mutfak',
    'Tekstil Ürünleri',
    'Banyo Ürünleri',
    'Dekorasyon',
    'Elektronik',
    'Diğer',
  ];

  // Uygulama ayarları
  static const String appName = 'Çeyiz Uygulaması';
  static const String appVersion = '1.0.0';
  static const int splashScreenDuration = 2; // saniye

  // Routes
  static const String homeRoute = '/';
  static const String splashRoute = '/splash';
  static const String ceyizRoute = '/ceyiz';
  static const String bohcaRoute = '/bohca';
  static const String categoryRoute = '/category';

  // Shared Preferences Keys
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String userKey = 'user_data';

  // API Constants
  static const String apiBaseUrl = 'https://api.example.com';
  static const int apiTimeout = 30; // seconds

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Animation Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}
