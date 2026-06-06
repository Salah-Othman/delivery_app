import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_delivery/features/auth/services/auth_service.dart';
import 'package:app_delivery/models/user_model.dart';
import '../../helpers/mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('currentUser', () {
    test('returns UserModel when user is logged in', () {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('u1');
      when(() => mockUser.phoneNumber).thenReturn('0100');
      when(() => mockUser.email).thenReturn('test@test.com');
      when(() => mockUser.displayName).thenReturn('أحمد');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final result = authService.currentUser();

      expect(result, isNotNull);
      expect(result!.id, 'u1');
      expect(result.phone, '0100');
      expect(result.email, 'test@test.com');
      expect(result.name, 'أحمد');
    });

    test('returns null when no user is logged in', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = authService.currentUser();

      expect(result, isNull);
    });

    test('returns null when FirebaseAuth throws', () {
      when(() => mockAuth.currentUser).thenThrow(Exception('error'));

      final result = authService.currentUser();

      expect(result, isNull);
    });
  });

  group('signInWithEmail', () {
    test('calls signInWithEmailAndPassword', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
          email: 'test@test.com', password: 'pass'))
          .thenAnswer((_) async => MockUserCredential());

      await authService.signInWithEmail('test@test.com', 'pass');

      verify(() => mockAuth.signInWithEmailAndPassword(
          email: 'test@test.com', password: 'pass')).called(1);
    });
  });

  group('createAccount', () {
    test('calls createUserWithEmailAndPassword', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
          email: 'new@test.com', password: 'pass'))
          .thenAnswer((_) async => MockUserCredential());

      await authService.createAccount('new@test.com', 'pass');

      verify(() => mockAuth.createUserWithEmailAndPassword(
          email: 'new@test.com', password: 'pass')).called(1);
    });
  });

  group('updateDisplayName', () {
    test('updates display name when user is logged in', () async {
      final mockUser = MockUser();
      when(() => mockUser.updateDisplayName('أحمد')).thenAnswer((_) async {});
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      await authService.updateDisplayName('أحمد');

      verify(() => mockUser.updateDisplayName('أحمد')).called(1);
    });

    test('does nothing when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      await authService.updateDisplayName('أحمد');

      verify(() => mockAuth.currentUser).called(1);
    });
  });

  group('signOut', () {
    test('calls signOut on FirebaseAuth', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('rethrows on error', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('signout error'));

      expect(() => authService.signOut(), throwsException);
    });
  });

  group('authStateChanges', () {
    test('returns auth state stream', () {
      when(() => mockAuth.authStateChanges()).thenAnswer((_) => const Stream.empty());

      expect(authService.authStateChanges, isA<Stream<User?>>());
    });
  });
}
