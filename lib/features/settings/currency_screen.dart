import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/currency.dart';
import '../../util/money.dart';
import '../../widgets/currency_picker.dart';

/// Pick the app's display currency. Amounts are never converted.
class CurrencyScreen extends ConsumerWidget {
  const CurrencyScreen({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, Currency current, Currency next) async {
    final navigator = Navigator.of(context);
    if (next == current) {
      navigator.pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch to ${next.name}?'),
        content: Text(
          'Amounts are not converted, they keep the numbers you entered. '
          'For example ${formatFils(12750, currency: current)} will show as '
          '${formatFils(12750, currency: next)}.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Switch')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(settingsProvider.notifier).setCurrency(next.code);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsProvider.select((s) => s.currency));
    return Scaffold(
      appBar: AppBar(title: const Text('Currency')),
      body: CurrencyPicker(selected: current, onSelected: (c) => _choose(context, ref, current, c)),
    );
  }
}
