import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/backup.dart';
import '../../data/csv_export.dart';
import '../../data/providers.dart';

String _stamp() => DateFormat('yyyy-MM-dd').format(DateTime.now());

void _toast(ScaffoldMessengerState messenger, String text) => messenger
  ..clearSnackBars()
  ..showSnackBar(SnackBar(content: Text(text)));

/// Writes a JSON backup to a location the user picks.
Future<void> runBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final data = await createBackup(ref.read(databaseProvider), _currentSettings(ref));
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Save backup',
      fileName: 'kakeibo-backup-${_stamp()}.json',
      bytes: utf8.encode(data.encode()),
      mimeType: 'application/json',
    );
    if (uri == null) return; // cancelled
    await ref.read(settingsProvider.notifier).setLastBackupAt(DateTime.now());
    _toast(messenger, 'Backup saved. Copy it to your laptop to keep it safe.');
  } catch (e) {
    _toast(messenger, 'Backup failed: $e');
  }
}

/// Exports all entries as CSV.
Future<void> runCsvExport(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final settings = ref.read(settingsProvider);
  try {
    final entries = await ref.read(databaseProvider).allEntries();
    if (entries.isEmpty) {
      _toast(messenger, 'No expenses to export yet.');
      return;
    }
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Export expenses',
      fileName: 'kakeibo-expenses-${_stamp()}.csv',
      bytes: entriesToCsv(entries, currency: settings.currency),
      mimeType: 'text/csv',
    );
    if (uri != null) _toast(messenger, 'Exported ${entries.length} expenses.');
  } catch (e) {
    _toast(messenger, 'Export failed: $e');
  }
}

/// Picks a backup file, validates it, confirms, then replaces all data.
Future<void> runRestore(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final BackupData data;
  try {
    final file = await FilePicker.pickFile(dialogTitle: 'Choose a Kakeibo backup');
    if (file == null) return; // cancelled
    final String text;
    try {
      text = utf8.decode(await file.readAsBytes());
    } on FormatException {
      throw const BackupFormatException('The file is not a text file.');
    }
    data = BackupData.decode(text);
  } on BackupFormatException catch (e) {
    if (context.mounted) await _showError(context, e.message);
    return;
  } catch (e) {
    _toast(messenger, 'Could not open the file: $e');
    return;
  }
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmRestoreDialog(data: data),
  );
  if (confirmed != true) return;

  try {
    final db = ref.read(databaseProvider);
    // Safety copy of what's on the phone now, so the restore can be undone.
    final before = await createBackup(db, _currentSettings(ref));
    await restoreBackup(db, data);
    await ref.read(settingsProvider.notifier).applyBackup(data.settings);
    ref.read(undoRestoreProvider.notifier).set(before);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('Backup restored.'),
          duration: const Duration(seconds: 20),
          action: SnackBarAction(label: 'Undo', onPressed: () => undoRestore(ref, messenger)),
        ),
      );
  } catch (e) {
    // The restore runs in one transaction, so nothing changed.
    _toast(messenger, 'Restore failed, your data was not changed: $e');
  }
}

/// Puts back the data that was on the phone before the last restore.
Future<void> undoRestore(WidgetRef ref, ScaffoldMessengerState messenger) async {
  final before = ref.read(undoRestoreProvider);
  if (before == null) return;
  try {
    await restoreBackup(ref.read(databaseProvider), before);
    await ref.read(settingsProvider.notifier).applyBackup(before.settings);
    ref.read(undoRestoreProvider.notifier).set(null);
    _toast(messenger, 'Restore undone. Your previous data is back.');
  } catch (e) {
    _toast(messenger, 'Could not undo the restore: $e');
  }
}

BackupSettings _currentSettings(WidgetRef ref) {
  final s = ref.read(settingsProvider);
  return BackupSettings(
    monthStartDay: s.monthStartDay,
    weekStartDay: s.weekStartDay,
    lockEnabled: s.lockEnabled,
    currencyCode: s.currencyCode,
    hideAmounts: s.hideAmounts,
    themeMode: s.themeMode.name,
  );
}

Future<void> _showError(BuildContext context, String message) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: const Icon(Icons.error_outline_rounded),
    title: const Text('Can’t restore this file'),
    content: Text(message),
    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
  ),
);

class _ConfirmRestoreDialog extends StatelessWidget {
  const _ConfirmRestoreDialog({required this.data});

  final BackupData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = DateFormat('d MMM y');
    final dates = [for (final e in data.entries) e.date]..sort();
    String count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

    return AlertDialog(
      icon: const Icon(Icons.settings_backup_restore_rounded),
      title: const Text('Restore this backup?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Made on ${DateFormat('d MMM y, HH:mm').format(data.exportedAt)}. It contains:'),
          const SizedBox(height: 12),
          for (final line in [
            count(data.entries.length, 'expense', 'expenses') +
                (dates.isEmpty ? '' : ' (${day.format(dates.first)} – ${day.format(dates.last)})'),
            count(data.monthPlans.length, 'month plan', 'month plans'),
            count(data.reflections.length, 'reflection', 'reflections'),
            count(data.recurringItems.length, 'recurring item', 'recurring items'),
          ])
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('•  $line')),
          const SizedBox(height: 12),
          Text(
            'This replaces everything currently on this phone.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            minimumSize: const Size(0, 44),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Replace everything'),
        ),
      ],
    );
  }
}
