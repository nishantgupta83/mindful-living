import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

/// Firebase Authentication Service
///
/// Provides secure authentication with multiple providers:
/// - Email/Password
/// - Google Sign-In
/// - Apple Sign-In
/// - Anonymous (Guest Mode)
///
/// Implements PII-compliant data handling and GDPR/CCPA requirements.
class AuthService extends ChangeNotifier {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser ?? _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isAnonymous => currentUser?.isAnonymous ?? false;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Initialize auth service and listen to auth state
  Future<void> initialize() async {
    _currentUser = _auth.currentUser;

    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();

      if (user != null) {
        _updateUserDocument(user);
      }
    });
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _updateUserDocument(credential.user!);
      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Create new account with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
      }

      // Send verification email
      await credential.user!.sendEmailVerification();

      await _createUserDocument(
        credential.user!,
        authProvider: 'email',
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      // User cancelled the sign-in
      if (googleUser == null) {
        _setError('Google sign-in cancelled');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Create/update user document
      await _createUserDocument(
        userCredential.user!,
        authProvider: 'google',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      _setError('Google sign-in failed: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple (iOS 13+ and macOS 10.15+ only)
  Future<UserCredential?> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      // Check if Apple Sign-In is available (iOS 13+)
      if (!kIsWeb && Platform.isIOS) {
        if (!(await SignInWithApple.isAvailable())) {
          _setError('Apple Sign-In not available on this device (requires iOS 13+)');
          return null;
        }
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Apple may not provide email if user chooses to hide it
      // Full name is only provided on first sign-in
      String? fullName;
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        fullName = '${appleCredential.givenName} ${appleCredential.familyName}';
      }

      // Create/update user document
      await _createUserDocument(
        userCredential.user!,
        authProvider: 'apple',
        fullName: fullName,
      );

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          _setError('Apple Sign-In cancelled');
          break;
        case AuthorizationErrorCode.failed:
          _setError('Apple Sign-In failed');
          break;
        case AuthorizationErrorCode.invalidResponse:
          _setError('Invalid response from Apple');
          break;
        case AuthorizationErrorCode.notHandled:
          _setError('Apple Sign-In not handled');
          break;
        case AuthorizationErrorCode.notInteractive:
          _setError('Apple Sign-In not available in non-interactive mode');
          break;
        case AuthorizationErrorCode.unknown:
          _setError('Unknown error during Apple Sign-In');
          break;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } catch (e) {
      _setError('Apple sign-in failed: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in anonymously (Guest mode)
  Future<UserCredential?> signInAnonymously() async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.signInAnonymously();

      await _createUserDocument(
        credential.user!,
        authProvider: 'anonymous',
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Convert anonymous account to permanent account
  Future<UserCredential?> convertAnonymousAccount({
    required String email,
    required String password,
  }) async {
    try {
      if (!isAnonymous) {
        _setError('Current user is not anonymous');
        return null;
      }

      _setLoading(true);
      _clearError();

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      final userCredential =
          await currentUser!.linkWithCredential(credential);

      await _updateUserDocument(
        userCredential.user!,
        authProvider: 'email',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile (display name, photo URL)
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) {
        _setError('No user logged in');
        return false;
      }

      _setLoading(true);
      _clearError();

      if (displayName != null) {
        await currentUser!.updateDisplayName(displayName.trim());
      }

      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      await _updateUserDocument(currentUser!);
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (currentUser == null || currentUser!.email == null) {
        _setError('No email user logged in');
        return false;
      }

      _setLoading(true);
      _clearError();

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await currentUser!.updatePassword(newPassword);

      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account (GDPR Right to Erasure)
  Future<bool> deleteAccount() async {
    try {
      if (currentUser == null) {
        _setError('No user logged in');
        return false;
      }

      _setLoading(true);
      _clearError();

      final userId = currentUser!.uid;

      // Delete user document and subcollections
      await _deleteUserData(userId);

      // Delete Firebase Auth account
      await currentUser!.delete();

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _setError(
          'Please log in again before deleting your account for security reasons.',
        );
      } else {
        _handleAuthException(e);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Export user data (GDPR Right to Access)
  Future<Map<String, dynamic>?> exportUserData() async {
    try {
      if (currentUser == null) {
        _setError('No user logged in');
        return null;
      }

      final userId = currentUser!.uid;

      // Get user document
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      // Get journal entries
      final journalDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .get();

      // Get favorites
      final favoritesDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': userId,
        'profile': userDoc.data(),
        'journal_entries': journalDocs.docs.map((d) => d.data()).toList(),
        'favorites': favoritesDocs.docs.map((d) => d.data()).toList(),
      };
    } catch (e) {
      _setError('Data export failed: ${e.toString()}');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google if user signed in with Google
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        // Ignore Google sign-out errors (user might not have signed in with Google)
        if (kDebugMode) {
          print('Google sign-out error (can be ignored): $e');
        }
      }
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ========== PRIVATE HELPERS ==========

  /// Create user document in Firestore (first time)
  Future<void> _createUserDocument(
    User user, {
    required String authProvider,
    String? fullName,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    // Check if document already exists
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      await _updateUserDocument(user, authProvider: authProvider);
      return;
    }

    // Create new document
    await userDoc.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': fullName ?? user.displayName ?? 'Anonymous User',
      'photoURL': user.photoURL,
      'authProvider': authProvider,
      'isAnonymous': user.isAnonymous,
      'emailVerified': user.emailVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'settings': {
        'analyticsEnabled': false, // GDPR: Opt-in required
        'personalizationEnabled': true,
        'notificationsEnabled': false,
      },
    });
  }

  /// Update user document in Firestore
  Future<void> _updateUserDocument(
    User user, {
    String? authProvider,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final updateData = {
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    if (authProvider != null) {
      updateData['authProvider'] = authProvider;
    }

    await userDoc.set(
      updateData,
      SetOptions(merge: true),
    );
  }

  /// Delete all user data (GDPR compliance)
  Future<void> _deleteUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete journal entries
    final journalDocs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('journal_entries')
        .get();

    for (var doc in journalDocs.docs) {
      batch.delete(doc.reference);
    }

    // Delete favorites
    final favoritesDocs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    for (var doc in favoritesDocs.docs) {
      batch.delete(doc.reference);
    }

    // Delete user document
    batch.delete(_firestore.collection('users').doc(userId));

    await batch.commit();
  }

  /// Handle Firebase Auth exceptions
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _setError('No account found with this email');
        break;
      case 'wrong-password':
        _setError('Incorrect password');
        break;
      case 'email-already-in-use':
        _setError('An account already exists with this email');
        break;
      case 'weak-password':
        _setError('Password is too weak. Use at least 8 characters');
        break;
      case 'invalid-email':
        _setError('Invalid email address');
        break;
      case 'user-disabled':
        _setError('This account has been disabled');
        break;
      case 'too-many-requests':
        _setError('Too many failed attempts. Please try again later');
        break;
      case 'operation-not-allowed':
        _setError('This sign-in method is not enabled');
        break;
      case 'requires-recent-login':
        _setError('Please log in again to perform this action');
        break;
      default:
        _setError(e.message ?? 'Authentication failed');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
