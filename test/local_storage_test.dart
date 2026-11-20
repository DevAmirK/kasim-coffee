import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/data/local_storage_service.dart';
import 'package:final_project/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults and settings restore in a new provider', () async {
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);
    final settings = SettingsProvider(storage);
    expect(settings.darkMode, false);
    expect(settings.displayName, 'Guest User');
    expect(settings.notes, isEmpty);

    await settings.setDarkMode(true);
    await settings.saveName('  Aigerim  ');
    await settings.addNote('First coffee');
    await settings.addNote('Second coffee');
    final firstId = settings.notes.last.id;
    await settings.toggleNote(firstId);

    final restored = SettingsProvider(LocalStorageService(preferences));
    expect(restored.darkMode, true);
    expect(restored.displayName, 'Aigerim');
    expect(restored.notes.map((note) => note.title), [
      'Second coffee',
      'First coffee',
    ]);
    expect(restored.notes.last.isCompleted, true);
    expect(restored.notes.last.dateText, isNotEmpty);
    final json = jsonDecode(
      preferences.getString(LocalStorageService.notesKey)!,
    ) as List;
    expect(json.last['isCompleted'], true);

    await restored.deleteNote(firstId);
    expect(storage.readNotes().single.title, 'Second coffee');
    await restored.deleteNote(restored.notes.single.id);
    expect(storage.readNotes(), isEmpty);
    await restored.saveName('   ');
    expect(storage.displayName, 'Guest User');
  });

  test('invalid saved JSON does not prevent startup', () async {
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);
    for (final value in ['invalid', '{}', '[{"id": 123}]']) {
      await preferences.setString(LocalStorageService.notesKey, value);
      expect(storage.readNotes(), isEmpty);
    }
  });
}
