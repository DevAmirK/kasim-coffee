import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';

class LocalStorageService {
  LocalStorageService(this.preferences);

  final SharedPreferences preferences;
  static const themeKey = 'app_theme_dark_mode';
  static const nameKey = 'user_display_name';
  static const notesKey = 'user_notes_json';

  bool get darkMode => preferences.getBool(themeKey) ?? false;
  String get displayName => preferences.getString(nameKey) ?? 'Guest User';

  List<NoteItem> readNotes() {
    final saved = preferences.getString(notesKey);
    if (saved == null) return [];
    try {
      final decoded = jsonDecode(saved) as List<dynamic>;
      return decoded
          .map((item) => NoteItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveDarkMode(bool value) async {
    _check(await preferences.setBool(themeKey, value));
  }

  Future<void> saveDisplayName(String value) async {
    _check(await preferences.setString(nameKey, value));
  }

  Future<void> saveNotes(List<NoteItem> notes) async {
    _check(
      await preferences.setString(
        notesKey,
        jsonEncode(notes.map((note) => note.toJson()).toList()),
      ),
    );
  }

  void _check(bool saved) {
    if (!saved) throw StateError('Could not save local data');
  }
}
