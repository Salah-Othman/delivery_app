import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_delivery/providers/cubit/provider_auth_cubit.dart';
import 'package:app_delivery/providers/cubit/provider_auth_state.dart';
import 'package:app_delivery/models/user_model.dart';
import 'package:app_delivery/models/provider_model.dart';
import '../../helpers/mocks.dart';

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;
  late MockProviderService mockProviderService;
  late MockNotificationService mockNotificationService;
  late ProviderAuthCubit cubit;

  setUp(() {
    mockAuthService = MockAuthService();
    mockProviderService = MockProviderService();
    mockNotificationService = MockNotificationService();
    when(() => mockAuthService.currentUser()).thenReturn(null);
    when(() => mockNotificationService.saveTokenToFirestore(any()))
        .thenAnswer((_) async {});
    when(() => mockNotificationService.deleteTokenFromFirestore(any()))
        .thenAnswer((_) async {});
    cubit = ProviderAuthCubit(
      authService: mockAuthService,
      providerService: mockProviderService,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('initial state', () {
    test('starts as ProviderAuthInitial when no user logged in', () {
      expect(cubit.state, const ProviderAuthInitial());
    });

    test('emits ProviderAuthVerified when provider already logged in', () async {
      final provider = ProviderModel(id: 'p1', email: 'ahmed@test.com', name: 'أحمد', phone: '0100');
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'p1', phone: '0100', email: 'ahmed@test.com', name: 'أحمد'),
      );
      when(() => mockProviderService.getProvider('p1'))
          .thenAnswer((_) async => provider);

      final cubit2 = ProviderAuthCubit(
        authService: mockAuthService,
        providerService: mockProviderService,
        notificationService: mockNotificationService,
      );
      await Future.delayed(Duration.zero);

      expect(cubit2.state, isA<ProviderAuthVerified>());
      cubit2.close();
    });
  });

  group('signIn', () {
    test('emits ProviderAuthVerified on success', () async {
      when(() => mockAuthService.signInWithEmail('ahmed@test.com', 'pass'))
          .thenAnswer((_) async => MockUserCredential());
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'p1', phone: '', email: 'ahmed@test.com', name: 'أحمد'),
      );
      final provider = ProviderModel(id: 'p1', email: 'ahmed@test.com', name: 'أحمد', phone: '0100');
      when(() => mockProviderService.getProvider('p1'))
          .thenAnswer((_) async => provider);

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signIn('ahmed@test.com', 'pass');
      await Future.delayed(Duration.zero);

      expect(emitted, [ProviderAuthLoading, ProviderAuthVerified]);
    });

    test('emits ProviderUnregistered when provider not found', () async {
      when(() => mockAuthService.signInWithEmail('unknown@test.com', 'pass'))
          .thenAnswer((_) async => MockUserCredential());
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'unknown', phone: '', email: 'unknown@test.com', name: ''),
      );
      when(() => mockProviderService.getProvider('unknown'))
          .thenAnswer((_) async => null);
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signIn('unknown@test.com', 'pass');
      await Future.delayed(Duration.zero);

      expect(emitted, [ProviderAuthLoading, ProviderUnregistered]);
    });

    test('emits ProviderAuthError on wrong password', () async {
      when(() => mockAuthService.signInWithEmail('ahmed@test.com', 'wrong'))
          .thenThrow(Exception('wrong-password'));

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signIn('ahmed@test.com', 'wrong');
      await Future.delayed(Duration.zero);

      expect(emitted, [ProviderAuthLoading, ProviderAuthError]);
    });
  });

  group('signOut', () {
    test('emits ProviderAuthInitial on success', () async {
      when(() => mockAuthService.currentUser()).thenReturn(null);
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signOut();
      await Future.delayed(Duration.zero);

      expect(emitted, [ProviderAuthInitial]);
    });
  });

  group('reset', () {
    test('emits ProviderAuthInitial', () {
      cubit.reset();
      expect(cubit.state, const ProviderAuthInitial());
    });
  });
}
