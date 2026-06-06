import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/core/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return ['wifi'];
        }
        return null;
      },
    );
  });

  group('ConnectivityService', () {
    test('is a singleton', () {
      final instance1 = ConnectivityService();
      final instance2 = ConnectivityService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('isOnline defaults to true', () {
      expect(ConnectivityService().isOnline, isTrue);
    });

    test('onStatusChanged broadcasts connectivity changes', () async {
      final service = ConnectivityService();
      final statuses = <bool>[];
      final sub = service.onStatusChanged.listen((online) {
        statuses.add(online);
      });

      await service.initialize();
      await Future.delayed(Duration.zero);

      expect(statuses.isNotEmpty, isTrue);
      expect(service.isOnline, isTrue);

      sub.cancel();
    });
  });
}
