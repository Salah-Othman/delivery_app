import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/orders/screens/order_tracking_screen.dart';
import 'package:app_delivery/core/theme.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light,
    home: child,
  );
}

void main() {
  testWidgets('OrderTrackingScreen shows status steps and call button',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const OrderTrackingScreen()));

    expect(find.text('متابعة الطلب'), findsOneWidget);
    expect(find.text('خريطة التتبع'), findsOneWidget);
    expect(find.text('تم استلام الطلب'), findsOneWidget);
    expect(find.text('تم قبول الطلب'), findsOneWidget);
    expect(find.text('مقدم الخدمة في الطريق'), findsOneWidget);
    expect(find.text('جارٍ العمل'), findsOneWidget);
    expect(find.text('تم الانتهاء'), findsOneWidget);
    expect(find.text('اتصل بمقدم الخدمة'), findsOneWidget);
    expect(find.text('محمد حسن'), findsOneWidget);
  });
}
