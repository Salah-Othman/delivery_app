import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<ConfirmationResult> signInWithPhone(
    String phone,
    RecaptchaVerifier verifier,
  ) {
    return _auth.signInWithPhoneNumber(phone, verifier);
  }

  Future<UserCredential> verifyOtp({
    required ConfirmationResult confirmationResult,
    required String smsCode,
  }) {
    return confirmationResult.confirm(smsCode);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserModel? currentUserModel() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      phone: user.phoneNumber ?? '',
      name: user.displayName,
    );
  }
}
