import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/auth/screens/login_screen.dart';
import 'package:app_delivery/core/theme.dart';
import 'helpers/mocks.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
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
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('إيد واحدة'), findsOneWidget);
    expect(find.text('عميل'), findsOneWidget);
    expect(find.text('مقدم خدمة'), findsOneWidget);
    expect(find.text('تسجيل دخول'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
  });
}
