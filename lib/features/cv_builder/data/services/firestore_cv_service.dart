import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/cv_data.dart';

/// CV Metadata for list display
class CVMetadata {
  final String id;
  final String title;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CVMetadata({
    required this.id,
    required this.title,
    this.firstName,
    this.lastName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CVMetadata.fromCVData(CVData cv) {
    return CVMetadata(
      id: cv.id,
      title: cv.personalInfo.fullName.isNotEmpty
          ? cv.personalInfo.fullName
          : 'Yeni CV',
      firstName: cv.personalInfo.firstName,
      lastName: cv.personalInfo.lastName,
      createdAt: cv.createdAt,
      updatedAt: cv.updatedAt,
    );
  }

  factory CVMetadata.fromJson(Map<String, dynamic> json, String id) {
    return CVMetadata(
      id: id,
      title: json['title'] as String? ?? 'Yeni CV',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Service for Firestore CV operations
class FirestoreCVService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get collection reference for user's CVs
  CollectionReference<Map<String, dynamic>> _getCVCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cvs');
  }

  /// Save CV data to Firestore
  Future<void> saveCVData(String userId, CVData cvData) async {
    try {
      final cvRef = _getCVCollection(userId).doc(cvData.id);

      await cvRef.set(cvData.toJson());
    } catch (e) {
      throw Exception('CV kaydedilemedi: $e');
    }
  }

  /// Load CV data from Firestore
  Future<CVData?> loadCVData(String userId, String cvId) async {
    try {
      final doc = await _getCVCollection(userId).doc(cvId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return CVData.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('CV yüklenemedi: $e');
    }
  }

  /// Get all CVs for a user (metadata only for performance)
  Future<List<CVMetadata>> getAllCVMetadata(String userId) async {
    try {
      final snapshot = await _getCVCollection(
        userId,
      ).orderBy('updatedAt', descending: true).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final personalInfo = data['personalInfo'] as Map<String, dynamic>?;

        return CVMetadata(
          id: doc.id,
          title: personalInfo != null
              ? '${personalInfo['firstName'] ?? ''} ${personalInfo['lastName'] ?? ''}'
                    .trim()
              : 'Yeni CV',
          firstName: personalInfo?['firstName'] as String?,
          lastName: personalInfo?['lastName'] as String?,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('CV\'ler yüklenemedi: $e');
    }
  }

  /// Get all CVs for a user (full data)
  Future<List<CVData>> getAllCVs(String userId) async {
    try {
      final snapshot = await _getCVCollection(
        userId,
      ).orderBy('updatedAt', descending: true).get();

      return snapshot.docs.map((doc) => CVData.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('CV\'ler yüklenemedi: $e');
    }
  }

  /// Delete CV from Firestore
  Future<void> deleteCVData(String userId, String cvId) async {
    try {
      await _getCVCollection(userId).doc(cvId).delete();
    } catch (e) {
      throw Exception('CV silinemedi: $e');
    }
  }

  /// Get CV count for a user
  Future<int> getCVCount(String userId) async {
    try {
      final snapshot = await _getCVCollection(userId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Create a new empty CV and return its ID
  Future<String> createNewCV(String userId) async {
    try {
      final newCV = CVData.empty();
      await saveCVData(userId, newCV);
      return newCV.id;
    } catch (e) {
      throw Exception('Yeni CV oluşturulamadı: $e');
    }
  }

  /// Duplicate an existing CV
  Future<String> duplicateCV(String userId, String cvId) async {
    try {
      final originalCV = await loadCVData(userId, cvId);

      if (originalCV == null) {
        throw Exception('Orijinal CV bulunamadı');
      }

      final duplicatedCV = CVData(
        personalInfo: originalCV.personalInfo,
        workExperiences: originalCV.workExperiences,
        educations: originalCV.educations,
        skills: originalCV.skills,
        languages: originalCV.languages,
        certificates: originalCV.certificates,
        projects: originalCV.projects,
        summary: originalCV.summary,
      );

      await saveCVData(userId, duplicatedCV);
      return duplicatedCV.id;
    } catch (e) {
      throw Exception('CV kopyalanamadı: $e');
    }
  }

  /// Listen to CV changes in real-time
  Stream<CVData?> watchCV(String userId, String cvId) {
    return _getCVCollection(userId).doc(cvId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return CVData.fromJson(doc.data()!);
    });
  }

  /// Listen to all CVs for a user
  Stream<List<CVMetadata>> watchAllCVs(String userId) {
    return _getCVCollection(
      userId,
    ).orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final personalInfo = data['personalInfo'] as Map<String, dynamic>?;

        return CVMetadata(
          id: doc.id,
          title: personalInfo != null
              ? '${personalInfo['firstName'] ?? ''} ${personalInfo['lastName'] ?? ''}'
                    .trim()
              : 'Yeni CV',
          firstName: personalInfo?['firstName'] as String?,
          lastName: personalInfo?['lastName'] as String?,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : DateTime.now(),
        );
      }).toList();
    });
  }
}
