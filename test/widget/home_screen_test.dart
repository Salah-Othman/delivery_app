import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/home/screens/home_screen.dart';
import 'package:app_delivery/core/theme.dart';
import 'package:app_delivery/core/routes.dart';
import '../helpers/mocks.dart';

Widget createTestApp(Widget child) {
  return BlocProvider.value(
    value: createMockAuthCubit(),
    child: MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      home: child,
      routes: {
        AppRoutes.newOrder: (_) => const Scaffold(),
        AppRoutes.orderHistory: (_) => const Scaffold(),
        AppRoutes.orderTracking: (_) => const Scaffold(),
        AppRoutes.profile: (_) => const Scaffold(),
      },
    ),
  );
}

void main() {
  testWidgets('HomeScreen shows categories and bottom nav',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const HomeScreen()));
    await tester.pump();

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('الخدمات'), findsOneWidget);
    expect(find.text('سباكة'), findsWidgets);
    expect(find.text('تكييف'), findsOneWidget);
    expect(find.text('كهرباء'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
  });
}
