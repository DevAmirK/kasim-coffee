import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/data/local_storage_service.dart';
import 'package:final_project/providers/settings_provider.dart';
import 'package:final_project/widgets/settings_vault.dart';

void main() {
  testWidgets('profile controls save name, theme and note changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = SettingsProvider(LocalStorageService(preferences));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(
          home: Scaffold(body: ListView(children: const [SettingsVault()])),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Coffee fan');
    await tester.tap(find.text('Save name'));
    await tester.pumpAndSettle();
    expect(preferences.getString(LocalStorageService.nameKey), 'Coffee fan');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(preferences.getBool(LocalStorageService.themeKey), true);

    await tester.enterText(find.byType(TextField).last, 'Try flat white');
    await tester.ensureVisible(find.text('Add note'));
    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(
      LocalStorageService(preferences).readNotes().single.isCompleted,
      true,
    );
    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();
    expect(LocalStorageService(preferences).readNotes(), isEmpty);
    expect(tester.takeException(), isNull);
  });
}
