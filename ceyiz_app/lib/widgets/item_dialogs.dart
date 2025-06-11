import 'package:flutter/material.dart';

import '../models/bohca_item_model.dart';
import '../models/ceyiz_item_model.dart';
import '../screens/dialogs/photo_dialog.dart';
import '../utils/dialog_helper.dart';
import '../viewmodels/bohca_view_model.dart';
import '../viewmodels/ceyiz_view_model.dart';
import 'item_form.dart';

/// Öğe dialogları için yardımcı sınıf
class ItemDialogs {
  /// Yeni çeyiz öğesi ekleme dialogunu gösterir
  static void showAddCeyizDialog(BuildContext context) {
    _showAddDialog(
      context: context,
      title: 'Yeni Çeyiz Öğesi',
      formType: FormType.ceyiz,
    );
  }

  /// Yeni bohça öğesi ekleme dialogunu gösterir
  static void showAddBohcaDialog(BuildContext context) {
    _showAddDialog(
      context: context,
      title: 'Yeni Bohça Öğesi',
      formType: FormType.bohca,
    );
  }

  /// Çeyiz öğesi düzenleme dialogunu gösterir
  static void showEditCeyizDialog(BuildContext context, CeyizItemModel item) {
    _showEditDialog(
      context: context,
      title: 'Çeyiz Öğesini Düzenle',
      formType: FormType.ceyiz,
      item: item,
    );
  }

  /// Bohça öğesi düzenleme dialogunu gösterir
  static void showEditBohcaDialog(BuildContext context, BohcaItemModel item) {
    _showEditDialog(
      context: context,
      title: 'Bohça Öğesini Düzenle',
      formType: FormType.bohca,
      item: item,
    );
  }

  /// Çeyiz öğesine fotoğraf ekleme dialogunu gösterir
  static void showAddPhotoCeyizDialog(
      BuildContext context, CeyizItemModel item, CeyizViewModel viewModel) {
    PhotoDialog.showCeyizPhotoDialog(context, item, viewModel);
  }

  /// Bohça öğesine fotoğraf ekleme dialogunu gösterir
  static void showAddPhotoBohcaDialog(
      BuildContext context, BohcaItemModel item, BohcaViewModel viewModel) {
    PhotoDialog.showBohcaPhotoDialog(context, item, viewModel);
  }

  /// Çeyiz öğesini silme onayı dialogunu gösterir
  static Future<void> showDeleteCeyizConfirmation(
    BuildContext context,
    CeyizItemModel item,
    CeyizViewModel viewModel,
  ) async {
    final confirmed = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Öğeyi Sil',
      content: '${item.name} öğesini silmek istediğinizden emin misiniz?',
      confirmText: 'Sil',
      cancelText: 'İptal',
    );

    if (confirmed && context.mounted) {
      viewModel.deleteItem(item.id);
      DialogHelper.showSuccessSnackBar(
        context: context,
        message: 'Öğe başarıyla silindi',
      );
    }
  }

  /// Bohça öğesini silme onayı dialogunu gösterir
  static Future<void> showDeleteBohcaConfirmation(
    BuildContext context,
    BohcaItemModel item,
    BohcaViewModel viewModel,
  ) async {
    final confirmed = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Öğeyi Sil',
      content: '${item.name} öğesini silmek istediğinizden emin misiniz?',
      confirmText: 'Sil',
      cancelText: 'İptal',
    );

    if (confirmed && context.mounted) {
      viewModel.deleteItem(item.id);
      DialogHelper.showSuccessSnackBar(
        context: context,
        message: 'Öğe başarıyla silindi',
      );
    }
  }

  /// Öğe ekleme dialogunu gösterir
  static void _showAddDialog({
    required BuildContext context,
    required String title,
    required FormType formType,
  }) {
    DialogHelper.showBottomSheet(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ItemForm(formType: formType),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Öğe düzenleme dialogunu gösterir
  static void _showEditDialog({
    required BuildContext context,
    required String title,
    required FormType formType,
    required dynamic item,
  }) {
    DialogHelper.showBottomSheet(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ItemForm(
              formType: formType,
              item: item,
              isEditing: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
