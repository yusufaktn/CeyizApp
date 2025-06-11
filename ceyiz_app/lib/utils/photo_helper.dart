import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Fotoğraf işlemleri için yardımcı sınıf
class PhotoHelper {
  /// Galeriden fotoğraf seçme
  static Future<File?> pickImageFromGallery() async {
    print('PhotoHelper.pickImageFromGallery: Galeri açılıyor...');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        print('PhotoHelper.pickImageFromGallery: Fotoğraf seçildi: ${image.path}');
        final file = File(image.path);
        print('PhotoHelper.pickImageFromGallery: Dosya var mı: ${await file.exists()}');
        print('PhotoHelper.pickImageFromGallery: Dosya boyutu: ${await file.length()} bytes');
        return file;
      }
      print('PhotoHelper.pickImageFromGallery: Fotoğraf seçilmedi');
      return null;
    } catch (e) {
      print('PhotoHelper.pickImageFromGallery: HATA: $e');
      return null;
    }
  }

  /// Kamera ile fotoğraf çekme
  static Future<File?> takePhotoWithCamera() async {
    print('PhotoHelper.takePhotoWithCamera: Kamera açılıyor...');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        print('PhotoHelper.takePhotoWithCamera: Fotoğraf çekildi: ${image.path}');
        final file = File(image.path);
        print('PhotoHelper.takePhotoWithCamera: Dosya var mı: ${await file.exists()}');
        print('PhotoHelper.takePhotoWithCamera: Dosya boyutu: ${await file.length()} bytes');
        return file;
      }
      print('PhotoHelper.takePhotoWithCamera: Fotoğraf çekilmedi');
      return null;
    } catch (e) {
      print('PhotoHelper.takePhotoWithCamera: HATA: $e');
      return null;
    }
  }

  /// Fotoğraf seçme dialogunu gösterme
  static Future<File?> showPhotoPickerDialog(BuildContext context) async {
    print('PhotoHelper.showPhotoPickerDialog: Dialog gösteriliyor...');
    File? selectedFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotoğraf Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () async {
                print('PhotoHelper.showPhotoPickerDialog: Galeri seçildi');
                selectedFile = await pickImageFromGallery();
                print('PhotoHelper.showPhotoPickerDialog: Galeriden seçilen dosya: ${selectedFile?.path}');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () async {
                print('PhotoHelper.showPhotoPickerDialog: Kamera seçildi');
                selectedFile = await takePhotoWithCamera();
                print('PhotoHelper.showPhotoPickerDialog: Kamera ile çekilen dosya: ${selectedFile?.path}');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );

    print('PhotoHelper.showPhotoPickerDialog: Dialog kapandı, seçilen dosya: ${selectedFile?.path}');
    return selectedFile;
  }

  /// Fotoğraf widget'ı oluşturma
  static Widget buildPhotoWidget(String photoUrl, {BoxFit fit = BoxFit.cover}) {
    debugPrint('PhotoHelper.buildPhotoWidget: Fotoğraf yükleniyor: $photoUrl');
    final file = File(photoUrl);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        debugPrint('PhotoHelper.buildPhotoWidget: Dosya kontrolü yapılıyor...');
        // Dosya var mı kontrolü
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          debugPrint('PhotoHelper.buildPhotoWidget: Dosya mevcut, okuma başlıyor');
          // Dosya varsa, FutureBuilder ile dosyayı oku ve göster
          return FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, bytesSnapshot) {
              if (bytesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bytesSnapshot.hasData && bytesSnapshot.data != null) {
                debugPrint('PhotoHelper.buildPhotoWidget: Dosya başarıyla okundu, boyut: ${bytesSnapshot.data!.length} bytes');
                return Image.memory(
                  bytesSnapshot.data!,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('PhotoHelper: Memory image loading error: $error');
                    return _buildErrorWidget();
                  },
                );
              } else {
                debugPrint('PhotoHelper.buildPhotoWidget: HATA - Dosya okunamadı: $photoUrl');
                return _buildErrorWidget();
              }
            },
          );
        } else {
          debugPrint('PhotoHelper.buildPhotoWidget: HATA - Dosya bulunamadı: $photoUrl');
          return _buildErrorWidget();
        }
      },
    );
  }

  /// Hata durumunda gösterilecek widget
  static Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text('Fotoğraf Yüklenemedi', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
