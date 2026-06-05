import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/profile/screens/profile_screen.dart';
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
  testWidgets('ProfileScreen shows user info and menu items',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ProfileScreen()));

    expect(find.text('حسابي'), findsOneWidget);
    expect(find.text('أحمد علي'), findsOneWidget);
    expect(find.text('01234567890'), findsOneWidget);
    expect(find.text('طلباتي'), findsWidgets);
    expect(find.text('العناوين'), findsOneWidget);
    expect(find.text('طرق الدفع'), findsOneWidget);
    expect(find.text('المفضلة'), findsOneWidget);
    expect(find.text('خدمة العملاء'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}
