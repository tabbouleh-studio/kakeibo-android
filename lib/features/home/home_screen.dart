import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/budget_summary.dart';
import '../../models/enums.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import '../entry/entry_screen.dart';
import '../settings/month_setup_screen.dart';
import '../settings/settings_screen.dart';
import 'progress_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(budgetSummaryProvider);
    final period = ref.watch(currentPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakeibo'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        tooltip: 'Add expense',
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EntryScreen())),
        child: const Icon(Icons.add),
      ),
      body: summary.when(
        data: (s) => _HomeBody(summary: s, period: period),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load your data.\n$e', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.summary, required this.period});

  final BudgetSummary summary;
  final Period period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = daysBetween(DateTime.now(), period.end);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        Text(
          '${formatPeriod(period)} · $daysLeft ${daysLeft == 1 ? 'day' : 'days'} left',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (!summary.hasPlan) ...[const _PlanPrompt(), const SizedBox(height: 12)],
        _LeftCard(summary: summary),
        const SizedBox(height: 12),
        if (summary.hasPlan && summary.savingsGoalFils > 0) ...[
          _SavingsCard(summary: summary),
          const SizedBox(height: 12),
        ],
        _CategoriesCard(summary: summary),
      ],
    );
  }
}

class _PlanPrompt extends StatelessWidget {
  const _PlanPrompt();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set your intentions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Enter this month\'s income, fixed costs and savings goal '
              'to see what you can spend.',
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const MonthSetupScreen())),
              child: const Text('Plan this month'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftCard extends StatelessWidget {
  const _LeftCard({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = summary.leftFils < 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.hasPlan ? (over ? 'Overspent' : 'Left to spend') : 'Spent this month',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              formatFils(summary.hasPlan ? summary.leftFils.abs() : summary.spentFils),
              style: moneyStyle(theme.textTheme.displaySmall)
                  .copyWith(color: over ? theme.colorScheme.error : null),
            ),
            if (summary.hasPlan) ...[
              const SizedBox(height: 4),
              Text(
                'Spent ${formatFils(summary.spentFils)} of ${formatFils(summary.spendableFils)}',
                style: moneyStyle(theme.textTheme.bodyMedium)
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eaten = summary.savedFils < summary.savingsGoalFils;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ProgressRing(
              value: summary.savingsProgress,
              color: eaten ? theme.colorScheme.error : theme.colorScheme.primary,
              child: Text(
                '${(summary.savingsProgress * 100).round()}%',
                style: moneyStyle(theme.textTheme.titleMedium),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Savings', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${formatFils(summary.savedFils)} of ${formatFils(summary.savingsGoalFils)}',
                    style: moneyStyle(theme.textTheme.bodyLarge),
                  ),
                  if (eaten) ...[
                    const SizedBox(height: 4),
                    Text(
                      summary.overBudgetFils > 0
                          ? 'Savings used up, plus ${formatFils(summary.overBudgetFils)} over'
                          : 'Overspending is eating into your savings',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending', style: theme.textTheme.titleSmall),
            if (summary.spentFils == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Nothing recorded yet. Tap + to add your first expense.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final c in SpendCategory.values) _CategoryRow(category: c, summary: summary),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.summary});

  final SpendCategory category;
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color(theme.brightness);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(category.label)),
              Text(
                formatFils(summary.spentByCategory[category]!),
                style: moneyStyle(theme.textTheme.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ProgressBar(value: summary.categoryFraction(category), color: color),
        ],
      ),
    );
  }
}
