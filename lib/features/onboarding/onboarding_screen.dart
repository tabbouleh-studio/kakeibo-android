import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/currency.dart';
import '../../theme.dart';
import '../../util/region.dart';
import '../../widgets/currency_picker.dart';
import '../../widgets/day_grid.dart';
import '../settings/backup_actions.dart';
import '../settings/month_setup_screen.dart';

/// First-launch setup: welcome, currency, month start, done.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 4;

  final _pages = PageController();
  int _page = 0;
  late final bool _fromRegion;
  Currency? _currency;
  int _monthStartDay = 1;

  @override
  void initState() {
    super.initState();
    _currency = currencyForRegion(phoneRegion());
    _fromRegion = _currency != null;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) {
    FocusScope.of(context).unfocus();
    setState(() => _page = page);
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish({required bool planNow}) async {
    final navigator = Navigator.of(context);
    final settings = ref.read(settingsProvider.notifier);
    await settings.setCurrency(_currency!.code);
    await settings.setMonthStartDay(_monthStartDay);
    await settings.setOnboardingDone();
    if (planNow) {
      // The app swaps this screen for Home; open the plan on top of it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.push(MaterialPageRoute(builder: (_) => const MonthSetupScreen()));
      });
    }
  }

  Future<void> _restore() async {
    if (await runRestore(context, ref)) {
      await ref.read(settingsProvider.notifier).setOnboardingDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = switch (_page) {
      1 => _currency != null,
      _ => true,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(onRestore: _restore),
                  _CurrencyPage(
                    currency: _currency,
                    fromRegion: _fromRegion,
                    onChanged: (c) => setState(() => _currency = c),
                  ),
                  _MonthStartPage(
                    day: _monthStartDay,
                    onChanged: (d) => setState(() => _monthStartDay = d),
                  ),
                  _ReadyPage(onFinish: _finish),
                ],
              ),
            ),
            if (_page < _pageCount - 1)
              _BottomBar(
                page: _page,
                pageCount: _pageCount,
                canContinue: canContinue,
                onBack: _page == 0 ? null : () => _go(_page - 1),
                onNext: () => _go(_page + 1),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.pageCount,
    required this.canContinue,
    required this.onBack,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final bool canContinue;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: onBack == null ? null : TextButton(onPressed: onBack, child: const Text('Back')),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pageCount; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == page
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: canContinue ? onNext : null,
            child: Text(page == 0 ? 'Get started' : 'Next'),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onRestore});

  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = KakeiboColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: colors.hero, shape: BoxShape.circle),
            child: Icon(Icons.menu_book_rounded, size: 44, color: colors.onHero),
          ),
        ),
        const SizedBox(height: 24),
        Text('家計簿', textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Welcome to Kakeibo',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'A calm way to budget, based on the Japanese method of mindful spending: '
          'plan your month, write down what you spend, and reflect on how to improve.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                for (final (icon, text) in const [
                  (Icons.wifi_off_rounded, 'Works fully offline'),
                  (Icons.person_off_outlined, 'No account, no ads, no tracking'),
                  (Icons.phone_android_rounded, 'Your data never leaves this phone'),
                ])
                  ListTile(
                    dense: true,
                    leading: Icon(icon, color: theme.colorScheme.primary),
                    title: Text(text, style: theme.textTheme.bodyLarge),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.settings_backup_restore_rounded),
            label: const Text('Moving phones? Restore a backup'),
          ),
        ),
      ],
    );
  }
}

class _CurrencyPage extends StatelessWidget {
  const _CurrencyPage({required this.currency, required this.fromRegion, required this.onChanged});

  final Currency? currency;
  final bool fromRegion;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Which currency do you use?',
          subtitle: fromRegion
              ? 'Suggested from your phone’s region setting. This is checked on your phone '
                    'only. You can change it any time in Settings.'
              : 'Pick the currency for your budget. You can change it any time in Settings.',
        ),
        Expanded(
          child: CurrencyPicker(selected: currency, onSelected: onChanged),
        ),
      ],
    );
  }
}

class _MonthStartPage extends StatelessWidget {
  const _MonthStartPage({required this.day, required this.onChanged});

  final int day;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        const _PageHeader(
          title: 'When does your month start?',
          subtitle:
              'Choose your payday so each budget month runs from one salary to the next. '
              'Most people keep day 1.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DayGrid(selected: day, onSelected: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Text(
            'Days 29–31 use the last day of shorter months.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({required this.onFinish});

  final Future<void> Function({required bool planNow}) onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Icon(Icons.check_circle_rounded, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 20),
          Text("You're all set", style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Kakeibo starts with intention. Write down your income, fixed costs and '
            'savings goal, and see what is left to spend this month.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => onFinish(planNow: true),
              child: const Text('Plan my first month'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => onFinish(planNow: false),
              child: const Text('Explore first'),
            ),
          ),
        ],
      ),
    );
  }
}
