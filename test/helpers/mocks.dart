import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/auth/services/auth_service.dart';
import 'package:app_delivery/features/notifications/services/notification_service.dart';
import 'package:app_delivery/providers/cubit/provider_auth_cubit.dart';
import 'package:app_delivery/providers/services/provider_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockProviderService extends Mock implements ProviderService {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

MockFirebaseFirestore createMockFirestore() {
  final firestore = MockFirebaseFirestore();
  final collection = MockCollectionReference();
  final doc = MockDocumentReference();
  final snap = MockDocumentSnapshot();
  when(() => snap.exists).thenReturn(true);
  when(() => firestore.collection(any())).thenReturn(collection);
  when(() => collection.doc(any())).thenReturn(doc);
  when(() => doc.set(any())).thenAnswer((_) async {});
  when(() => doc.get()).thenAnswer((_) async => snap);
  return firestore;
}

AuthCubit createMockAuthCubit() {
  final authService = MockAuthService();
  when(() => authService.currentUser()).thenReturn(null);
  return AuthCubit(
    authService: authService,
    firestore: createMockFirestore(),
  );
}

class MockNotificationService extends Mock
    implements NotificationService {}

ProviderAuthCubit createMockProviderAuthCubit() {
  final authService = MockAuthService();
  when(() => authService.currentUser()).thenReturn(null);
  return ProviderAuthCubit(
    authService: authService,
    providerService: MockProviderService(),
    notificationService: MockNotificationService(),
  );
}
