import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Get current signed-in user ─────────────────────────────────────
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final name = doc.data()?['name'] as String? ??
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'User';

      // Cache locally for offline use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserId, firebaseUser.uid);
      await prefs.setString(AppConstants.keyUserEmail, firebaseUser.email ?? '');
      await prefs.setString(AppConstants.keyUserName, name);

      return AppUser(
        id: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? '',
      );
    } catch (_) {
      // Fallback to local cache if Firestore unreachable
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(AppConstants.keyUserId);
      final email = prefs.getString(AppConstants.keyUserEmail);
      final name = prefs.getString(AppConstants.keyUserName);
      if (userId == null || email == null) return null;
      return AppUser(id: userId, name: name ?? 'User', email: email);
    }
  }

  // ── Login with email + password (Firebase Auth) ────────────────────
  Future<AppUser> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user!;

    // Fetch profile from Firestore
    String name = email.split('@').first;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        name = doc.data()?['name'] as String? ?? name;
      }
    } catch (_) {}

    // Cache locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, firebaseUser.uid);
    await prefs.setString(AppConstants.keyUserEmail, email.trim());
    await prefs.setString(AppConstants.keyUserName, name);

    return AppUser(
      id: firebaseUser.uid,
      name: name,
      email: email.trim(),
    );
  }

  // ── Register new account (Firebase Auth + Firestore profile) ──────
  Future<AppUser> register(String name, String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user!;

    // Update Firebase display name
    await firebaseUser.updateDisplayName(name.trim());

    // Save user profile to Firestore
    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'uid': firebaseUser.uid,
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Cache locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserId, firebaseUser.uid);
    await prefs.setString(AppConstants.keyUserEmail, email.trim());
    await prefs.setString(AppConstants.keyUserName, name.trim());

    return AppUser(
      id: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────
  Future<void> logout() async {
    await _firebaseAuth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserName);
  }

  // ── Auth state stream (for auto-login on app restart) ─────────────
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ── Password reset ─────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }
}
