import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/providers.dart';
import '../../models/app_settings.dart';
import '../../util/period.dart';
import '../../app_info.dart';
import '../about/about_screen.dart';
import '../lock/app_gate.dart';
import '../../widgets/day_grid.dart';
import 'backup_actions.dart';
import 'currency_screen.dart';
import 'month_setup_screen.dart';
import 'recurring_screen.dart';
import '../../widgets/money_scope.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final period = ref.watch(currentPeriodProvider);
    final summary = ref.watch(budgetSummaryProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _GroupLabel('Budget'),
          _Group(
            children: [
              _Tile(
                icon: Icons.edit_note_rounded,
                title: 'This month’s plan',
                subtitle: summary == null || !summary.hasPlan
                    ? 'Not set yet'
                    : 'Spendable ${context.money(summary.spendableFils)}',
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MonthSetupScreen())),
              ),
              _Tile(
                icon: Icons.event_repeat_rounded,
                title: 'Month starts on',
                subtitle: 'Day ${settings.monthStartDay} · now ${formatPeriod(period)}',
                onTap: () => _pickMonthStart(context, ref, settings.monthStartDay),
              ),
              _Tile(
                icon: Icons.repeat_rounded,
                title: 'Recurring entries',
                subtitle: switch (ref.watch(recurringItemsProvider).value?.length ?? 0) {
                  0 => 'Subscriptions and other repeating expenses',
                  1 => '1 recurring entry',
                  final n => '$n recurring entries',
                },
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const RecurringScreen())),
              ),
              _Tile(
                icon: Icons.payments_outlined,
                title: 'Currency',
                subtitle: '${settings.currency.name} (${settings.currency.code})',
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const CurrencyScreen())),
              ),
              _Tile(
                icon: Icons.view_week_outlined,
                title: 'Week starts on',
                subtitle: AppSettings.weekStartChoices[settings.weekStartDay] ?? 'Sunday',
                onTap: () => _pickWeekStart(context, ref, settings.weekStartDay),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _GroupLabel('Appearance'),
          _Group(
            children: [
              _Tile(
                icon: switch (settings.themeMode) {
                  ThemeMode.light => Icons.light_mode_outlined,
                  ThemeMode.dark => Icons.dark_mode_outlined,
                  ThemeMode.system => Icons.brightness_auto_outlined,
                },
                title: 'Theme',
                subtitle: AppSettings.themeModeLabels[settings.themeMode]!,
                onTap: () => _pickTheme(context, ref, settings.themeMode),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _GroupLabel('Privacy'),
          _Group(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: _IconBox(icon: Icons.lock_outline_rounded),
                title: Text('App lock', style: theme.textTheme.titleSmall),
                subtitle: Text(
                  'Use your fingerprint, face or phone PIN to open Kakeibo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.lockEnabled,
                onChanged: (on) => _setLock(context, ref, on),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                secondary: const _IconBox(icon: Icons.visibility_off_outlined),
                title: Text('Hide amounts', style: theme.textTheme.titleSmall),
                subtitle: Text(
                  'Show •••• instead of numbers. Tap the eye on Home to peek',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.hideAmounts,
                onChanged: ref.read(settingsProvider.notifier).setHideAmounts,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _GroupLabel('Your data'),
          _Group(
            children: [
              _Tile(
                icon: Icons.save_alt_rounded,
                title: 'Back up',
                subtitle: settings.lastBackupAt == null
                    ? 'Never backed up'
                    : 'Last backup ${DateFormat('d MMM y').format(settings.lastBackupAt!)}',
                onTap: () => runBackup(context, ref),
              ),
              _Tile(
                icon: Icons.settings_backup_restore_rounded,
                title: 'Restore from backup',
                subtitle: 'Replaces all data on this phone',
                onTap: () => runRestore(context, ref),
              ),
              if (ref.watch(undoRestoreProvider) != null)
                _Tile(
                  icon: Icons.undo_rounded,
                  title: 'Undo last restore',
                  subtitle: 'Bring back the data from before the restore',
                  onTap: () => undoRestore(ref, ScaffoldMessenger.of(context)),
                ),
              _Tile(
                icon: Icons.table_chart_outlined,
                title: 'Export CSV',
                subtitle: 'All expenses, for Excel',
                onTap: () => runCsvExport(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Group(
            children: [
              _Tile(
                icon: Icons.info_outline_rounded,
                title: 'About Kakeibo',
                subtitle: 'Version $appVersion · Free and open source',
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text('家計簿', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Kakeibo works fully offline.\nYour data never leaves this phone.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Made with ❤️ by Tabbouleh Studio 🥗',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setLock(BuildContext context, WidgetRef ref, bool on) async {
    final notifier = ref.read(settingsProvider.notifier);
    if (!on) return notifier.setLockEnabled(false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!await ref.read(localAuthProvider).isDeviceSupported()) {
        messenger.showSnackBar(const SnackBar(content: Text('This phone can’t lock apps.')));
        return;
      }
      if (await authenticate(ref, 'Confirm to turn on app lock')) {
        await notifier.setLockEnabled(true);
      }
    } on LocalAuthException catch (e) {
      final text = e.code == LocalAuthExceptionCode.noCredentialsSet
          ? 'Set up a screen lock on your phone first.'
          : 'App lock not turned on: ${e.description ?? e.code.name}';
      messenger.showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref, ThemeMode current) async {
    final mode = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final (mode, icon) in const [
              (ThemeMode.system, Icons.brightness_auto_outlined),
              (ThemeMode.light, Icons.light_mode_outlined),
              (ThemeMode.dark, Icons.dark_mode_outlined),
            ])
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(icon),
                title: Text(AppSettings.themeModeLabels[mode]!),
                subtitle: mode == ThemeMode.system
                    ? const Text('Follows your phone’s light or dark setting')
                    : null,
                trailing: mode == current
                    ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (mode != null) await ref.read(settingsProvider.notifier).setThemeMode(mode);
  }

  Future<void> _pickMonthStart(BuildContext context, WidgetRef ref, int current) async {
    final day = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _MonthStartSheet(current: current),
    );
    if (day != null) await ref.read(settingsProvider.notifier).setMonthStartDay(day);
  }

  Future<void> _pickWeekStart(BuildContext context, WidgetRef ref, int current) async {
    final day = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Week starts on', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final MapEntry(:key, :value) in AppSettings.weekStartChoices.entries)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(value),
                trailing: key == current
                    ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(key),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (day != null) await ref.read(settingsProvider.notifier).setWeekStartDay(day);
  }
}

class _MonthStartSheet extends StatelessWidget {
  const _MonthStartSheet({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Month starts on day', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Pick your salary day. Days 29–31 use the last day of shorter months.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            DayGrid(selected: current, onSelected: (d) => Navigator.of(context).pop(d)),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const Divider(indent: 64),
            child,
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: icon),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
    );
  }
}
