import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:app_delivery/features/auth/screens/otp_screen.dart';
import 'package:app_delivery/core/routes.dart';
import 'package:app_delivery/core/theme.dart';

Widget createOtpApp() {
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
      initialRoute: AppRoutes.otp,
      routes: {
        AppRoutes.otp: (_) => const OtpScreen(),
      },
    ),
  );
}

void main() {
  testWidgets('OtpScreen renders title and confirm button',
      (WidgetTester tester) async {
    await tester.pumpWidget(createOtpApp());

    expect(find.text('تأكيد الرقم'), findsOneWidget);
    expect(find.text('تأكيد'), findsOneWidget);
    expect(find.text('تغيير الرقم'), findsOneWidget);
  });
}
