import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/models/user_model.dart';

void main() {
  group('UserModel', () {
    final now = DateTime.now();
    final user = UserModel(
      id: 'user_1',
      phone: '01001234567',
      email: 'test@example.com',
      name: 'أحمد علي',
      address: 'شارع البحر، أبو قرقاص',
      lat: 27.9311,
      lng: 30.8389,
      orderCount: 5,
      createdAt: now,
    );

    test('toMap returns correct map', () {
      final map = user.toMap();

      expect(map['id'], 'user_1');
      expect(map['phone'], '01001234567');
      expect(map['email'], 'test@example.com');
      expect(map['name'], 'أحمد علي');
      expect(map['address'], 'شارع البحر، أبو قرقاص');
      expect(map['lat'], 27.9311);
      expect(map['lng'], 30.8389);
      expect(map['orderCount'], 5);
      expect(map['createdAt'], now);
    });

    test('fromMap creates correct model', () {
      final map = user.toMap();
      final restored = UserModel.fromMap(map, 'user_1');

      expect(restored.id, 'user_1');
      expect(restored.phone, '01001234567');
      expect(restored.email, 'test@example.com');
      expect(restored.name, 'أحمد علي');
      expect(restored.address, 'شارع البحر، أبو قرقاص');
      expect(restored.lat, 27.9311);
      expect(restored.lng, 30.8389);
      expect(restored.orderCount, 5);
    });

    test('fromMap handles null fields', () {
      final restored = UserModel.fromMap({}, 'user_2');

      expect(restored.id, 'user_2');
      expect(restored.phone, '');
      expect(restored.email, isNull);
      expect(restored.name, isNull);
      expect(restored.address, isNull);
      expect(restored.lat, isNull);
      expect(restored.lng, isNull);
      expect(restored.orderCount, 0);
    });

    test('copyWith updates specified fields', () {
      final updated = user.copyWith(name: 'محمد', orderCount: 10);

      expect(updated.id, 'user_1');
      expect(updated.name, 'محمد');
      expect(updated.orderCount, 10);
      expect(updated.phone, '01001234567');
      expect(updated.address, 'شارع البحر، أبو قرقاص');
    });

    test('copyWith preserves unspecified fields', () {
      final updated = user.copyWith(name: 'محمد');

      expect(updated.phone, '01001234567');
      expect(updated.email, 'test@example.com');
      expect(updated.address, 'شارع البحر، أبو قرقاص');
      expect(updated.orderCount, 5);
    });

    test('createdAt defaults to now', () {
      final fresh = UserModel(id: 'new', phone: '01000000000');

      expect(fresh.createdAt, isA<DateTime>());
      expect(fresh.orderCount, 0);
    });
  });
}
