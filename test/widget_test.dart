import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/main.dart';

void main() {
  testWidgets('App starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EidWahdaApp());

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('رقم الموبايل'), findsOneWidget);
  });

  testWidgets('Navigates from login to OTP', (WidgetTester tester) async {
    await tester.pumpWidget(const EidWahdaApp());

    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد الرقم'), findsOneWidget);
    expect(find.text('تأكيد'), findsOneWidget);
  });
}
