import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'core/connectivity_service.dart';
import 'core/error_utils.dart';
import 'core/firebase_service.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/orders/screens/new_order_screen.dart';
import 'features/orders/screens/order_tracking_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/splash/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  try {
    await FirebaseService.initialize();
  } catch (e, s) {
    logError(e, s, context: 'FirebaseService.initialize');
  }

  NotificationService().setNavigatorKey(navigatorKey);
  NotificationService().initialize().catchError((e, s) {
    logError(e, s, context: 'NotificationService.initialize');
  });

  try {
    await ConnectivityService().initialize();
  } catch (e, s) {
    logError(e, s, context: 'ConnectivityService.initialize');
  }

  runApp(const EidWahdaApp());
}

class EidWahdaApp extends StatefulWidget {
  const EidWahdaApp({super.key});

  @override
  State<EidWahdaApp> createState() => _EidWahdaAppState();
}

class _EidWahdaAppState extends State<EidWahdaApp> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    ConnectivityService().onStatusChanged.listen((online) {
      if (mounted) setState(() => _isOffline = !online);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
        home: _isOffline
            ? Stack(
                children: [
                  const SplashScreen(),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: MaterialBanner(
                      backgroundColor: Colors.orange.shade800,
                      content: const Text(
                        'لا يوجد اتصال بالإنترنت',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'إعادة محاولة',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SplashScreen(),
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
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
