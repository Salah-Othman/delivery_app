import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/models/order_model.dart';

void main() {
  group('OrderStatus', () {
    test('labels are in Arabic', () {
      expect(OrderStatus.pending.label, 'قيد الانتظار');
      expect(OrderStatus.accepted.label, 'تم القبول');
      expect(OrderStatus.inProgress.label, 'جارٍ العمل');
      expect(OrderStatus.completed.label, 'تم الانتهاء');
      expect(OrderStatus.cancelled.label, 'ملغي');
    });

    test('fromString handles all values', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('accepted'), OrderStatus.accepted);
      expect(OrderStatus.fromString('inProgress'), OrderStatus.inProgress);
      expect(OrderStatus.fromString('completed'), OrderStatus.completed);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
    });

    test('fromString defaults to pending for unknown', () {
      expect(OrderStatus.fromString('unknown'), OrderStatus.pending);
    });
  });

  group('PaymentMethod', () {
    test('labels are in Arabic', () {
      expect(PaymentMethod.cash.label, 'كاش');
      expect(PaymentMethod.vodafoneCash.label, 'فودافون كاش');
    });

    test('fromString handles all values', () {
      expect(PaymentMethod.fromString('cash'), PaymentMethod.cash);
      expect(PaymentMethod.fromString('vodafoneCash'),
          PaymentMethod.vodafoneCash);
    });

    test('fromString defaults to cash for unknown', () {
      expect(PaymentMethod.fromString('unknown'), PaymentMethod.cash);
    });
  });

  group('OrderModel', () {
    final now = DateTime.now();
    final order = OrderModel(
      id: 'order_1',
      userId: 'user_1',
      providerId: 'provider_1',
      serviceType: 'سباكة',
      description: 'حنفية المطبخ بتسرب مياه',
      status: OrderStatus.inProgress,
      price: 150.0,
      paymentMethod: PaymentMethod.vodafoneCash,
      userAddress: 'شارع البحر',
      userLat: 27.9311,
      userLng: 30.8389,
      createdAt: now,
    );

    test('toMap returns correct map', () {
      final map = order.toMap();

      expect(map['id'], 'order_1');
      expect(map['userId'], 'user_1');
      expect(map['providerId'], 'provider_1');
      expect(map['serviceType'], 'سباكة');
      expect(map['description'], 'حنفية المطبخ بتسرب مياه');
      expect(map['status'], 'inProgress');
      expect(map['price'], 150.0);
      expect(map['paymentMethod'], 'vodafoneCash');
      expect(map['userAddress'], 'شارع البحر');
    });

    test('fromMap creates correct model', () {
      final map = order.toMap();
      final restored = OrderModel.fromMap(map, 'order_1');

      expect(restored.id, 'order_1');
      expect(restored.userId, 'user_1');
      expect(restored.providerId, 'provider_1');
      expect(restored.serviceType, 'سباكة');
      expect(restored.description, 'حنفية المطبخ بتسرب مياه');
      expect(restored.status, OrderStatus.inProgress);
      expect(restored.price, 150.0);
      expect(restored.paymentMethod, PaymentMethod.vodafoneCash);
      expect(restored.userLat, 27.9311);
      expect(restored.userLng, 30.8389);
    });

    test('fromMap handles empty map with defaults', () {
      final restored = OrderModel.fromMap({
        'userId': 'user_2',
        'serviceType': 'كهرباء',
        'description': 'عطل',
        'price': 100,
      }, 'order_2');

      expect(restored.id, 'order_2');
      expect(restored.status, OrderStatus.pending);
      expect(restored.paymentMethod, PaymentMethod.cash);
      expect(restored.providerId, isNull);
      expect(restored.userAddress, isNull);
    });
  });
}
