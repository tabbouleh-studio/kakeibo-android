import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../util/money.dart';

/// Deletes [entry] and offers to undo it from a snackbar.
Future<void> deleteWithUndo(
  BuildContext context,
  WidgetRef ref,
  Entry entry, {
  VoidCallback? onUndo,
}) async {
  final db = ref.read(databaseProvider);
  final messenger = ScaffoldMessenger.of(context);
  await db.deleteEntry(entry.id);
  HapticFeedback.mediumImpact();
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text('Deleted ${formatFils(entry.amountFils)} · ${entry.category.label}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            onUndo?.call();
            db.restoreEntry(entry);
          },
        ),
      ),
    );
}
