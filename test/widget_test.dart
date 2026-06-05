import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/auth/screens/login_screen.dart';
import 'package:app_delivery/core/theme.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
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
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('تسجيل الدخول برقم الموبايل'), findsOneWidget);
    expect(find.text('تسجيل الدخول بواسطة Google'), findsOneWidget);
    expect(find.text('01001234567'), findsOneWidget);
  });
}
