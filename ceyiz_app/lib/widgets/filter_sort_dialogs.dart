import 'package:flutter/material.dart';

/// Sıralama ve filtreleme dialogları için yardımcı sınıf
class FilterSortDialogs {
  /// Sıralama dialogunu gösterir
  static void showSortDialog(
    BuildContext context, {
    required Function() onSortByName,
    required Function() onSortByPriceAsc,
    required Function() onSortByPriceDesc,
    Function()? onSortByCategory,
  }) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sıralama'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onSortByName();
            },
            child: const Text('İsme Göre (A-Z)'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onSortByPriceAsc();
            },
            child: const Text('Fiyata Göre (Artan)'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onSortByPriceDesc();
            },
            child: const Text('Fiyata Göre (Azalan)'),
          ),
          if (onSortByCategory != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                onSortByCategory();
              },
              child: const Text('Kategoriye Göre'),
            ),
        ],
      ),
    );
  }

  /// Filtreleme dialogunu gösterir
  static void showFilterDialog(
    BuildContext context, {
    required Function() onFilterAll,
    required Function() onFilterPurchased,
    required Function() onFilterNotPurchased,
  }) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filtrele'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onFilterAll();
            },
            child: const Text('Tümü'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onFilterPurchased();
            },
            child: const Text('Sadece Alınanlar'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onFilterNotPurchased();
            },
            child: const Text('Sadece Alınmayanlar'),
          ),
        ],
      ),
    );
  }
}
