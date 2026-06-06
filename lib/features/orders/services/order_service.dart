import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error_utils.dart';
import '../../../models/order_model.dart';
import '../../../models/review_model.dart';
import '../../../core/constants.dart';

class OrderService {
  final FirebaseFirestore _firestore;

  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(AppConstants.firebaseCollectionOrders);

  Future<String> createOrder(OrderModel order) async {
    final doc = _orders.doc();
    await doc.set(order.toMap());
    return doc.id;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _orders.doc(orderId).update({
        'status': status.name,
        if (status == OrderStatus.completed) 'completedAt': DateTime.now(),
      });
    } catch (e, s) {
      logError(e, s, context: 'OrderService.updateOrderStatus');
      rethrow;
    }
  }

  Future<void> assignProvider(String orderId, String providerId) async {
    try {
      await _orders.doc(orderId).update({
        'providerId': providerId,
        'status': OrderStatus.accepted.name,
      });
    } catch (e, s) {
      logError(e, s, context: 'OrderService.assignProvider');
      rethrow;
    }
  }

  Stream<OrderModel?> orderStream(String orderId) {
    return _orders
        .doc(orderId)
        .snapshots()
        .map(
          (snap) =>
              snap.exists ? OrderModel.fromMap(snap.data()!, snap.id) : null,
        )
        .handleError((e, s) => logError(e, s, context: 'OrderService.orderStream'));
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        )
        .handleError(
            (e, s) => logError(e, s, context: 'OrderService.userOrdersStream'));
  }

  Stream<List<OrderModel>> providerOrdersStream(String providerId) {
    return _orders
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList(),
        )
        .handleError((e, s) =>
            logError(e, s, context: 'OrderService.providerOrdersStream'));
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore
          .collection(AppConstants.firebaseCollectionReviews)
          .doc(review.id)
          .set(review.toMap());
    } catch (e, s) {
      logError(e, s, context: 'OrderService.addReview');
      rethrow;
    }
  }

  Stream<List<ReviewModel>> providerReviewsStream(String providerId) {
    return _firestore
        .collection(AppConstants.firebaseCollectionReviews)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList(),
        )
        .handleError((e, s) =>
            logError(e, s, context: 'OrderService.providerReviewsStream'));
  }

  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final snap = await _orders
          .where('status', isEqualTo: OrderStatus.pending.name)
          .get();
      return snap.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, s) {
      logError(e, s, context: 'OrderService.getPendingOrders');
      rethrow;
    }
  }
}
