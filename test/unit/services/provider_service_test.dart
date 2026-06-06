import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_delivery/providers/services/provider_service.dart';
import 'package:app_delivery/models/provider_model.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDoc;
  late MockDocumentSnapshot mockSnap;
  late ProviderService providerService;

  setUp(() {
    mockFirestore = createMockFirestore();
    mockCollection = MockCollectionReference();
    mockDoc = MockDocumentReference();
    mockSnap = MockDocumentSnapshot();
    when(() => mockSnap.exists).thenReturn(true);
    when(() => mockSnap.id).thenReturn('p1');
    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDoc);
    when(() => mockDoc.get()).thenAnswer((_) async => mockSnap);
    providerService = ProviderService(firestore: mockFirestore);
  });

  group('getProvider', () {
    test('returns ProviderModel when found', () async {
      final data = {
        'name': 'أحمد',
        'phone': '0100',
        'email': 'ahmed@test.com',
        'available': true,
      };
      when(() => mockSnap.exists).thenReturn(true);
      when(() => mockSnap.data()).thenReturn(data);
      when(() => mockDoc.get()).thenAnswer((_) async => mockSnap);

      final result = await providerService.getProvider('p1');

      expect(result, isNotNull);
      expect(result!.id, 'p1');
      expect(result.name, 'أحمد');
    });

    test('returns null when provider not found', () async {
      when(() => mockSnap.exists).thenReturn(false);
      when(() => mockDoc.get()).thenAnswer((_) async => mockSnap);

      final result = await providerService.getProvider('nonexistent');

      expect(result, isNull);
    });

    test('rethrows on error', () async {
      when(() => mockDoc.get()).thenThrow(Exception('firestore error'));

      expect(() => providerService.getProvider('p1'), throwsException);
    });
  });

  group('updateAvailability', () {
    test('updates the available field', () async {
      when(() => mockDoc.update({'available': false}))
          .thenAnswer((_) async {});

      await providerService.updateAvailability('p1', false);

      verify(() => mockDoc.update({'available': false})).called(1);
    });

    test('rethrows on error', () async {
      when(() => mockDoc.update(any())).thenThrow(Exception('error'));

      expect(() => providerService.updateAvailability('p1', true),
          throwsException);
    });
  });

  group('updateLocation', () {
    test('updates lat and lng fields', () async {
      when(() => mockDoc.update({'lat': 30.0, 'lng': 31.0}))
          .thenAnswer((_) async {});

      await providerService.updateLocation('p1', 30.0, 31.0);

      verify(() => mockDoc.update({'lat': 30.0, 'lng': 31.0})).called(1);
    });
  });

  group('incrementOrders', () {
    test('increments totalOrders', () async {
      when(() => mockDoc.update(any())).thenAnswer((_) async {});

      await providerService.incrementOrders('p1');

      verify(() => mockDoc.update(any())).called(1);
    });
  });

  group('addEarnings', () {
    test('increments totalEarnings', () async {
      when(() => mockDoc.update(any())).thenAnswer((_) async {});

      await providerService.addEarnings('p1', 100.0);

      verify(() => mockDoc.update(any())).called(1);
    });
  });
}
