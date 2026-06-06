import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error_utils.dart';
import '../../../core/constants.dart';
import '../../../models/user_model.dart';
import '../../notifications/services/notification_service.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final FirebaseFirestore? _firestore;

  AuthCubit({AuthService? authService, FirebaseFirestore? firestore})
      : _authService = authService ?? AuthService(),
        _firestore = firestore,
        super(const AuthInitial()) {
    _checkAuthState();
  }

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  void _checkAuthState() {
    final user = _authService.currentUser();
    if (user != null) {
      emit(AuthVerified(user: user));
      _saveFcmToken(user.id);
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    try {
      await _authService.signInWithEmail(email, password);
      final user = _authService.currentUser();
      if (user != null) {
        await _ensureUserDoc(user);
        emit(AuthVerified(user: user));
      } else {
        emit(const AuthError(message: 'حدث خطأ، حاول مرة أخرى'));
      }
    } catch (e) {
      emit(AuthError(message: _errorMessage(e)));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.createAccount(email, password);
      await _authService.updateDisplayName(name);

      final firebaseUser = credential.user!;
      final user = UserModel(
        id: firebaseUser.uid,
        phone: '',
        email: email,
        name: name,
      );

      await _db
          .collection(AppConstants.firebaseCollectionUsers)
          .doc(firebaseUser.uid)
          .set(user.toMap());

      await _saveFcmToken(firebaseUser.uid);
      emit(AuthVerified(user: user));
    } catch (e) {
      emit(AuthError(message: _errorMessage(e)));
    }
  }

  Future<void> _ensureUserDoc(UserModel user) async {
    try {
      final doc = await _db
          .collection(AppConstants.firebaseCollectionUsers)
          .doc(user.id)
          .get();
      if (!doc.exists) {
        await _db
            .collection(AppConstants.firebaseCollectionUsers)
            .doc(user.id)
            .set(user.toMap());
      }
    } catch (e, s) {
      logError(e, s, context: 'AuthCubit._ensureUserDoc');
    }
  }

  Future<void> signOut() async {
    try {
      final user = _authService.currentUser();
      if (user != null) {
        await NotificationService().deleteTokenFromFirestore(user.id);
      }
      await _authService.signOut();
    } catch (e, s) {
      logError(e, s, context: 'AuthCubit.signOut');
    }
    emit(const AuthInitial());
  }

  Future<void> _saveFcmToken(String userId) async {
    try {
      await NotificationService().saveTokenToFirestore(userId);
    } catch (e, s) {
      logError(e, s, context: 'AuthCubit._saveFcmToken');
    }
  }

  void reset() => emit(const AuthInitial());

  String _errorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found')) return 'لا يوجد حساب بهذا البريد الإلكتروني';
    if (msg.contains('wrong-password')) return 'كلمة المرور غير صحيحة';
    if (msg.contains('invalid-credential')) return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    if (msg.contains('invalid-email')) return 'البريد الإلكتروني غير صحيح';
    if (msg.contains('email-already-in-use')) return 'البريد الإلكتروني مستخدم بالفعل';
    if (msg.contains('weak-password')) return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
    if (msg.contains('user-disabled')) return 'تم تعطيل هذا الحساب';
    if (msg.contains('too-many-requests')) return 'حاول مرة أخرى بعد قليل';
    if (msg.contains('network-request-failed')) return 'مشكلة في الاتصال، حاول مرة أخرى';
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
