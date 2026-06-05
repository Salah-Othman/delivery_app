import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/home/screens/home_screen.dart';
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
  testWidgets('HomeScreen shows categories and bottom nav',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const HomeScreen()));

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('الخدمات'), findsOneWidget);
    expect(find.text('طلباتي'), findsWidgets);
    expect(find.text('سباكة'), findsWidgets);
    expect(find.text('تكييف'), findsOneWidget);
    expect(find.text('كهرباء'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
  });
}
