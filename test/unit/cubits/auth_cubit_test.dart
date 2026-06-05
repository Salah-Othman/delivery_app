import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/auth/cubit/auth_state.dart';
import 'package:app_delivery/features/auth/services/auth_service.dart';
import 'package:app_delivery/models/user_model.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;
  late AuthCubit cubit;

  setUp(() {
    mockAuthService = MockAuthService();
    when(() => mockAuthService.currentUser()).thenReturn(null);
    cubit = AuthCubit(authService: mockAuthService);
  });

  tearDown(() {
    cubit.close();
  });

  group('initial state', () {
    test('starts as AuthInitial when no user logged in', () {
      expect(cubit.state, const AuthInitial());
    });

    test('emits AuthVerified when user already logged in', () {
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'u1', phone: '0100', name: 'أحمد'),
      );

      final cubit2 = AuthCubit(authService: mockAuthService);
      expect(cubit2.state, isA<AuthVerified>());
      cubit2.close();
    });
  });

  group('signInWithPhone', () {
    test('emits AuthCodeSent on success', () async {
      when(() => mockAuthService.sendOtp('+20100')).thenAnswer(
        (_) async => 'verification_id_123',
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signInWithPhone('+20100');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthCodeSent]);
    });

    test('emits AuthError on failure', () async {
      when(() => mockAuthService.sendOtp('+20100')).thenThrow(
        Exception('invalid-phone-number'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signInWithPhone('+20100');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthError]);
    });
  });

  group('verifyOtp', () {
    test('emits AuthVerified on success', () async {
      when(() => mockAuthService.verifyOtp('123456')).thenAnswer(
        (_) async => MockUserCredential(),
      );
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'u1', phone: '0100'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.verifyOtp('123456');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthVerified]);
    });

    test('emits AuthError on failure', () async {
      when(() => mockAuthService.verifyOtp('000000')).thenThrow(
        Exception('invalid-verification-code'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.verifyOtp('000000');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthError]);
    });
  });

  group('signInWithGoogle', () {
    test('emits AuthVerified on success', () async {
      when(() => mockAuthService.signInWithGoogle()).thenAnswer(
        (_) async => MockUserCredential(),
      );
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'u1', phone: '', email: 'test@gmail.com'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signInWithGoogle();
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthVerified]);
    });

    test('emits AuthInitial when user cancels', () async {
      when(() => mockAuthService.signInWithGoogle()).thenThrow(
        Exception('user-cancelled'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signInWithGoogle();
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthInitial]);
    });

    test('emits AuthError on failure', () async {
      when(() => mockAuthService.signInWithGoogle()).thenThrow(
        Exception('network-request-failed'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signInWithGoogle();
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthError]);
    });
  });

  group('signOut', () {
    test('emits AuthInitial on success', () async {
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signOut();
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthInitial]);
    });
  });

  group('reset', () {
    test('emits AuthInitial', () async {
      cubit.signInWithPhone('+20100');
      await Future.delayed(Duration.zero);

      cubit.reset();
      expect(cubit.state, const AuthInitial());
    });
  });
}
