import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/profile/screens/profile_screen.dart';
import 'package:app_delivery/core/theme.dart';
import 'package:app_delivery/core/routes.dart';

Widget createTestApp(Widget child) {
  return BlocProvider(
    create: (_) => AuthCubit(),
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
        AppRoutes.login: (_) => const Scaffold(),
        AppRoutes.orderHistory: (_) => const Scaffold(),
      },
    ),
  );
}

void main() {
  testWidgets('ProfileScreen shows user info and menu items',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const ProfileScreen()));
    await tester.pump();

    expect(find.text('حسابي'), findsOneWidget);
    expect(find.text('مستخدم'), findsOneWidget);
    expect(find.text('العناوين'), findsOneWidget);
    expect(find.text('طرق الدفع'), findsOneWidget);
    expect(find.text('المفضلة'), findsOneWidget);
    expect(find.text('خدمة العملاء'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}
