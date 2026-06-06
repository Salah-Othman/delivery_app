import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_delivery/core/app_exception.dart';

void main() {
  group('AppException', () {
    test('creates with user message', () {
      final exc = AppException(userMessage: 'حدث خطأ');

      expect(exc.userMessage, 'حدث خطأ');
      expect(exc.toString(), 'حدث خطأ');
    });

    test('stores original error and stack trace', () {
      final original = Exception('original');
      final stack = StackTrace.current;
      final exc = AppException(
        userMessage: 'خطأ',
        originalError: original,
        stackTrace: stack,
      );

      expect(exc.originalError, original);
      expect(exc.stackTrace, stack);
    });
  });

  group('firestoreErrorMessage', () {
    test('returns permission-denied message', () {
      final e = FirebaseException(plugin: 'firestore', code: 'permission-denied');
      expect(firestoreErrorMessage(e), 'ليس لديك صلاحية للقيام بهذا الإجراء');
    });

    test('returns not-found message', () {
      final e = FirebaseException(plugin: 'firestore', code: 'not-found');
      expect(firestoreErrorMessage(e), 'لم يتم العثور على البيانات المطلوبة');
    });

    test('returns already-exists message', () {
      final e = FirebaseException(plugin: 'firestore', code: 'already-exists');
      expect(firestoreErrorMessage(e), 'البيانات موجودة بالفعل');
    });

    test('returns unavailable message', () {
      final e = FirebaseException(plugin: 'firestore', code: 'unavailable');
      expect(firestoreErrorMessage(e), 'خدمة قاعدة البيانات غير متاحة حالياً، حاول مرة أخرى');
    });

    test('returns default message for unknown code', () {
      final e = FirebaseException(plugin: 'firestore', code: 'unknown');
      expect(firestoreErrorMessage(e), 'حدث خطأ في قاعدة البيانات');
    });

    test('handles FirebaseAuthException network error', () {
      final e = FirebaseAuthException(code: 'network-request-failed');
      expect(firestoreErrorMessage(e), 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
    });

    test('handles FirebaseAuthException invalid phone', () {
      final e = FirebaseAuthException(code: 'invalid-phone-number');
      expect(firestoreErrorMessage(e), 'رقم الهاتف غير صحيح');
    });

    test('handles FirebaseAuthException invalid code', () {
      final e = FirebaseAuthException(code: 'invalid-verification-code');
      expect(firestoreErrorMessage(e), 'رمز التحقق غير صحيح');
    });

    test('handles FirebaseAuthException expired session', () {
      final e = FirebaseAuthException(code: 'session-expired');
      expect(firestoreErrorMessage(e), 'انتهت صلاحية الجلسة، أعد إرسال رمز التحقق');
    });

    test('handles FirebaseAuthException too many requests', () {
      final e = FirebaseAuthException(code: 'too-many-requests');
      expect(firestoreErrorMessage(e), 'طلبات كثيرة جداً، حاول بعد قليل');
    });

    test('handles FirebaseAuthException default', () {
      final e = FirebaseAuthException(code: 'unknown');
      expect(firestoreErrorMessage(e), 'حدث خطأ في تسجيل الدخول');
    });

    test('handles network-related string errors', () {
      expect(firestoreErrorMessage(Exception('network-request-failed')),
          'تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      expect(firestoreErrorMessage(Exception('SocketException')),
          'تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      expect(firestoreErrorMessage(Exception('HandshakeException')),
          'تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
    });

    test('handles permission-denied string', () {
      expect(firestoreErrorMessage(Exception('permission-denied')),
          'ليس لديك صلاحية للقيام بهذا الإجراء');
    });

    test('returns default for unknown error', () {
      expect(firestoreErrorMessage(Exception('something else')),
          'حدث خطأ غير متوقع، حاول مرة أخرى');
    });
  });
}
