import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/auth/screens/login_screen.dart';
import 'package:app_delivery/core/theme.dart';
import 'package:app_delivery/core/routes.dart';
import '../helpers/mocks.dart';

Widget createTestApp(Widget child) {
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
      home: child,
      routes: {
        AppRoutes.home: (_) => const Scaffold(),
      },
    ),
  );
}

void main() {
  testWidgets('LoginScreen shows logo, role toggle, email/password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const LoginScreen()));

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('كل حاجة في مكان واحد'), findsOneWidget);
    expect(find.text('عميل'), findsOneWidget);
    expect(find.text('مقدم خدمة'), findsOneWidget);
    expect(find.text('تسجيل دخول'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
