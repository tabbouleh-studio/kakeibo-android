import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../models/day_group.dart';
import '../../theme.dart';
import '../../util/period.dart';
import '../../widgets/money_scope.dart';
import '../../widgets/money_text.dart';
import '../entry/entry_screen.dart';

/// Entries grouped by day, each tappable to edit and swipeable to delete.
class EntryList extends StatelessWidget {
  const EntryList({super.key, required this.entries, required this.onDelete});

  final List<Entry> entries;
  final ValueChanged<Entry> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = groupByDay(entries, dateOf: (e) => e.date, filsOf: (e) => e.amountFils);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final group = groups[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Text(
                      formatDay(group.day),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.money(group.totalFils),
                      style: moneyStyle(theme.textTheme.bodySmall)
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (j, entry) in group.items.indexed) ...[
                      if (j > 0) const Divider(indent: 68),
                      _EntryRow(entry: entry, onDelete: () => onDelete(entry)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onDelete});

  final Entry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = entry.category.color(theme.brightness);
    final hasNote = entry.note.isNotEmpty;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(entry.category.icon, color: color, size: 20),
        ),
        title: Text(
          hasNote ? entry.note : entry.category.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge,
        ),
        subtitle: hasNote || entry.recurringId != null
            ? Text.rich(
                TextSpan(
                  children: [
                    if (entry.recurringId != null)
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.repeat_rounded, size: 14),
                        ),
                      ),
                    TextSpan(text: entry.category.label),
                  ],
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: MoneyText(entry.amountFils, size: 18),
        onTap: () =>
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => EntryScreen(entry: entry))),
      ),
    );
  }
}

/// Icon, title and short message for an empty list.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
