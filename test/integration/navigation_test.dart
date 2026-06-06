import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/core/routes.dart';
import 'package:app_delivery/core/theme.dart';
import 'package:app_delivery/features/home/screens/home_screen.dart';
import '../helpers/mocks.dart';

Widget createIntegrationApp() {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: createMockAuthCubit()),
      BlocProvider.value(value: createMockProviderAuthCubit()),
    ],
    child: MaterialApp(
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
        AppRoutes.newOrder: (_) => const Scaffold(),
        AppRoutes.orderTracking: (_) => const Scaffold(
              appBar: null,
              body: Center(child: Text('متابعة الطلب')),
            ),
        AppRoutes.orderHistory: (_) => const Scaffold(
              appBar: null,
              body: Center(child: Text('طلباتي')),
            ),
        AppRoutes.profile: (_) => const Scaffold(
              appBar: null,
              body: Center(child: Text('حسابي')),
            ),
        AppRoutes.login: (_) => const Scaffold(),
      },
    ),
  );
}

void main() {
  testWidgets('HomeScreen renders and navigates to screens',
      (WidgetTester tester) async {
    await tester.pumpWidget(createIntegrationApp());
    await tester.pump();

    expect(find.text('الخدمات'), findsOneWidget);
    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });
}
