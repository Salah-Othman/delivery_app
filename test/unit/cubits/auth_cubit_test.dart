import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/auth/cubit/auth_state.dart';
import 'package:app_delivery/features/auth/services/auth_service.dart';
import 'package:app_delivery/models/user_model.dart';
import '../../helpers/mocks.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late MockFirebaseFirestore mockFirestore;
  late AuthCubit cubit;

  setUp(() {
    mockAuthService = MockAuthService();
    mockFirestore = MockFirebaseFirestore();
    when(() => mockAuthService.currentUser()).thenReturn(null);
    final mockCollection = MockCollectionReference();
    final mockDoc = MockDocumentReference();
    final mockSnap = MockDocumentSnapshot();
    when(() => mockSnap.exists).thenReturn(true);
    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDoc);
    when(() => mockDoc.set(any())).thenAnswer((_) async {});
    when(() => mockDoc.get()).thenAnswer((_) async => mockSnap);
    cubit = AuthCubit(authService: mockAuthService, firestore: mockFirestore);
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
        UserModel(id: 'u1', phone: '0100', email: 'test@test.com', name: 'أحمد'),
      );

      final cubit2 = AuthCubit(authService: mockAuthService);
      expect(cubit2.state, isA<AuthVerified>());
      cubit2.close();
    });
  });

  group('signIn', () {
    test('emits AuthVerified on success', () async {
      when(() => mockAuthService.signInWithEmail('test@test.com', 'password123'))
          .thenAnswer((_) async => MockUserCredential());
      when(() => mockAuthService.currentUser()).thenReturn(
        UserModel(id: 'u1', phone: '', email: 'test@test.com', name: 'أحمد'),
      );

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signIn('test@test.com', 'password123');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthVerified]);
    });

    test('emits AuthError on wrong password', () async {
      when(() => mockAuthService.signInWithEmail('test@test.com', 'wrong'))
          .thenThrow(Exception('wrong-password'));

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signIn('test@test.com', 'wrong');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthError]);
    });

    test('emits AuthError when user not found', () async {
      when(() => mockAuthService.signInWithEmail('unknown@test.com', 'pass'))
          .thenThrow(Exception('user-not-found'));

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signIn('unknown@test.com', 'pass');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthError]);
    });
  });

  group('signUp', () {
    test('emits AuthVerified on success', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('new_u1');
      when(() => mockAuthService.createAccount('new@test.com', 'password123'))
          .thenAnswer((_) async {
        final cred = MockUserCredential();
        when(() => cred.user).thenReturn(mockUser);
        return cred;
      });
      when(() => mockAuthService.updateDisplayName('أحمد جديد'))
          .thenAnswer((_) async {});

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signUp('new@test.com', 'password123', 'أحمد جديد');
      await Future.delayed(Duration.zero);

      expect(emitted, [AuthLoading, AuthVerified]);
    });

    test('emits AuthError when email already in use', () async {
      when(() => mockAuthService.createAccount('used@test.com', 'pass'))
          .thenThrow(Exception('email-already-in-use'));

      final emitted = <Type>[];
      cubit.stream.listen((s) => emitted.add(s.runtimeType));

      cubit.signUp('used@test.com', 'pass', 'أحمد');
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
}
