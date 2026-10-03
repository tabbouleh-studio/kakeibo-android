import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../models/currency.dart';
import '../../util/money.dart';

/// Pick the app's display currency. Amounts are never converted.
class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  String _query = '';

  List<Currency> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return Currency.all;
    return [
      for (final c in Currency.all)
        if (c.code.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q) ||
            c.symbol.toLowerCase() == q)
          c,
    ];
  }

  Future<void> _choose(Currency current, Currency next) async {
    if (next == current) {
      Navigator.of(context).pop();
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
    if (confirmed != true || !mounted) return;
    await ref.read(settingsProvider.notifier).setCurrency(next.code);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = ref.watch(settingsProvider.select((s) => s.currency));
    final matches = _matches;

    return Scaffold(
      appBar: AppBar(title: const Text('Currency')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or code',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (q) => setState(() => _query = q),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? Center(
                    child: Text(
                      'No currency matches',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: matches.length,
                    itemBuilder: (context, i) {
                      final c = matches[i];
                      final selected = c == current;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        leading: Container(
                          width: 52,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(c.symbol, style: theme.textTheme.titleSmall),
                            ),
                          ),
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.code} · ${formatFils(1234500, currency: c)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: selected
                            ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                            : null,
                        onTap: () => _choose(current, c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
