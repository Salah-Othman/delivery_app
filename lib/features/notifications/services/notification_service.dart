import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../core/error_utils.dart';
import '../../../core/routes.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _token;
  GlobalKey<NavigatorState>? _navigatorKey;

  String? get token => _token;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        _token = await _messaging.getToken();

        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        final initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      }
    } catch (e, s) {
      logError(e, s, context: 'NotificationService.initialize');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final navigatorContext = _navigatorKey?.currentContext;
    if (navigatorContext == null) return;

    ScaffoldMessenger.of(navigatorContext).showSnackBar(
      SnackBar(
        content: Text(notification.body ?? notification.title ?? ''),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () => _navigateToOrder(message),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    _navigateToOrder(message);
  }

  void _navigateToOrder(RemoteMessage message) {
    final data = message.data;
    final orderId = data['orderId'] as String?;
    if (orderId != null && orderId.isNotEmpty) {
      _navigatorKey?.currentState?.pushNamed(
        AppRoutes.orderTracking,
        arguments: orderId,
      );
    }
  }

  Future<void> saveTokenToFirestore(String userId) async {
    if (_token == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': _token});
    } catch (e, s) {
      logError(e, s, context: 'NotificationService.saveTokenToFirestore');
    }
  }

  Future<void> deleteTokenFromFirestore(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
    } catch (e, s) {
      logError(e, s, context: 'NotificationService.deleteTokenFromFirestore');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _token = null;
    } catch (e, s) {
      logError(e, s, context: 'NotificationService.deleteToken');
    }
  }
}
