import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_delivery/features/orders/cubit/order_cubit.dart';
import 'package:app_delivery/features/orders/screens/new_order_screen.dart';
import 'package:app_delivery/features/orders/services/order_service.dart';
import 'package:app_delivery/core/theme.dart';
import 'package:app_delivery/core/routes.dart';

class MockOrderService extends Mock implements OrderService {}

void main() {
  testWidgets('NewOrderScreen shows form fields and submit button',
      (WidgetTester tester) async {
    final mockService = MockOrderService();
    final cubit = OrderCubit(orderService: mockService);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        home: NewOrderScreen(orderCubit: cubit),
        routes: {
          AppRoutes.home: (_) => const Scaffold(),
          AppRoutes.orderTracking: (_) => const Scaffold(),
        },
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('طلب خدمة جديدة'), findsOneWidget);
    expect(find.text('اختر الخدمة'), findsOneWidget);
    expect(find.text('وصف المشكلة'), findsOneWidget);
    expect(find.text('العنوان'), findsOneWidget);
    expect(find.text('السعر المقترح'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    await tester.pump();

    expect(find.text('إرسال الطلب'), findsOneWidget);
  });
}
