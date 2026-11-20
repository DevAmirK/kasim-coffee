import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/data/local_storage_service.dart';
import 'package:final_project/providers/settings_provider.dart';

void main() {
  testWidgets('theme transitions keep button text styles compatible', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = SettingsProvider(LocalStorageService(preferences));
    await tester.pumpWidget(KasimCoffeeApp(settings: settings));

    for (final dark in [true, false, true, false]) {
      await settings.setDarkMode(dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final context = tester.element(find.text('Sign in'));
      expect(
        Theme.of(context).brightness,
        dark ? Brightness.dark : Brightness.light,
      );
    }
  });

  testWidgets('Kasim Coffee login screen smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      KasimCoffeeApp(
        settings: SettingsProvider(LocalStorageService(preferences)),
      ),
    );
    expect(find.text('Welcome to Kasim Coffee'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('saved dark mode applies on the first frame', (tester) async {
    SharedPreferences.setMockInitialValues({
      LocalStorageService.themeKey: true,
    });
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      KasimCoffeeApp(
        settings: SettingsProvider(LocalStorageService(preferences)),
      ),
    );
    final context = tester.element(find.text('Welcome to Kasim Coffee'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
