import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيد واحدة'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('مرحباً بك في إيد واحدة'),
      ),
    );
  }
}
