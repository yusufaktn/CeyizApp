import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Fotoğraf işlemleri için yardımcı sınıf
class PhotoHelper {
  /// Galeriden fotoğraf seçme
  static Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('PhotoHelper.pickImageFromGallery: HATA: $e');
      return null;
    }
  }

  /// Kamera ile fotoğraf çekme
  static Future<File?> takePhotoWithCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('PhotoHelper.takePhotoWithCamera: HATA: $e');
      return null;
    }
  }

  /// Fotoğraf seçme dialogunu gösterme
  static Future<File?> showPhotoPickerDialog(BuildContext context) async {
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
                Navigator.pop(context);
                selectedFile = await pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () async {
                Navigator.pop(context);
                selectedFile = await takePhotoWithCamera();
              },
            ),
          ],
        ),
      ),
    );

    return selectedFile;
  }

  /// Fotoğraf widget'ı oluşturma
  static Widget buildPhotoWidget(String photoUrl, {BoxFit fit = BoxFit.cover}) {
    final file = File(photoUrl);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        // Dosya var mı kontrolü
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          // Dosya varsa, FutureBuilder ile dosyayı oku ve göster
          return FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, bytesSnapshot) {
              if (bytesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bytesSnapshot.hasData && bytesSnapshot.data != null) {
                return Image.memory(
                  bytesSnapshot.data!,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('PhotoHelper: Memory image loading error: $error');
                    return _buildErrorWidget();
                  },
                );
              } else {
                debugPrint('PhotoHelper: Error loading image bytes at $photoUrl');
                return _buildErrorWidget();
              }
            },
          );
        } else {
          debugPrint('PhotoHelper: File does not exist at $photoUrl');
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
