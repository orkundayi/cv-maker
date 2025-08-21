import 'dart:html' as html;
import 'dart:async'; // Added for Completer
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';

/// Service for handling image uploads in web environment
class ImageUploadService {
  const ImageUploadService._();

  /// Pick image from file input - Simple and reliable approach
  static Future<html.File?> pickImage({List<String>? allowedFormats, int? maxSizeBytes}) async {
    if (kDebugMode) print('📁 ImageUploadService.pickImage başladı');

    try {
      // Create file input element
      final input = html.FileUploadInputElement()
        ..accept = _getAcceptedFormats(allowedFormats ?? AppConstants.allowedImageFormats)
        ..multiple = false;

      // Open file picker
      if (kDebugMode) print('🖱️ File picker açılıyor...');
      input.click();

      // Wait for user to select file
      if (kDebugMode) print('⏳ File seçimi bekleniyor...');

      // Simple polling approach - check every 100ms
      for (int i = 0; i < 50; i++) {
        // Max 5 seconds wait
        await Future.delayed(const Duration(milliseconds: 100));

        if (input.files != null && input.files!.isNotEmpty) {
          final file = input.files!.first;
          if (kDebugMode) print('✅ File seçildi: ${file.name} (${file.size} bytes)');

          // Validate file size
          if (maxSizeBytes != null && file.size > maxSizeBytes) {
            if (kDebugMode) print('❌ File boyutu çok büyük: ${file.size} > $maxSizeBytes');
            throw Exception(
              'File size exceeds maximum allowed size of ${(maxSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB',
            );
          }

          // Validate file format
          final extension = _getFileExtension(file.name);
          if (kDebugMode) print('🔍 File extension: $extension');
          if (!(allowedFormats ?? AppConstants.allowedImageFormats).contains(extension.toLowerCase())) {
            if (kDebugMode) print('❌ File format desteklenmiyor: $extension');
            throw Exception(
              'File format not supported. Allowed formats: ${(allowedFormats ?? AppConstants.allowedImageFormats).join(', ')}',
            );
          }

          if (kDebugMode) print('✅ File validation başarılı');
          return file;
        }
      }

      if (kDebugMode) print('❌ File seçilmedi veya timeout');
      return null;
    } catch (e) {
      if (kDebugMode) print('💥 pickImage hatası: $e');
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Convert image file to base64 string - Simple approach
  static Future<String> imageToBase64(html.File file) async {
    if (kDebugMode) print('🔄 imageToBase64 başladı: ${file.name}');

    try {
      final reader = html.FileReader();

      // Use Completer for simple async handling
      final completer = Completer<String>();

      reader.onLoad.listen((event) {
        final result = reader.result;
        if (kDebugMode) print('📖 FileReader result type: ${result.runtimeType}');

        if (result is String) {
          // Data URL format: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
          final base64Data = result.split(',')[1];
          if (kDebugMode) print('✅ Base64 data hazır, uzunluk: ${base64Data.length}');
          completer.complete(base64Data);
        } else {
          if (kDebugMode) print('❌ Beklenmeyen result type: ${result.runtimeType}');
          completer.completeError(Exception('Failed to read image file - unexpected type'));
        }
      });

      reader.onError.listen((event) {
        if (kDebugMode) print('❌ FileReader error: $event');
        completer.completeError(Exception('Failed to read image file: $event'));
      });

      if (kDebugMode) print('📖 readAsDataUrl çağrılıyor...');
      reader.readAsDataUrl(file);

      final result = await completer.future;
      if (kDebugMode) print('✅ imageToBase64 tamamlandı');
      return result;
    } catch (e) {
      if (kDebugMode) print('💥 imageToBase64 hatası: $e');
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  /// Compress image if it exceeds max dimensions - Simple approach
  static Future<html.File> compressImage(html.File file, {int maxWidth = 800, int maxHeight = 600}) async {
    if (kDebugMode) print('🗜️ compressImage başladı: ${file.name} (${file.size} bytes)');

    try {
      final canvas = html.CanvasElement(width: maxWidth, height: maxHeight);
      final ctx = canvas.getContext('2d') as html.CanvasRenderingContext2D;
      if (kDebugMode) print('🎨 Canvas oluşturuldu: ${canvas.width}x${canvas.height}');

      final img = html.ImageElement()..src = html.Url.createObjectUrlFromBlob(file);
      if (kDebugMode) print('🖼️ Image element oluşturuldu, src: ${img.src?.substring(0, 50)}...');

      // Use Completer for simple async handling
      final completer = Completer<html.File>();

      img.onLoad.listen((event) {
        try {
          if (kDebugMode) print('🖼️ Image yüklendi: ${img.naturalWidth}x${img.naturalHeight}');

          // Calculate new dimensions maintaining aspect ratio
          final aspectRatio = img.naturalWidth / img.naturalHeight;
          int newWidth = maxWidth;
          int newHeight = maxHeight;

          if (aspectRatio > 1) {
            // Landscape image
            newHeight = (maxWidth / aspectRatio).round();
          } else {
            // Portrait image
            newWidth = (maxHeight * aspectRatio).round();
          }

          if (kDebugMode) {
            print('📏 Yeni boyutlar: ${newWidth}x$newHeight (aspect ratio: ${aspectRatio.toStringAsFixed(2)})');
          }

          // Resize canvas to new dimensions
          canvas.width = newWidth;
          canvas.height = newHeight;

          // Draw and compress image
          if (kDebugMode) print('🎨 Canvas\'a image çiziliyor...');
          ctx.drawImageScaled(img, 0, 0, newWidth, newHeight);

          // Convert to data URL
          if (kDebugMode) print('🔄 Canvas\'tan data URL oluşturuluyor...');
          final dataUrl = canvas.toDataUrl();
          if (kDebugMode) print('✅ Data URL oluşturuldu, uzunluk: ${dataUrl.length}');

          // Data URL'den base64 string'i çıkar
          final base64Data = dataUrl.split(',')[1];
          if (kDebugMode) print('✅ Base64 data hazır, uzunluk: ${base64Data.length}');

          // Base64'ten Uint8List oluştur
          final bytes = _base64ToBytes(base64Data);
          if (kDebugMode) print('✅ Bytes oluşturuldu: ${bytes.length} bytes');

          final compressedFile = html.File(
            [bytes],
            file.name,
            {'type': file.type.isNotEmpty ? file.type : 'image/jpeg'},
          );
          if (kDebugMode) print('✅ Compressed file oluşturuldu: ${compressedFile.size} bytes');

          completer.complete(compressedFile);
          html.Url.revokeObjectUrl(img.src!);
        } catch (e) {
          if (kDebugMode) print('💥 Image compression hatası: $e');
          html.Url.revokeObjectUrl(img.src!);
          completer.completeError(Exception('Failed to compress image: $e'));
        }
      });

      img.onError.listen((event) {
        if (kDebugMode) print('❌ Image load error: $event');
        html.Url.revokeObjectUrl(img.src!);
        completer.completeError(Exception('Failed to load image for compression'));
      });

      final result = await completer.future;
      if (kDebugMode) print('✅ compressImage tamamlandı');
      return result;
    } catch (e) {
      if (kDebugMode) print('💥 compressImage hatası: $e');
      throw Exception('Failed to compress image: $e');
    }
  }

  /// Convert Base64 string to Uint8List
  static Uint8List _base64ToBytes(String base64) {
    const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = <int>[];

    // Remove padding characters
    base64 = base64.replaceAll('=', '');

    for (int i = 0; i < base64.length; i += 4) {
      final c1 = base64Chars.indexOf(base64[i]);
      final c2 = i + 1 < base64.length ? base64Chars.indexOf(base64[i + 1]) : 0;
      final c3 = i + 2 < base64.length ? base64Chars.indexOf(base64[i + 2]) : 0;
      final c4 = i + 3 < base64.length ? base64Chars.indexOf(base64[i + 3]) : 0;

      if (c1 == -1 || c2 == -1 || c3 == -1 || c4 == -1) {
        throw Exception('Invalid base64 character');
      }

      final b1 = (c1 << 2) | (c2 >> 4);
      final b2 = ((c2 & 15) << 4) | (c3 >> 2);
      final b3 = ((c3 & 3) << 6) | c4;

      result.add(b1);
      if (i + 2 < base64.length) result.add(b2);
      if (i + 3 < base64.length) result.add(b3);
    }

    return Uint8List.fromList(result);
  }

  /// Get accepted file formats for file input
  static String _getAcceptedFormats(List<String> formats) {
    return formats.map((format) => 'image/$format').join(',');
  }

  /// Get file extension from filename
  static String _getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  /// Validate image file
  static bool isValidImageFile(html.File file) {
    // Check file type
    if (!file.type.startsWith('image/')) {
      return false;
    }

    // Check file size
    if (file.size > AppConstants.maxImageSizeBytes) {
      return false;
    }

    // Check file extension
    final extension = _getFileExtension(file.name);
    if (!AppConstants.allowedImageFormats.contains(extension.toLowerCase())) {
      return false;
    }

    return true;
  }
}
