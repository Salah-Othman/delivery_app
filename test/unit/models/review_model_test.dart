import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    final review = ReviewModel(
      id: 'review_1',
      orderId: 'order_1',
      userId: 'user_1',
      providerId: 'provider_1',
      rating: 5,
      comment: 'شغل ممتاز ونظيف',
    );

    test('toMap returns correct map', () {
      final map = review.toMap();

      expect(map['id'], 'review_1');
      expect(map['orderId'], 'order_1');
      expect(map['userId'], 'user_1');
      expect(map['providerId'], 'provider_1');
      expect(map['rating'], 5);
      expect(map['comment'], 'شغل ممتاز ونظيف');
    });

    test('fromMap creates correct model', () {
      final map = review.toMap();
      final restored = ReviewModel.fromMap(map, 'review_1');

      expect(restored.id, 'review_1');
      expect(restored.orderId, 'order_1');
      expect(restored.userId, 'user_1');
      expect(restored.providerId, 'provider_1');
      expect(restored.rating, 5);
      expect(restored.comment, 'شغل ممتاز ونظيف');
    });

    test('fromMap handles null comment', () {
      final restored = ReviewModel.fromMap({
        'orderId': 'order_2',
        'userId': 'user_2',
        'providerId': 'provider_2',
        'rating': 3,
      }, 'review_2');

      expect(restored.comment, isNull);
      expect(restored.rating, 3);
    });
  });
}
