import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

import '../../domain/cv_data.dart';

/// Service for storing and retrieving CV data
class CVStorageService {
  static const String _storageKey = 'cv_maker_data';
  static const String _backupKey = 'cv_maker_backup';

  /// Save CV data to local storage
  static Future<void> saveCVData(CVData cvData) async {
    try {
      final jsonString = jsonEncode(cvData.toJson());
      html.window.localStorage[_storageKey] = jsonString;

      // Create backup
      await _createBackup(cvData);
    } catch (e) {
      throw Exception('Failed to save CV data: $e');
    }
  }

  /// Load CV data from local storage
  static Future<CVData?> loadCVData() async {
    try {
      final jsonString = html.window.localStorage[_storageKey];
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CVData.fromJson(json);
    } catch (e) {
      // Try to load from backup if main data is corrupted
      return _loadFromBackup();
    }
  }

  /// Clear all stored CV data
  static Future<void> clearCVData() async {
    try {
      html.window.localStorage.remove(_storageKey);
      html.window.localStorage.remove(_backupKey);
    } catch (e) {
      throw Exception('Failed to clear CV data: $e');
    }
  }

  /// Export CV data as file
  static Future<void> exportCVData(CVData cvData, String filename) async {
    try {
      final jsonString = jsonEncode(cvData.toJson());
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception('Failed to export CV data: $e');
    }
  }

  /// Import CV data from file
  static Future<CVData> importCVData(html.File file) async {
    try {
      final reader = html.FileReader();

      final completer = _FileReaderCompleter<CVData>();

      reader.onLoad.listen((event) {
        try {
          final jsonString = reader.result as String;
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final cvData = CVData.fromJson(json);
          completer.complete(cvData);
        } catch (e) {
          completer.completeError(Exception('Invalid CV data format: $e'));
        }
      });

      reader.onError.listen((event) {
        completer.completeError(Exception('Failed to read file: $event'));
      });

      reader.readAsText(file);

      return await completer.future;
    } catch (e) {
      throw Exception('Failed to import CV data: $e');
    }
  }

  /// Check if CV data exists
  static bool hasCVData() {
    try {
      final jsonString = html.window.localStorage[_storageKey];
      return jsonString != null && jsonString.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get last modified date
  static DateTime? getLastModified() {
    try {
      final jsonString = html.window.localStorage[_storageKey];
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final updatedAt = json['updatedAt'] as String?;
      return updatedAt != null ? DateTime.parse(updatedAt) : null;
    } catch (e) {
      return null;
    }
  }

  /// Create backup of CV data
  static Future<void> _createBackup(CVData cvData) async {
    try {
      final jsonString = jsonEncode(cvData.toJson());
      html.window.localStorage[_backupKey] = jsonString;
    } catch (e) {
      // Backup creation failed, but don't throw error
      if (kDebugMode) {
        print('Failed to create backup: $e');
      }
    }
  }

  /// Load CV data from backup
  static Future<CVData?> _loadFromBackup() async {
    try {
      final jsonString = html.window.localStorage[_backupKey];
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CVData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Get storage statistics
  static Map<String, dynamic> getStorageStats() {
    try {
      final mainData = html.window.localStorage[_storageKey];
      final backupData = html.window.localStorage[_backupKey];

      return {
        'mainDataSize': mainData?.length ?? 0,
        'backupDataSize': backupData?.length ?? 0,
        'hasMainData': mainData != null && mainData.isNotEmpty,
        'hasBackupData': backupData != null && backupData.isNotEmpty,
        'lastModified': getLastModified()?.toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

/// Simple completer for file reading operations
class _FileReaderCompleter<T> {
  T? _result;
  Object? _error;
  bool _isCompleted = false;
  final List<Function()> _listeners = [];

  Future<T> get future {
    if (_isCompleted) {
      if (_error != null) {
        throw _error!;
      }
      return Future.value(_result as T);
    }

    return Future(() {
      if (_error != null) {
        throw _error!;
      }
      return _result as T;
    });
  }

  void complete(T value) {
    if (!_isCompleted) {
      _result = value;
      _isCompleted = true;
      _notifyListeners();
    }
  }

  void completeError(Object error) {
    if (!_isCompleted) {
      _error = error;
      _isCompleted = true;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
