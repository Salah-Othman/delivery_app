import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? _verificationId;

  String? get verificationId => _verificationId;

  UserModel? currentUser() {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        phone: user.phoneNumber ?? '',
        name: user.displayName,
      );
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> sendOtp(String phone) async {
    final completer = Completer<String>();
    String? storedVerificationId;

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        if (storedVerificationId != null) {
          completer.complete(storedVerificationId);
        }
      },
      verificationFailed: (e) {
        completer.completeError(e);
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        storedVerificationId = verificationId;
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  Future<UserCredential> verifyOtp(String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
