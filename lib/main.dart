import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/firebase_service.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/orders/screens/new_order_screen.dart';
import 'features/orders/screens/order_tracking_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  NotificationService().initialize();
  runApp(const EidWahdaApp());
}

class EidWahdaApp extends StatelessWidget {
  const EidWahdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: MaterialApp(
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
        home: const AuthGate(),
        routes: {
          AppRoutes.otp: (_) => const OtpScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.newOrder: (_) => const NewOrderScreen(),
          AppRoutes.orderTracking: (_) => const OrderTrackingScreen(),
          AppRoutes.orderHistory: (_) => const OrderHistoryScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthVerified) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
