import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Galeriden fotoğraf seçme
  Future<File?> pickImageFromGallery() async {
    try {
      print('PhotoService.pickImageFromGallery: Galeriden fotoğraf seçiliyor...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      print('PhotoService.pickImageFromGallery: Seçilen fotoğraf: ${image?.path}');
      if (image != null) {
        final tempFile = File(image.path);
        // Seçilen fotoğrafı kalıcı olarak kaydet
        final savedPath = await savePhoto(tempFile);
        return File(savedPath);
      }
      return null;
    } catch (e) {
      print('PhotoService.pickImageFromGallery: HATA: $e');
      rethrow;
    }
  }

  // Kameradan fotoğraf çekme
  Future<File?> takePhotoWithCamera() async {
    try {
      print('PhotoService.takePhotoWithCamera: Kamera ile fotoğraf çekiliyor...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      print('PhotoService.takePhotoWithCamera: Çekilen fotoğraf: ${image?.path}');
      if (image != null) {
        final tempFile = File(image.path);
        // Çekilen fotoğrafı kalıcı olarak kaydet
        final savedPath = await savePhoto(tempFile);
        return File(savedPath);
      }
      return null;
    } catch (e) {
      print('PhotoService.takePhotoWithCamera: HATA: $e');
      rethrow;
    }
  }

  Future<String> savePhoto(File photo) async {
    try {
      print('PhotoService.savePhoto: Fotoğraf kaydediliyor: ${photo.path}');

      // Önce kaynak dosyanın var olup olmadığını kontrol et
      if (!await photo.exists()) {
        print('PhotoService.savePhoto: HATA - Kaynak dosya bulunamadı: ${photo.path}');
        throw Exception('Kaynak fotoğraf dosyası bulunamadı');
      }

      final sourceSize = await photo.length();
      print('PhotoService.savePhoto: Kaynak dosya boyutu: $sourceSize byte');

      // Uygulama dökümanları dizinini al
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');

      print('PhotoService.savePhoto: Fotoğraf dizini: ${photosDir.path}');

      // photos klasörü yoksa oluştur
      if (!await photosDir.exists()) {
        print('PhotoService.savePhoto: Fotoğraf dizini oluşturuluyor...');
        await photosDir.create(recursive: true);
      }

      // Benzersiz bir dosya adı oluştur
      final uuid = const Uuid().v4();
      final extension = path.extension(photo.path).isNotEmpty
          ? path.extension(photo.path)
          : '.jpg'; // Uzantı yoksa .jpg ekle
      final fileName = '$uuid$extension';
      final targetPath = '${photosDir.path}/$fileName';

      print('PhotoService.savePhoto: Hedef dosya: $targetPath');
      print('PhotoService.savePhoto: Hedef klasör mevcut mu: ${await photosDir.exists()}');
      print('PhotoService.savePhoto: Kaynak fotoğraf boyutu: ${await photo.length()} byte');

      // Hedef dosyanın var olup olmadığını kontrol et
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        print('PhotoService.savePhoto: Hedef dosya zaten var, siliniyor...');
        await targetFile.delete();
      }

      // Fotoğrafı kopyala
      try {
        print('PhotoService.savePhoto: Fotoğraf kopyalama işlemi başlıyor...');
        // Kaynak dosyayı oku
        final bytes = await photo.readAsBytes();
        print('PhotoService.savePhoto: Kaynak dosya okundu, ${bytes.length} byte');

        // Hedef dosyaya yaz
        await targetFile.writeAsBytes(bytes, flush: true);
        print('PhotoService.savePhoto: Hedef dosyaya yazıldı');
        print('PhotoService.savePhoto: Hedef dosya oluşturuldu mu: ${await targetFile.exists()}');
        print('PhotoService.savePhoto: Kaydedilen dosya boyutu: ${await targetFile.length()} byte');
      } catch (e) {
        print('PhotoService.savePhoto: Dosya kopyalama hatası: $e');
        // Klasik kopyalama yöntemini dene
        final savedPhoto = await photo.copy(targetPath);
        print('PhotoService.savePhoto: Fotoğraf klasik yöntemle kopyalandı: ${savedPhoto.path}');
      }

      // Dosyanın varlığını kontrol et
      if (await targetFile.exists()) {
        final savedSize = await targetFile.length();
        print('PhotoService.savePhoto: Dosya var ve erişilebilir: ${targetFile.path}');
        print('PhotoService.savePhoto: Dosya boyutu: $savedSize byte');

        // Dosya boyutu 0 ise hata fırlat
        if (savedSize == 0) {
          print('PhotoService.savePhoto: HATA - Kaydedilen dosya boş (0 byte)');
          throw Exception('Kaydedilen fotoğraf dosyası boş');
        }

        // Kaynak ve hedef dosya boyutları çok farklıysa uyarı ver
        if (savedSize < sourceSize * 0.5) {
          print('PhotoService.savePhoto: UYARI - Kaydedilen dosya boyutu beklenenden küçük');
        }
      } else {
        print(
            'PhotoService.savePhoto: HATA - Dosya var olması gerekiyor ama bulunamadı: ${targetFile.path}');
        throw Exception('Fotoğraf kaydedildi ancak dosya bulunamadı');
      }

      // Dosya izinlerini kontrol et
      try {
        final stat = await targetFile.stat();
        print('PhotoService.savePhoto: Dosya izinleri: ${stat.modeString()}');
      } catch (e) {
        print('PhotoService.savePhoto: Dosya izinleri kontrol edilirken hata: $e');
      }

      return targetFile.path;
    } catch (e) {
      print('PhotoService.savePhoto: HATA: $e');
      throw Exception('Fotoğraf kaydedilemedi: $e');
    }
  }

  // Fotoğrafı sunucuya yükleme
  Future<String?> uploadPhoto(File imageFile) async {
    try {
      // Gerçek bir sunucuya yükleme yapmak yerine yerel olarak kaydediyoruz
      print('PhotoService.uploadPhoto: Fotoğraf yükleniyor: ${imageFile.path}');

      // Fotoğrafı kalıcı olarak kaydet
      final savedPath = await savePhoto(imageFile);
      print('PhotoService.uploadPhoto: Fotoğraf kaydedildi: $savedPath');

      return savedPath;
    } catch (e) {
      debugPrint('Fotoğraf yükleme hatası: $e');
      return null;
    }
  }

  // Fotoğrafları çoklu seçme
  Future<List<File>> pickMultipleImages() async {
    try {
      print('PhotoService.pickMultipleImages: Çoklu fotoğraf seçiliyor...');
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      print('PhotoService.pickMultipleImages: ${pickedFiles.length} fotoğraf seçildi');

      // Seçilen her fotoğrafı kalıcı olarak kaydet
      List<File> savedFiles = [];
      for (var xFile in pickedFiles) {
        final tempFile = File(xFile.path);
        final savedPath = await savePhoto(tempFile);
        savedFiles.add(File(savedPath));
      }

      return savedFiles;
    } catch (e) {
      print('PhotoService.pickMultipleImages: HATA: $e');
      return [];
    }
  }

  // Fotoğrafı silme
  Future<void> deletePhoto(String photoPath) async {
    try {
      print('PhotoService.deletePhoto: Fotoğraf siliniyor: $photoPath');
      final file = File(photoPath);
      if (await file.exists()) {
        print('PhotoService.deletePhoto: Dosya var, siliniyor...');
        await file.delete();
        print('PhotoService.deletePhoto: Dosya başarıyla silindi');
      } else {
        print('PhotoService.deletePhoto: Dosya bulunamadı, silinemiyor');
      }
    } catch (e) {
      print('PhotoService.deletePhoto: HATA: $e');
      throw Exception('Fotoğraf silinemedi: $e');
    }
  }
}
