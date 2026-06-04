import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/main.dart';

void main() {
  testWidgets('App renders welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const EidWahdaApp());

    expect(find.text('إيد واحدة'), findsWidgets);
    expect(find.text('مرحباً بك في إيد واحدة'), findsOneWidget);
  });
}
