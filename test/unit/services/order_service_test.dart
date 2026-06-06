import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app_delivery/features/orders/services/order_service.dart';
import 'package:app_delivery/models/order_model.dart';
import 'package:app_delivery/models/review_model.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockOrders;
  late MockCollectionReference mockReviews;
  late MockDocumentReference mockDoc;
  late MockDocumentSnapshot mockSnap;
  late OrderService orderService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockOrders = MockCollectionReference();
    mockReviews = MockCollectionReference();
    mockDoc = MockDocumentReference();
    mockSnap = MockDocumentSnapshot();
    when(() => mockSnap.exists).thenReturn(true);

    when(() => mockFirestore.collection('orders')).thenReturn(mockOrders);
    when(() => mockFirestore.collection('reviews')).thenReturn(mockReviews);
    when(() => mockOrders.doc(any())).thenReturn(mockDoc);
    when(() => mockOrders.doc()).thenReturn(mockDoc);
    when(() => mockReviews.doc(any())).thenReturn(mockDoc);
    when(() => mockDoc.id).thenReturn('new_order_1');
    when(() => mockDoc.set(any())).thenAnswer((_) async {});
    when(() => mockDoc.update(any())).thenAnswer((_) async {});
    when(() => mockDoc.get()).thenAnswer((_) async => mockSnap);
    orderService = OrderService(firestore: mockFirestore);
  });

  group('createOrder', () {
    test('returns new order ID', () async {
      final order = OrderModel(
        id: '',
        userId: 'u1',
        serviceType: 'c1',
        description: 'إصلاح حنفية',
        userAddress: 'شارع 1',
        userLat: 30.0,
        userLng: 31.0,
        paymentMethod: PaymentMethod.cash,
        price: 0,
      );

      final orderId = await orderService.createOrder(order);

      expect(orderId, 'new_order_1');
      verify(() => mockDoc.set(any())).called(1);
    });
  });

  group('updateOrderStatus', () {
    test('updates status to completed with timestamp', () async {
      await orderService.updateOrderStatus('o1', OrderStatus.completed);

      verify(() => mockDoc.update(any())).called(1);
    });

    test('updates status without timestamp', () async {
      await orderService.updateOrderStatus('o1', OrderStatus.accepted);

      verify(() => mockDoc.update(any())).called(1);
    });

    test('rethrows on error', () async {
      when(() => mockDoc.update(any())).thenThrow(Exception('error'));

      expect(() => orderService.updateOrderStatus('o1', OrderStatus.cancelled),
          throwsException);
    });
  });

  group('assignProvider', () {
    test('updates providerId and sets status to accepted', () async {
      await orderService.assignProvider('o1', 'p1');

      verify(() => mockDoc.update(any())).called(1);
    });

    test('rethrows on error', () async {
      when(() => mockDoc.update(any())).thenThrow(Exception('error'));

      expect(() => orderService.assignProvider('o1', 'p1'), throwsException);
    });
  });

  group('addReview', () {
    test('adds review document', () async {
      final review = ReviewModel(
        id: 'r1',
        orderId: 'o1',
        providerId: 'p1',
        userId: 'u1',
        rating: 5,
        comment: 'ممتاز',
      );

      await orderService.addReview(review);

      verify(() => mockDoc.set(review.toMap())).called(1);
    });

    test('rethrows on error', () async {
      when(() => mockDoc.set(any())).thenThrow(Exception('error'));

      expect(
        () => orderService.addReview(ReviewModel(
          id: 'r1', orderId: 'o1', providerId: 'p1', userId: 'u1', rating: 3,
        )),
        throwsException,
      );
    });
  });

  group('getPendingOrders', () {
    test('returns list of pending orders', () async {
      final snap = MockQuerySnapshot();
      when(() => snap.docs).thenReturn([]);
      when(() => mockOrders.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockOrders);
      when(() => mockOrders.get()).thenAnswer((_) async => snap);

      final result = await orderService.getPendingOrders();

      expect(result, isEmpty);
    });

    test('rethrows on error', () async {
      when(() => mockOrders.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockOrders);
      when(() => mockOrders.get()).thenThrow(Exception('error'));

      expect(() => orderService.getPendingOrders(), throwsException);
    });
  });
}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}
