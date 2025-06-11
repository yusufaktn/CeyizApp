import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/bohca_item_model.dart';
import '../../models/ceyiz_item_model.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/photo_helper.dart';
import '../../viewmodels/bohca_view_model.dart';
import '../../viewmodels/ceyiz_view_model.dart';

/// Fotoğraf ekleme dialogunu gösteren ve işleyen sınıf
class PhotoDialog {
  /// Çeyiz öğesine fotoğraf ekleme dialogunu gösterir
  static Future<void> showCeyizPhotoDialog(
    BuildContext context,
    CeyizItemModel item,
    CeyizViewModel viewModel,
  ) async {
    print('PhotoDialog.showCeyizPhotoDialog: Dialog gösteriliyor...');
    final file = await PhotoHelper.showPhotoPickerDialog(context);
    if (file != null && context.mounted) {
      print('PhotoDialog.showCeyizPhotoDialog: Fotoğraf seçildi: ${file.path}');
      print('PhotoDialog.showCeyizPhotoDialog: Dosya var mı: ${await file.exists()}');
      print('PhotoDialog.showCeyizPhotoDialog: Dosya boyutu: ${await file.length()} bytes');
      
      await _addPhotoToItem<CeyizItemModel, CeyizViewModel>(
        context: context,
        file: file,
        item: item,
        viewModel: viewModel,
        itemType: 'çeyiz',
      );
    } else {
      print('PhotoDialog.showCeyizPhotoDialog: Fotoğraf seçilmedi veya context artık geçerli değil');
    }
  }

  /// Bohça öğesine fotoğraf ekleme dialogunu gösterir
  static Future<void> showBohcaPhotoDialog(
    BuildContext context,
    BohcaItemModel item,
    BohcaViewModel viewModel,
  ) async {
    final file = await PhotoHelper.showPhotoPickerDialog(context);
    if (file != null && context.mounted) {
      await _addPhotoToItem<BohcaItemModel, BohcaViewModel>(
        context: context,
        file: file,
        item: item,
        viewModel: viewModel,
        itemType: 'bohça',
      );
    }
  }

  /// Öğeye fotoğraf ekler (generic metod)
  static Future<void> _addPhotoToItem<T, V>({
    required BuildContext context,
    required File file,
    required T item,
    required V viewModel,
    required String itemType,
  }) async {
    try {
      print('PhotoDialog: Fotoğraf ekleme başlıyor...');
      print('PhotoDialog: Dosya yolu: ${file.path}');
      print('PhotoDialog: Dosya var mı: ${await file.exists()}');
      print('PhotoDialog: Dosya boyutu: ${await file.length()} bytes');

      // item ve viewModel'in gerekli metodlara sahip olduğundan emin olalım
      if (!(item is dynamic) || !(viewModel is dynamic)) {
        throw Exception('Geçersiz item veya viewModel tipi');
      }

      final dynamic dynamicItem = item;
      final dynamic dynamicViewModel = viewModel;

      print('PhotoDialog: $itemType öğesi ID: ${dynamicItem.id}');
      print('PhotoDialog: File nesnesi oluşturuldu: ${file.path}');
      print('PhotoDialog: File var mı: ${await file.exists()}');

      // Doğrudan ViewModel'in addPhotoToItem metodunu çağır
      await dynamicViewModel.addPhotoToItem(dynamicItem.id, file);
      print('PhotoDialog: Fotoğraf başarıyla eklendi');

      if (context.mounted) {
        DialogHelper.showSuccessSnackBar(
          context: context,
          message: 'Fotoğraf başarıyla eklendi',
        );
      }
    } catch (e) {
      print('PhotoDialog: Fotoğraf işleme hatası: $e');
      if (context.mounted) {
        DialogHelper.showErrorSnackBar(
          context: context,
          message: 'Fotoğraf işlenirken hata: $e',
        );
      }
    }
  }
}
