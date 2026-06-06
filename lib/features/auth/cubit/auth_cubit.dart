import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/app_exception.dart';
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
    } catch (e, s) {
      logError(e, s, context: 'AuthCubit.signIn');
      emit(AuthError(message: firestoreErrorMessage(e)));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    emit(const AuthLoading());
    try {
      final credential = await _authService.createAccount(email, password);
      await _authService.updateDisplayName(name);

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(const AuthError(message: 'حدث خطأ في إنشاء الحساب'));
        return;
      }

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
    } catch (e, s) {
      logError(e, s, context: 'AuthCubit.signUp');
      emit(AuthError(message: firestoreErrorMessage(e)));
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
}
