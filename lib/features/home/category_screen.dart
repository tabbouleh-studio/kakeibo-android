import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../models/enums.dart';
import '../../theme.dart';
import '../../util/period.dart';
import '../../widgets/money_text.dart';
import '../entry/entry_screen.dart';
import '../ledger/delete_entry.dart';
import '../ledger/entry_list.dart';
import 'progress_widgets.dart';

/// This month's expenses in one category, opened from a tile on Home.
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final SpendCategory category;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  /// Swiped away but maybe not yet gone from the stream.
  final Set<int> _hidden = {};

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
    final category = widget.category;
    final period = ref.watch(currentPeriodProvider);
    final all = ref.watch(currentEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add ${category.label} expense',
        onPressed: () =>
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => EntryScreen(initialCategory: category))),
        child: const Icon(Icons.add_rounded),
      ),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load expenses.\n$e')),
        data: (entries) {
          final totalSpent = entries.fold<int>(0, (sum, e) => sum + e.amountFils);
          final mine = [
            for (final e in entries)
              if (e.category == category && !_hidden.contains(e.id)) e,
          ];
          final spent = mine.fold<int>(0, (sum, e) => sum + e.amountFils);
          return Column(
            children: [
              _Summary(
                category: category,
                period: period,
                spentFils: spent,
                share: totalSpent == 0 ? 0 : spent / totalSpent,
                count: mine.length,
              ),
              Expanded(
                child: mine.isEmpty
                    ? EmptyState(
                        icon: category.icon,
                        title: 'Nothing here yet',
                        message: 'No ${category.label} expenses this month. ${category.hint}.',
                      )
                    : EntryList(entries: mine, onDelete: _delete),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.category,
    required this.period,
    required this.spentFils,
    required this.share,
    required this.count,
  });

  final SpendCategory category;
  final Period period;
  final int spentFils;
  final double share;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color(theme.brightness);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(category.icon, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: MoneyText(spentFils, size: 28),
                        ),
                        Text(
                          '${formatPeriod(period)} · $count ${count == 1 ? 'expense' : 'expenses'}',
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(share * 100).round()}%',
                    style: moneyStyle(theme.textTheme.titleLarge).copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressBar(value: share, color: color, height: 6),
              const SizedBox(height: 6),
              Text('Share of everything spent this month', style: muted),
            ],
          ),
        ),
      ),
    );
  }
}
