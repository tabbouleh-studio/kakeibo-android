import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../util/money.dart';

/// Searchable list of currencies.
class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({super.key, required this.selected, required this.onSelected});

  final Currency? selected;
  final ValueChanged<Currency> onSelected;

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  String _query = '';

  List<Currency> get _matches {
    final q = _query.trim().toLowerCase();
    final all = [
      // The selected currency first, so it's visible without scrolling.
      ?widget.selected,
      for (final c in Currency.all)
        if (c != widget.selected) c,
    ];
    if (q.isEmpty) return all;
    return [
      for (final c in all)
        if (c.code.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q) ||
            c.symbol.toLowerCase() == q)
          c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _matches;
    return Column(
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
                    final selected = c == widget.selected;
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
                      onTap: () => widget.onSelected(c),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
