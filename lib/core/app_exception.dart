import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  final String userMessage;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.userMessage,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => userMessage;
}

String firestoreErrorMessage(Object e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للقيام بهذا الإجراء';
      case 'not-found':
        return 'لم يتم العثور على البيانات المطلوبة';
      case 'already-exists':
        return 'البيانات موجودة بالفعل';
      case 'unavailable':
        return 'خدمة قاعدة البيانات غير متاحة حالياً، حاول مرة أخرى';
      case 'deadline-exceeded':
        return 'انتهت مهلة الاتصال، تحقق من اتصالك بالإنترنت';
      case 'cancelled':
        return 'تم إلغاء العملية';
      case 'aborted':
        return 'تم إحباط العملية بسبب تعارض';
      case 'out-of-range':
        return 'القيمة خارج النطاق المسموح';
      default:
        return 'حدث خطأ في قاعدة البيانات';
    }
  }
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت صلاحية الجلسة، أعد إرسال رمز التحقق';
      case 'too-many-requests':
        return 'طلبات كثيرة جداً، حاول بعد قليل';
      default:
        return 'حدث خطأ في تسجيل الدخول';
    }
  }
  final msg = e.toString();
  if (msg.contains('network-request-failed') ||
      msg.contains('SocketException') ||
      msg.contains('HandshakeException')) {
    return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
  }
  if (msg.contains('permission-denied')) {
    return 'ليس لديك صلاحية للقيام بهذا الإجراء';
  }
  return 'حدث خطأ غير متوقع، حاول مرة أخرى';
}
