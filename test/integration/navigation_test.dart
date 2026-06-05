import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/core/routes.dart';
import 'package:app_delivery/core/theme.dart';
import 'package:app_delivery/features/home/screens/home_screen.dart';
import 'package:app_delivery/features/orders/screens/new_order_screen.dart';
import 'package:app_delivery/features/orders/screens/order_history_screen.dart';
import 'package:app_delivery/features/orders/screens/order_tracking_screen.dart';
import 'package:app_delivery/features/profile/screens/profile_screen.dart';

Widget createIntegrationApp() {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light,
    initialRoute: AppRoutes.home,
    routes: {
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.newOrder: (_) => const NewOrderScreen(),
      AppRoutes.orderTracking: (_) => const OrderTrackingScreen(),
      AppRoutes.orderHistory: (_) => const OrderHistoryScreen(),
      AppRoutes.profile: (_) => const ProfileScreen(),
    },
  );
}

void main() {
  testWidgets('Full navigation: Home → Order → History → Profile',
      (WidgetTester tester) async {
    await tester.pumpWidget(createIntegrationApp());

    // Start at HomeScreen
    expect(find.text('الخدمات'), findsOneWidget);

    // Tap a service category → navigate to NewOrder
    await tester.tap(find.text('سباكة').first);
    await tester.pumpAndSettle();
    expect(find.text('طلب خدمة جديدة'), findsOneWidget);

    // Go back to Home
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('الخدمات'), findsOneWidget);

    // Use bottom nav to go to Profile
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('أحمد علي'), findsOneWidget);

    // From Profile, tap طلباتي → navigate to OrderHistory
    await tester.tap(find.text('طلباتي').last);
    await tester.pumpAndSettle();
    expect(find.text('إصلاح حنفية المطبخ'), findsOneWidget);
  });
}
