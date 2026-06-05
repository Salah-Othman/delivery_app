import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/orders/screens/new_order_screen.dart';
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
  testWidgets('NewOrderScreen shows form fields and submit button',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const NewOrderScreen()));

    expect(find.text('طلب خدمة جديدة'), findsOneWidget);
    expect(find.text('اختر الخدمة'), findsOneWidget);
    expect(find.text('وصف المشكلة'), findsOneWidget);
    expect(find.text('العنوان'), findsOneWidget);
    expect(find.text('السعر المقترح'), findsOneWidget);
    expect(find.text('إرسال الطلب'), findsOneWidget);
  });
}
