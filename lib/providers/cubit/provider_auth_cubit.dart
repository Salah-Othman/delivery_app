import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_exception.dart';
import '../../core/error_utils.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/notifications/services/notification_service.dart';
import '../services/provider_service.dart';
import 'provider_auth_state.dart';

class ProviderAuthCubit extends Cubit<ProviderAuthState> {
  final AuthService _authService;
  final ProviderService _providerService;
  final NotificationService _notificationService;

  ProviderAuthCubit({
    AuthService? authService,
    ProviderService? providerService,
    NotificationService? notificationService,
  })  : _authService = authService ?? AuthService(),
        _providerService = providerService ?? ProviderService(),
        _notificationService = notificationService ?? NotificationService(),
        super(const ProviderAuthInitial()) {
    _checkAuthState();
  }

  void _checkAuthState() {
    final user = _authService.currentUser();
    if (user != null) {
      _resolveProvider(user.id);
    }
  }

  Future<void> _resolveProvider(String uid) async {
    try {
      final provider = await _providerService.getProvider(uid);
      if (provider != null) {
        emit(ProviderAuthVerified(provider: provider));
      } else {
        emit(const ProviderAuthInitial());
      }
    } catch (e, s) {
      logError(e, s, context: 'ProviderAuthCubit._resolveProvider');
      emit(const ProviderAuthInitial());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const ProviderAuthLoading());
    try {
      await _authService.signInWithEmail(email, password);
      final user = _authService.currentUser();
      if (user == null) {
        emit(const ProviderAuthError(message: 'حدث خطأ، حاول مرة أخرى'));
        return;
      }

      final provider = await _providerService.getProvider(user.id);
      if (provider == null) {
        await _authService.signOut();
        emit(const ProviderUnregistered());
        return;
      }

      await _notificationService.saveTokenToFirestore(user.id);
      emit(ProviderAuthVerified(provider: provider));
    } catch (e, s) {
      logError(e, s, context: 'ProviderAuthCubit.signIn');
      emit(ProviderAuthError(message: firestoreErrorMessage(e)));
    }
  }

  Future<void> signOut() async {
    try {
      final user = _authService.currentUser();
      if (user != null) {
        await _notificationService.deleteTokenFromFirestore(user.id);
        await _providerService.updateAvailability(user.id, false);
      }
      await _authService.signOut();
    } catch (e, s) {
      logError(e, s, context: 'ProviderAuthCubit.signOut');
    }
    emit(const ProviderAuthInitial());
  }

  void reset() => emit(const ProviderAuthInitial());
}
