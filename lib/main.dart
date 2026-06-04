import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/orders/screens/new_order_screen.dart';
import 'features/orders/screens/order_tracking_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() {
  runApp(const EidWahdaApp());
}

class EidWahdaApp extends StatelessWidget {
  const EidWahdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إيد واحدة',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.newOrder: (_) => const NewOrderScreen(),
        AppRoutes.orderTracking: (_) => const OrderTrackingScreen(),
        AppRoutes.orderHistory: (_) => const OrderHistoryScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}
