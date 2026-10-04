import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../models/budget_summary.dart';
import '../../models/enums.dart';
import '../../theme.dart';
import '../../util/period.dart';
import '../../widgets/money_text.dart';
import '../settings/backup_actions.dart';
import '../settings/month_setup_screen.dart';
import 'category_screen.dart';
import 'progress_widgets.dart';
import '../../widgets/money_scope.dart';

void _open(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(budgetSummaryProvider);
    final period = ref.watch(currentPeriodProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: summary.when(
          data: (s) => _HomeBody(summary: s, period: period),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load your data.\n$e', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.summary, required this.period});

  final BudgetSummary summary;
  final Period period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasData = summary.hasPlan || summary.spentFils > 0;
    final remind = hasData && ref.watch(backupReminderProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const _Header(),
        const SizedBox(height: 20),
        if (remind) ...[const _BackupBanner(), const SizedBox(height: 12)],
        if (summary.hasPlan)
          _HeroCard(summary: summary, period: period)
        else
          _StartCard(period: period, spentFils: summary.spentFils),
        if (summary.hasPlan && summary.savingsGoalFils > 0) ...[
          const SizedBox(height: 12),
          _SavingsCard(summary: summary),
        ],
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Categories', style: theme.textTheme.titleLarge),
            const SizedBox(width: 12),
            if (summary.spentFils > 0)
              Expanded(
                child: Text(
                  '${context.money(summary.spentFils)} spent',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: moneyStyle(theme.textTheme.bodyMedium)
                      .copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
        if (summary.spentFils == 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Nothing recorded yet. Tap + below to log your first one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 12),
        _CategoryGrid(summary: summary),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masking = ref.watch(settingsProvider.select((s) => s.hideAmounts));
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text('Kakeibo', style: theme.textTheme.headlineMedium),
            ],
          ),
        ),
        if (masking)
          IconButton.filledTonal(
            tooltip: context.amountsHidden ? 'Show amounts' : 'Hide amounts',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              foregroundColor: theme.colorScheme.onSurface,
            ),
            icon: Icon(
              context.amountsHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            ),
            onPressed: ref.read(amountsRevealedProvider.notifier).toggle,
          ),
      ],
    );
  }
}

/// In-app reminder when the last backup is over 30 days old (or never).
class _BackupBanner extends ConsumerWidget {
  const _BackupBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final last = ref.watch(settingsProvider.select((s) => s.lastBackupAt));
    final days = last == null ? null : daysBetween(last, DateTime.now());
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 0, 4),
        child: Row(
          children: [
            Icon(Icons.save_alt_rounded, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                days == null ? 'Not backed up yet' : 'Last backup $days days ago',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: () => runBackup(context, ref), child: const Text('Back up')),
            IconButton(
              tooltip: 'Remind me later',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.close_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
              onPressed: ref.read(backupReminderProvider.notifier).snooze,
            ),
          ],
        ),
      ),
    );
  }
}

/// The main card: what's left, a daily allowance and the month's spending bar.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary, required this.period});

  final BudgetSummary summary;
  final Period period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = KakeiboColors.of(context);
    final on = colors.onHero;
    final soft = on.withValues(alpha: 0.72);
    final today = DateTime.now();
    final daysLeft = daysBetween(today, period.end).clamp(1, 366);
    final elapsed = (daysBetween(period.start, today) + 1) / period.lengthInDays;
    final over = summary.leftFils < 0;
    final spendable = summary.spendableFils;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(color: colors.hero, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                over ? 'OVER BUDGET' : 'LEFT TO SPEND',
                style: theme.textTheme.labelMedium?.copyWith(color: soft, letterSpacing: 1.4),
              ),
              const Spacer(),
              _Pill(text: formatPeriod(period), color: on),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(
              summary.leftFils.abs(),
              size: 52,
              color: over ? const Color(0xFFFFB4A2) : on,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            over
                ? 'Spent more than planned, with $daysLeft ${_days(daysLeft)} to go'
                : 'About ${context.money(summary.leftFils ~/ daysLeft)} a day · '
                      '$daysLeft ${_days(daysLeft)} left',
            style: moneyStyle(theme.textTheme.bodyMedium).copyWith(color: soft),
          ),
          const SizedBox(height: 18),
          SegmentedBar(
            track: on.withValues(alpha: 0.16),
            markerColor: on,
            marker: elapsed,
            segments: [
              for (final c in SpendCategory.values)
                (
                  value: spendable <= 0
                      ? (summary.spentFils == 0
                            ? 0
                            : summary.spentByCategory[c]! / summary.spentFils)
                      : summary.spentByCategory[c]! / spendable,
                  color: c.pastel,
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const labelWidth = 44.0;
              final x = constraints.maxWidth * elapsed.clamp(0.0, 1.0) - labelWidth / 2;
              return Padding(
                padding: EdgeInsets.only(left: x.clamp(0.0, constraints.maxWidth - labelWidth)),
                child: SizedBox(
                  width: labelWidth,
                  child: Text(
                    'today',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(color: soft),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Spent ${context.money(summary.spentFils)}',
                style: moneyStyle(theme.textTheme.bodySmall).copyWith(color: soft),
              ),
              const Spacer(),
              Text(
                'of ${context.money(spendable)}',
                style: moneyStyle(theme.textTheme.bodySmall).copyWith(color: soft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _days(int n) => n == 1 ? 'day' : 'days';
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
    );
  }
}

/// Shown until this month has a plan.
class _StartCard extends StatelessWidget {
  const _StartCard({required this.period, required this.spentFils});

  final Period period;
  final int spentFils;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = KakeiboColors.of(context);
    final on = colors.onHero;
    final soft = on.withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: colors.hero, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('家計簿', style: theme.textTheme.titleMedium?.copyWith(color: soft)),
              const Spacer(),
              _Pill(text: formatPeriod(period), color: on),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Start your month with intention',
            style: theme.textTheme.headlineSmall?.copyWith(color: on),
          ),
          const SizedBox(height: 8),
          Text(
            'Write down what comes in, what must go out and what you want to save. '
            'What remains is yours to spend.',
            style: theme.textTheme.bodyMedium?.copyWith(color: soft, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, step) in ['Income', 'Fixed costs', 'Savings goal'].indexed)
                _Pill(text: '${i + 1}  $step', color: on),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: on, foregroundColor: colors.hero),
              onPressed: () => _open(context, const MonthSetupScreen()),
              child: const Text('Plan this month'),
            ),
          ),
          if (spentFils > 0) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${context.money(spentFils)} spent so far',
                style: moneyStyle(theme.textTheme.bodySmall).copyWith(color: soft),
              ),
            ),
          ],
        ],
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
    final color = eaten ? theme.colorScheme.error : theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            ProgressRing(
              value: summary.savingsProgress,
              color: color,
              size: 64,
              strokeWidth: 7,
              child: Text(
                '${(summary.savingsProgress * 100).round()}%',
                style: moneyStyle(theme.textTheme.labelMedium)
                    .copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Savings', style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: MoneyText(summary.savedFils, size: 22),
                  ),
                  Text(
                    'of ${context.money(summary.savingsGoalFils)} goal',
                    style: moneyStyle(theme.textTheme.bodySmall).copyWith(color: muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    !eaten
                        ? 'On track, stay within budget'
                        : summary.overBudgetFils > 0
                        ? 'Savings used up, plus ${context.money(summary.overBudgetFils)} over'
                        : 'Overspending is eating into your savings',
                    style: theme.textTheme.bodySmall?.copyWith(color: eaten ? color : muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final cats = SpendCategory.values;
    return Column(
      children: [
        for (var i = 0; i < cats.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CategoryTile(category: cats[i], summary: summary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoryTile(category: cats[i + 1], summary: summary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.summary});

  final SpendCategory category;
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color(theme.brightness);
    final share = summary.categoryShare(category);
    final spent = summary.spentByCategory[category]!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context, CategoryScreen(category: category)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (spent > 0)
                    Text(
                      '${(share * 100).round()}%',
                      style: moneyStyle(theme.textTheme.labelMedium)
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                category.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: MoneyText(spent, size: 22),
              ),
              const SizedBox(height: 12),
              ProgressBar(value: share, color: color, height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
