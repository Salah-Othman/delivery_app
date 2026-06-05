import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/auth/screens/login_screen.dart';
import 'package:app_delivery/core/theme.dart';

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
    ),
  );
}

void main() {
  testWidgets('LoginScreen shows logo, title, and buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const LoginScreen()));

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('كل حاجة في مكان واحد'), findsOneWidget);
    expect(find.text('رقم الموبايل'), findsOneWidget);
    expect(find.text('تسجيل الدخول برقم الموبايل'), findsOneWidget);
    expect(find.text('أو'), findsOneWidget);
    expect(find.text('تسجيل الدخول بواسطة Google'), findsOneWidget);
  });
}
