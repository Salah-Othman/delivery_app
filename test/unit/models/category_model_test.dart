import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    final category = CategoryModel(
      id: 'cat_1',
      nameAr: 'سباكة',
      icon: 'water_drop',
      orderCount: 120,
    );

    test('toMap returns correct map', () {
      final map = category.toMap();

      expect(map['id'], 'cat_1');
      expect(map['nameAr'], 'سباكة');
      expect(map['icon'], 'water_drop');
      expect(map['orderCount'], 120);
    });

    test('fromMap creates correct model', () {
      final map = category.toMap();
      final restored = CategoryModel.fromMap(map, 'cat_1');

      expect(restored.id, 'cat_1');
      expect(restored.nameAr, 'سباكة');
      expect(restored.icon, 'water_drop');
      expect(restored.orderCount, 120);
    });

    test('fromMap handles empty map with defaults', () {
      final restored = CategoryModel.fromMap({
        'nameAr': 'كهرباء',
      }, 'cat_2');

      expect(restored.nameAr, 'كهرباء');
      expect(restored.icon, 'handyman');
      expect(restored.orderCount, 0);
    });
  });
}
