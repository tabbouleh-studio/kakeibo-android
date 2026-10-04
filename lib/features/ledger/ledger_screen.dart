import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import 'delete_entry.dart';
import 'entry_list.dart';
import '../../widgets/money_scope.dart';

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
                  return EmptyState(
                    icon: Icons.search_rounded,
                    title: 'Search all months',
                    message:
                        'Try a note like “coffee”, a category like “Culture”, '
                        'or an amount like ${exampleAmount(context.currency)}',
                  );
                }
                if (visible.isEmpty) {
                  return showingSearch
                      ? const EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matches',
                          message: 'Nothing found for that search.',
                        )
                      : const EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'A clean page',
                          message: 'No expenses in this month yet.',
                        );
                }
                return EntryList(entries: visible, onDelete: _delete);
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
                      '${context.money(total)} · ${entries.length} '
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
