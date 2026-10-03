import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/app_settings.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import 'month_setup_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final period = ref.watch(currentPeriodProvider);
    final summary = ref.watch(budgetSummaryProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _Header('Budget'),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('This month\'s plan'),
            subtitle: Text(
              summary == null || !summary.hasPlan
                  ? 'Not set yet'
                  : 'Spendable ${formatFils(summary.spendableFils)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MonthSetupScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text('Month starts on day'),
            subtitle: Text('Current month: ${formatPeriod(period)}'),
            trailing: DropdownButton<int>(
              value: settings.monthStartDay,
              underline: const SizedBox.shrink(),
              menuMaxHeight: 400,
              items: [for (var d = 1; d <= 31; d++) DropdownMenuItem(value: d, child: Text('$d'))],
              onChanged: (d) => d == null ? null : notifier.setMonthStartDay(d),
            ),
          ),
          if (settings.monthStartDay > 28)
            const Padding(
              padding: EdgeInsets.fromLTRB(72, 0, 16, 8),
              child: Text('In shorter months the budget month starts on the last day.'),
            ),
          ListTile(
            leading: const Icon(Icons.view_week_outlined),
            title: const Text('Week starts on'),
            trailing: DropdownButton<int>(
              value: settings.weekStartDay,
              underline: const SizedBox.shrink(),
              items: [
                for (final MapEntry(:key, :value) in AppSettings.weekStartChoices.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (d) => d == null ? null : notifier.setWeekStartDay(d),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
