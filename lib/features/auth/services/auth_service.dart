import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
<<<<<<< HEAD
  GoogleSignIn get _googleSignIn => GoogleSignIn();
=======
>>>>>>> bbc6f8fa6ca2b08fd8d4f51b35938d2a6ba1a1ee

  String? _verificationId;

  String? get verificationId => _verificationId;

  UserModel? currentUser() {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        phone: user.phoneNumber ?? '',
<<<<<<< HEAD
        email: user.email,
=======
>>>>>>> bbc6f8fa6ca2b08fd8d4f51b35938d2a6ba1a1ee
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
<<<<<<< HEAD
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('user-cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
=======
  }

  Future<void> signOut() async {
    await _auth.signOut();
>>>>>>> bbc6f8fa6ca2b08fd8d4f51b35938d2a6ba1a1ee
  }
}
