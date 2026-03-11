import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Stream provider that listens to Firebase auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for the auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google (google_sign_in v7 API)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize Google Sign In singleton (must be called once)
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
      }

      // Authenticate the user — returns GoogleSignInAccount, throws on cancel/error
      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();

      // Get authentication tokens (contains idToken)
      final GoogleSignInAuthentication auth = account.authentication;

      // Create Firebase credential from the Google ID token
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint(
          '[Libro Auth] Google sign-in success: ${userCredential.user?.email}');
      return userCredential;
    } on GoogleSignInException catch (e) {
      debugPrint('[Libro Auth] Google sign-in exception: ${e.code} - ${e.description}');
      // User cancelled or sign-in failed
      return null;
    } catch (e) {
      debugPrint('[Libro Auth] Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
          '[Libro Auth] Email sign-in success: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('[Libro Auth] Email sign-in error: $e');
      rethrow;
    }
  }

  /// Create account with email and password
  Future<UserCredential> createAccountWithEmail(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
          '[Libro Auth] Account created: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('[Libro Auth] Account creation error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
    debugPrint('[Libro Auth] Signed out.');
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    debugPrint('[Libro Auth] Password reset email sent to $email');
  }
}
