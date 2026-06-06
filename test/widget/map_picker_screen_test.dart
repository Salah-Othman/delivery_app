import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_delivery/features/orders/screens/map_picker_screen.dart';
import 'package:app_delivery/core/theme.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light,
    home: child,
  );
}

void main() {
  group('MapPickerScreen', () {
    testWidgets('renders title and confirm button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const MapPickerScreen()));
      await tester.pump();

      expect(find.text('اختيار الموقع'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
      expect(find.text('تأكيد الموقع'), findsOneWidget);
      // address is immediately resolved from reverse geocoding fallback
      expect(find.textContaining('27.9311'), findsOneWidget);
    });

    testWidgets('shows my location FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const MapPickerScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('shows location pin icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const MapPickerScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.location_on_rounded), findsWidgets);
    });

    testWidgets('close button pops the screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const MapPickerScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('اختيار الموقع'), findsNothing);
    });

    testWidgets('returns MapPickerResult on confirm', (WidgetTester tester) async {
      MapPickerResult? result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<MapPickerResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MapPickerScreen(
                      initialLat: 27.9311,
                      initialLng: 30.8389,
                    ),
                  ),
                );
              },
              child: const Text('فتح الخريطة'),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('فتح الخريطة'));
      await tester.pump();
      await tester.pump();

      expect(find.text('اختيار الموقع'), findsOneWidget);

      await tester.tap(find.text('تأكيد'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.latitude, 27.9311);
      expect(result!.longitude, 30.8389);
    });

    testWidgets('accepts initial coordinates', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const MapPickerScreen(
            initialLat: 27.93,
            initialLng: 30.84,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('اختيار الموقع'), findsOneWidget);
    });
  });
}
