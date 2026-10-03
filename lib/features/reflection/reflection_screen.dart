import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../models/enums.dart';
import '../../theme.dart';
import '../../util/period.dart';
import '../../widgets/money_text.dart';
import 'reflection_form_screen.dart';

String reflectionTitle(ReflectionType type, Period p) =>
    type == ReflectionType.weekly ? 'Week of ${formatDay(p.start)}' : formatPeriod(p);

/// Weekly and monthly reflections: what's due, and the saved history.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  ReflectionType _type = ReflectionType.weekly;

  List<(String, Period)> _duePeriods() {
    final settings = ref.watch(settingsProvider);
    final now = DateTime.now();
    if (_type == ReflectionType.weekly) {
      final week = weekFor(now, settings.weekStartDay);
      final last = weekFor(week.start.subtract(const Duration(hours: 12)), settings.weekStartDay);
      return [('This week', week), ('Last week', last)];
    }
    final month = ref.watch(currentPeriodProvider);
    return [
      ('This month', month),
      ('Last month', previousBudgetMonth(month, settings.monthStartDay)),
    ];
  }

  void _open(Period period) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReflectionFormScreen(type: _type, period: period),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = ref.watch(reflectionsProvider(_type));
    final saved = history.value ?? const <Reflection>[];
    final done = {for (final r in saved) r.periodStart};

    return Scaffold(
      appBar: AppBar(title: const Text('Reflect')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          SegmentedButton<ReflectionType>(
            segments: const [
              ButtonSegment(value: ReflectionType.weekly, label: Text('Weekly')),
              ButtonSegment(value: ReflectionType.monthly, label: Text('Monthly')),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          Text(
            'Kakeibo asks four questions: how much you had, how much you wanted to save, '
            'how much you spent, and how you can improve.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          for (final (label, period) in _duePeriods()) ...[
            _DueCard(
              label: label,
              period: period,
              done: done.contains(period.start),
              onTap: () => _open(period),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          Text('History', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          if (saved.isEmpty)
            Text(
              'Your saved reflections will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (i, r) in saved.indexed) ...[
                    if (i > 0) const Divider(indent: 16),
                    _HistoryTile(
                      reflection: r,
                      title: reflectionTitle(r.type, _periodOf(r)),
                      onTap: () => _open(_periodOf(r)),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Period _periodOf(Reflection r) {
    final start = r.periodStart;
    if (r.type == ReflectionType.weekly) {
      return Period(start, DateTime(start.year, start.month, start.day + 7));
    }
    final month = budgetMonthFor(start, ref.read(settingsProvider).monthStartDay);
    // Saved under a different month start day: assume a one-month span.
    return month.start == start
        ? month
        : Period(start, DateTime(start.year, start.month + 1, start.day));
  }
}

class _DueCard extends StatelessWidget {
  const _DueCard({
    required this.label,
    required this.period,
    required this.done,
    required this.onTap,
  });

  final String label;
  final Period period;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: done
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.edit_note_rounded,
                  color: done ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleSmall),
                    Text(
                      formatPeriod(period),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                done ? 'Done' : 'Reflect',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: done ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.reflection, required this.title, required this.onTap});

  final Reflection reflection;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = reflection;
    final note = r.improveNote.isNotEmpty ? r.improveNote : 'No notes';
    return ListTile(
      onTap: onTap,
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(r.spentFils, size: 16),
          Text(
            'spent',
            style: moneyStyle(theme.textTheme.labelSmall)
                .copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
