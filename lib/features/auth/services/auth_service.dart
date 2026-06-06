import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error_utils.dart';
import '../../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  UserModel? currentUser() {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        phone: user.phoneNumber ?? '',
        email: user.email,
        name: user.displayName,
      );
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createAccount(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, s) {
      logError(e, s, context: 'AuthService.signOut');
      rethrow;
    }
  }
}
