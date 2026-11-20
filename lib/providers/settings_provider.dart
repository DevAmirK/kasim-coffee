import 'package:flutter/foundation.dart';

import '../data/local_storage_service.dart';
import '../models/note_item.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this.storage)
    : darkMode = storage.darkMode,
      displayName = storage.displayName,
      _notes = storage.readNotes();

  final LocalStorageService storage;
  bool darkMode;
  String displayName;
  List<NoteItem> _notes;
  bool saving = false;

  List<NoteItem> get notes => List.unmodifiable(_notes);

  Future<void> _save(Future<void> Function() action) async {
    if (saving) return;
    saving = true;
    notifyListeners();
    try {
      await action();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) => _save(() async {
    await storage.saveDarkMode(value);
    darkMode = value;
  });

  Future<void> saveName(String value) => _save(() async {
    final name = value.trim().isEmpty ? 'Guest User' : value.trim();
    await storage.saveDisplayName(name);
    displayName = name;
  });

  Future<void> addNote(String title) => _save(() async {
    if (title.trim().isEmpty) return;
    final now = DateTime.now();
    final updated = [
      NoteItem(
        id: now.microsecondsSinceEpoch.toString(),
        title: title.trim(),
        dateText:
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      ),
      ..._notes,
    ];
    await storage.saveNotes(updated);
    _notes = updated;
  });

  Future<void> toggleNote(String id) => _save(() async {
    final updated = _notes
        .map((note) => note.id == id ? note.toggle() : note)
        .toList();
    await storage.saveNotes(updated);
    _notes = updated;
  });

  Future<void> deleteNote(String id) => _save(() async {
    final updated = _notes.where((note) => note.id != id).toList();
    await storage.saveNotes(updated);
    _notes = updated;
  });
}
