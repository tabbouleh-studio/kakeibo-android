import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../models/day_group.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import '../../widgets/money_text.dart';
import '../entry/entry_screen.dart';
import 'delete_entry.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  final _search = TextEditingController();
  bool _searching = false;

  /// Swiped away but maybe not yet gone from the stream; hidden so the
  /// Dismissible leaves the tree immediately.
  final Set<int> _hidden = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _search.clear();
      ref.read(ledgerSearchProvider.notifier).set('');
    }
  }

  Future<void> _delete(Entry entry) async {
    setState(() => _hidden.add(entry.id));
    await deleteWithUndo(
      context,
      ref,
      entry,
      onUndo: () {
        if (mounted) setState(() => _hidden.remove(entry.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(ledgerSearchProvider).trim();
    final showingSearch = _searching && query.isNotEmpty;
    final entries = ref.watch(showingSearch ? searchResultsProvider : ledgerEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _search,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search notes, categories, amounts',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: ref.read(ledgerSearchProvider.notifier).set,
              )
            : const Text('Ledger'),
        centerTitle: !_searching,
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search',
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_searching) const _MonthSwitcher(),
          Expanded(
            child: entries.when(
              data: (list) {
                final visible = [
                  for (final e in list)
                    if (!_hidden.contains(e.id)) e,
                ];
                if (_searching && query.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.search_rounded,
                    title: 'Search all months',
                    message:
                        'Try a note like “coffee”, a category like “Culture”, '
                        'or an amount like 2.5',
                  );
                }
                if (visible.isEmpty) {
                  return showingSearch
                      ? const _EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matches',
                          message: 'Nothing found for that search.',
                        )
                      : const _EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'A clean page',
                          message: 'No expenses in this month yet.',
                        );
                }
                return _EntryList(entries: visible, onDelete: _delete);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load entries.\n$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  const _MonthSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(ledgerPeriodProvider);
    final notifier = ref.read(ledgerPeriodProvider.notifier);
    final entries = ref.watch(ledgerEntriesProvider).value ?? const [];
    final total = entries.fold<int>(0, (sum, e) => sum + e.amountFils);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  notifier.previous();
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(formatPeriod(period), style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${formatFils(total)} · ${entries.length} '
                      '${entries.length == 1 ? 'entry' : 'entries'}',
                      style: moneyStyle(theme.textTheme.bodySmall)
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: notifier.canGoNext
                    ? () {
                        HapticFeedback.selectionClick();
                        notifier.next();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries, required this.onDelete});

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
                      formatFils(group.totalFils),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.message});

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
