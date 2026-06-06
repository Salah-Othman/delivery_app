import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/orders/screens/order_history_screen.dart';
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
        AppRoutes.orderTracking: (_) => const Scaffold(),
      },
    ),
  );
}

void main() {
  testWidgets('OrderHistoryScreen shows login prompt when not authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const OrderHistoryScreen()));
    await tester.pump();

    expect(find.text('طلباتي'), findsOneWidget);
    expect(find.text('سجل الدخول لعرض طلباتك'), findsOneWidget);
  });
}
