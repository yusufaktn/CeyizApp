import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/bohca_item_model.dart';
import '../models/category_model.dart';
import '../models/ceyiz_item_model.dart';
import '../services/bohca_service.dart';
import '../services/ceyiz_service.dart';
import '../services/photo_service.dart';

class HomeViewModel extends ChangeNotifier {
  final CeyizService? ceyizService;
  final BohcaService? bohcaService;
  final PhotoService? photoService;

  List<CategoryModel> categories = [];
  List<CeyizItemModel> _recentCeyizItems = [];
  List<BohcaItemModel> _recentBohcaItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  HomeViewModel({
    this.ceyizService,
    this.bohcaService,
    this.photoService,
  });

  List<CeyizItemModel> get recentCeyizItems => _recentCeyizItems;
  List<BohcaItemModel> get recentBohcaItems => _recentBohcaItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  Future<void> init() async {
    _initializeCategories();
    await loadRecentItems();
  }

  void _initializeCategories() {
    categories = [
      CategoryModel(
        id: 'ceyiz',
        name: 'Çeyiz',
        description: 'Tüm çeyiz ürünlerinizi yönetin',
        iconData: Icons.inventory_2_outlined,
        color: const Color(0xFF6A1B9A),
        route: AppConstants.ceyizRoute,
      ),
      CategoryModel(
        id: 'bohca',
        name: 'Bohça',
        description: 'Bohça ürünlerinizi yönetin',
        iconData: Icons.card_giftcard_outlined,
        color: const Color(0xFF00695C),
        route: AppConstants.bohcaRoute,
      ),
    ];
  }

  void navigateToCategory(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void navigateToCeyiz(BuildContext context) {
    navigateToCategory(context, AppConstants.ceyizRoute);
  }

  void navigateToBohca(BuildContext context) {
    navigateToCategory(context, AppConstants.bohcaRoute);
  }

  Future<void> loadRecentItems() async {
    _setLoading(true);
    try {
      // Çeyiz öğelerini yükle
      final ceyizItems = await ceyizService?.getItems() ?? [];

      // Bohça öğelerini yükle
      final bohcaItems = await bohcaService?.getItems() ?? [];

      // Öğeleri tarihe göre sırala (en yeni önce)
      ceyizItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      bohcaItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // En son eklenen 5 öğeyi al
      _recentCeyizItems = ceyizItems.take(5).toList();
      _recentBohcaItems = bohcaItems.take(5).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Öğeler yüklenirken bir hata oluştu: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
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
}
