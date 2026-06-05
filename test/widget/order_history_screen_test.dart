import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/orders/screens/order_history_screen.dart';
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
  testWidgets('OrderHistoryScreen shows list of past orders',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const OrderHistoryScreen()));

    expect(find.text('طلباتي'), findsOneWidget);
    expect(find.text('سباكة'), findsOneWidget);
    expect(find.text('تكييف'), findsOneWidget);
    expect(find.text('توصيل'), findsOneWidget);
    expect(find.text('إصلاح حنفية المطبخ'), findsOneWidget);
    expect(find.text('صيانة دورية'), findsOneWidget);
    expect(find.text('طلب من بقالة'), findsOneWidget);
    expect(find.text('200 EGP'), findsOneWidget);
    expect(find.text('تم الانتهاء'), findsWidgets);
    expect(find.text('قيد التنفيذ'), findsOneWidget);
  });
}
