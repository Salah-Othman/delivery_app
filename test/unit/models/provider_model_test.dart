import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/models/provider_model.dart';

void main() {
  group('ProviderModel', () {
    final provider = ProviderModel(
      id: 'provider_1',
      email: 'mohamed@example.com',
      phone: '01001234567',
      name: 'محمد حسن',
      services: ['سباكة', 'كهرباء'],
      available: true,
      lat: 27.93,
      lng: 30.84,
      rating: 4.5,
      totalOrders: 50,
      commission: 0.10,
    );

    test('toMap returns correct map', () {
      final map = provider.toMap();

      expect(map['id'], 'provider_1');
      expect(map['email'], 'mohamed@example.com');
      expect(map['phone'], '01001234567');
      expect(map['name'], 'محمد حسن');
      expect(map['services'], ['سباكة', 'كهرباء']);
      expect(map['available'], true);
      expect(map['rating'], 4.5);
      expect(map['totalOrders'], 50);
      expect(map['commission'], 0.10);
    });

    test('fromMap creates correct model', () {
      final map = provider.toMap();
      final restored = ProviderModel.fromMap(map, 'provider_1');

      expect(restored.id, 'provider_1');
      expect(restored.email, 'mohamed@example.com');
      expect(restored.name, 'محمد حسن');
      expect(restored.services, ['سباكة', 'كهرباء']);
      expect(restored.available, true);
      expect(restored.rating, 4.5);
      expect(restored.totalOrders, 50);
      expect(restored.commission, 0.10);
    });

    test('fromMap handles empty map with defaults', () {
      final restored = ProviderModel.fromMap({}, 'provider_2');

      expect(restored.id, 'provider_2');
      expect(restored.email, '');
      expect(restored.available, true);
      expect(restored.services, isEmpty);
      expect(restored.rating, 0);
      expect(restored.totalOrders, 0);
      expect(restored.commission, 0.10);
    });

    test('copyWith updates specified fields', () {
      final updated = provider.copyWith(
        available: false,
        rating: 4.8,
        totalOrders: 51,
      );

      expect(updated.available, false);
      expect(updated.rating, 4.8);
      expect(updated.totalOrders, 51);
      expect(updated.name, 'محمد حسن');
      expect(updated.commission, 0.10);
    });
  });
}
