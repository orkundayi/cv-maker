import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/user.dart';

/// Custom exception for auth errors with error code for localization
class AuthException implements Exception {
  final String code;
  final String? message;

  const AuthException(this.code, {this.message});

  @override
  String toString() => message ?? code;
}

/// Service for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign up with email and password
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('account-creation-failed');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
      }

      // Create user document in Firestore
      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _createUserDocument(appUser);

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('login-failed');
      }

      // Update last login time
      await _updateLastLogin(credential.user!.uid);

      return AppUser.fromFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      // Delete user document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete all user's CVs
      final cvs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cvs')
          .get();

      for (final cv in cvs.docs) {
        await cv.reference.delete();
      }

      // Delete Firebase Auth user
      await user.delete();
    }
  }

  /// Get user profile from Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return AppUser.fromJson(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  /// Update last login time
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    });
  }

  /// Handle Firebase Auth exceptions - returns error code for localization
  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException('email-already-in-use');
      case 'invalid-email':
        return const AuthException('invalid-email');
      case 'operation-not-allowed':
        return const AuthException('operation-not-allowed');
      case 'weak-password':
        return const AuthException('weak-password');
      case 'user-disabled':
        return const AuthException('user-disabled');
      case 'user-not-found':
        return const AuthException('user-not-found');
      case 'wrong-password':
        return const AuthException('wrong-password');
      case 'too-many-requests':
        return const AuthException('too-many-requests');
      case 'invalid-credential':
        return const AuthException('invalid-credential');
      default:
        return AuthException('generic', message: e.message);
    }
  }
}
