import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsVault extends StatefulWidget {
  const SettingsVault({super.key});

  @override
  State<SettingsVault> createState() => _SettingsVaultState();
}

class _SettingsVaultState extends State<SettingsVault> {
  final name = TextEditingController();
  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    name.text = context.read<SettingsProvider>().displayName;
  }

  @override
  void dispose() {
    name.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save(Future<void> Function() action, {String? message}) async {
    try {
      await action();
      if (!mounted || message == null) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save changes. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          'Settings & offline notes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: const Text('Dark mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: settings.darkMode,
            onChanged: settings.saving
                ? null
                : (value) => save(() => settings.setDarkMode(value)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: name,
          enabled: !settings.saving,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: settings.saving
              ? null
              : () => save(() async {
                  await settings.saveName(name.text);
                  if (!mounted) return;
                  name.text = settings.displayName;
                }, message: 'Name saved'),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save name'),
        ),
        const SizedBox(height: 20),
        Text('My notes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: note,
          enabled: !settings.saving,
          minLines: 1,
          maxLines: 3,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'New note',
            hintText: 'Try a new latte',
          ),
        ),
        FilledButton.icon(
          onPressed: settings.saving
              ? null
              : () {
                  if (note.text.trim().isEmpty) return;
                  save(() async {
                    await settings.addNote(note.text);
                    if (!mounted) return;
                    note.clear();
                  });
                },
          icon: const Icon(Icons.add),
          label: const Text('Add note'),
        ),
        if (settings.notes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No notes yet. Add your first coffee idea.'),
          ),
        for (final item in settings.notes)
          Card(
            key: ValueKey(item.id),
            child: ListTile(
              leading: Checkbox(
                value: item.isCompleted,
                onChanged: settings.saving
                    ? null
                    : (_) => save(() => settings.toggleNote(item.id)),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(item.dateText),
              trailing: IconButton(
                tooltip: 'Delete note',
                onPressed: settings.saving
                    ? null
                    : () => save(() => settings.deleteNote(item.id)),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
