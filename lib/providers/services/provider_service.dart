import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/error_utils.dart';
import '../../models/provider_model.dart';
import '../../core/constants.dart';

class ProviderService {
  final FirebaseFirestore _firestore;

  ProviderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _providers =>
      _firestore.collection(AppConstants.firebaseCollectionProviders);

  Future<ProviderModel?> getProvider(String id) async {
    try {
      final doc = await _providers.doc(id).get();
      if (!doc.exists) return null;
      return ProviderModel.fromMap(doc.data()!, doc.id);
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.getProvider');
      rethrow;
    }
  }

  Future<ProviderModel?> getProviderByPhone(String phone) async {
    try {
      final snap = await _providers.where('phone', isEqualTo: phone).get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return ProviderModel.fromMap(doc.data(), doc.id);
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.getProviderByPhone');
      rethrow;
    }
  }

  Stream<ProviderModel?> streamProvider(String id) {
    return _providers.doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ProviderModel.fromMap(snap.data()!, snap.id);
    }).handleError((e, s) => logError(e, s, context: 'ProviderService.streamProvider'));
  }

  Future<void> updateAvailability(String id, bool available) async {
    try {
      await _providers.doc(id).update({'available': available});
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.updateAvailability');
      rethrow;
    }
  }

  Future<void> updateLocation(String id, double lat, double lng) async {
    try {
      await _providers.doc(id).update({'lat': lat, 'lng': lng});
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.updateLocation');
      rethrow;
    }
  }

  Future<void> incrementOrders(String id) async {
    try {
      await _providers.doc(id).update({
        'totalOrders': FieldValue.increment(1),
      });
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.incrementOrders');
      rethrow;
    }
  }

  Future<void> addEarnings(String id, double amount) async {
    try {
      await _providers.doc(id).update({
        'totalEarnings': FieldValue.increment(amount),
      });
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.addEarnings');
      rethrow;
    }
  }

  Future<double> getTodayEarnings(String providerId) async {
    try {
      final startOfDay = DateTime.now();
      final start = DateTime(startOfDay.year, startOfDay.month, startOfDay.day);
      final end = start.add(const Duration(days: 1));

      final snap = await _firestore
          .collection(AppConstants.firebaseCollectionOrders)
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: start)
          .where('completedAt', isLessThan: end)
          .get();

      double total = 0;
      for (final doc in snap.docs) {
        final price = (doc.data()['price'] as num?)?.toDouble() ?? 0;
        total += price;
      }
      return total;
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.getTodayEarnings');
      return 0;
    }
  }

  Future<double> getPeriodEarnings(
      String providerId, DateTime from, DateTime to) async {
    try {
      final snap = await _firestore
          .collection(AppConstants.firebaseCollectionOrders)
          .where('providerId', isEqualTo: providerId)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: from)
          .where('completedAt', isLessThan: to)
          .get();

      double total = 0;
      for (final doc in snap.docs) {
        final price = (doc.data()['price'] as num?)?.toDouble() ?? 0;
        total += price;
      }
      return total;
    } catch (e, s) {
      logError(e, s, context: 'ProviderService.getPeriodEarnings');
      return 0;
    }
  }
}
