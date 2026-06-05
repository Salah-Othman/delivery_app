import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    _checkAuthState();
  }

  void _checkAuthState() {
    final user = _authService.currentUser();
    if (user != null) {
      emit(AuthVerified(user: user));
    }
  }

  Future<void> signInWithPhone(String phone) async {
    emit(const AuthLoading());
    try {
      final verificationId = await _authService.sendOtp(phone);
      emit(AuthCodeSent(
        verificationId: verificationId,
        phone: phone,
      ));
    } catch (e) {
      emit(AuthError(message: _errorMessage(e)));
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    emit(const AuthLoading());
    try {
      await _authService.verifyOtp(smsCode);
      final user = _authService.currentUser();
      if (user != null) {
        emit(AuthVerified(user: user));
      } else {
        emit(const AuthError(message: 'حدث خطأ، حاول مرة أخرى'));
      }
    } catch (e) {
      emit(AuthError(message: _errorMessage(e)));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      await _authService.signInWithGoogle();
      final user = _authService.currentUser();
      if (user != null) {
        emit(AuthVerified(user: user));
      } else {
        emit(const AuthError(message: 'حدث خطأ، حاول مرة أخرى'));
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('user-cancelled') || msg.contains('CANCELED')) {
        emit(const AuthInitial());
      } else {
        emit(AuthError(message: _errorMessage(e)));
      }
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AuthInitial());
  }

  void reset() => emit(const AuthInitial());

  String _errorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('invalid-phone-number')) return 'رقم الهاتف غير صحيح';
    if (msg.contains('too-many-requests')) return 'حاول مرة أخرى بعد قليل';
    if (msg.contains('invalid-verification-code')) return 'رمز التحقق غير صحيح';
    if (msg.contains('network-request-failed')) return 'مشكلة في الاتصال، حاول مرة أخرى';
    if (msg.contains('account-exists-with-different-credential')) {
      return 'هذا الحساب مرتبط بطريقة تسجيل دخول أخرى';
    }
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
