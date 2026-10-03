import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../models/currency.dart';
import '../../models/enums.dart';
import '../../widgets/money_scope.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import '../ledger/delete_entry.dart';
import 'amount_keypad.dart';

/// Quick entry: type the amount, tap a category, tap Save.
/// With [entry], edits that entry instead.
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, this.entry});

  final Entry? entry;

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  String _amountText = '';
  SpendCategory? _category;
  DateTime _date = dateOnly(DateTime.now());
  final _note = TextEditingController();
  bool _saving = false;

  /// When editing, the first digit typed replaces the old amount.
  bool _replaceOnType = false;

  bool get _editing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (widget.entry case final e?) {
      _amountText = filsToInput(e.amountFils, currency: _currency);
      _replaceOnType = true;
      _category = e.category;
      _date = e.date;
      _note.text = e.note;
    }
  }

  Currency get _currency => ref.read(settingsProvider).currency;

  int get _amountFils => parseFils(_amountText, currency: _currency) ?? 0;
  bool get _canSave => _amountFils > 0 && _category != null && !_saving;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final category = _category!;
    final amount = _amountFils;
    final message = _editing
        ? 'Updated ${context.money(amount)} · ${category.label}'
        : 'Saved ${context.money(amount)} to ${category.label}';
    final db = ref.read(databaseProvider);
    if (widget.entry case final e?) {
      await db.updateEntry(
        e.copyWith(amountFils: amount, category: category, date: _date, note: _note.text),
      );
    } else {
      await db.addEntry(amountFils: amount, category: category, date: _date, note: _note.text);
    }
    navigator.pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _delete() {
    final navigator = Navigator.of(context);
    deleteWithUndo(context, ref, widget.entry!);
    navigator.pop();
  }

  String get _saveLabel {
    if (_amountFils == 0) return 'Enter an amount';
    if (_category == null) return 'Choose a category';
    return _editing ? 'Save changes' : 'Save ${formatFils(_amountFils, currency: _currency)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_editing ? 'Edit expense' : 'New expense'),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Taller phones get bigger keys instead of empty space.
            final keyHeight = (constraints.maxHeight * 0.095).clamp(56.0, 80.0);
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _AmountDisplay(text: _amountText),
                              const SizedBox(height: 14),
                              ActionChip(
                                avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                                label: Text(formatDay(_date)),
                                onPressed: _pickDate,
                                side: BorderSide.none,
                                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                                shape: const StadiumBorder(),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _note,
                                textCapitalization: TextCapitalization.sentences,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Add a note (optional)',
                                  prefixIcon: Icon(Icons.notes_rounded),
                                  suffixIcon: SizedBox(width: 48),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            for (final c in SpendCategory.values)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _CategoryButton(
                                    height: keyHeight + 20,
                                    category: c,
                                    selected: _category == c,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _category = c);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AmountKeypad(
                          keyHeight: keyHeight,
                          allowDecimal: _currency.decimals > 0,
                          onKey: (key) => setState(() {
                            final start = _replaceOnType && key != backspaceKey ? '' : _amountText;
                            _replaceOnType = false;
                            _amountText = applyAmountKey(start, key, decimals: _currency.decimals);
                          }),
                          onClear: () => setState(() => _amountText = ''),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: FilledButton(
                              onPressed: _canSave ? _save : null,
                              child: Text(_saveLabel, style: moneyStyle(null)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The typed amount, with fils digits still to come shown faintly.
class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.currency;
    final ink = theme.colorScheme.onSurface;
    final faint = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    final dot = text.indexOf('.');
    final whole = text.isEmpty ? '0' : (dot < 0 ? text : text.substring(0, dot));
    final typedFraction = dot < 0 ? '' : text.substring(dot + 1);
    final pendingFraction = '0' * (currency.decimals - typedFraction.length);
    final style = moneyStyle(
      const TextStyle(fontSize: 64, fontWeight: FontWeight.w600, height: 1.1),
    ).copyWith(color: text.isEmpty ? faint : ink, letterSpacing: -1.5);
    const small = TextStyle(fontSize: 34, letterSpacing: 0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(
              text: '${currency.symbol} ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
            TextSpan(text: whole),
            if (currency.decimals > 0) ...[
              TextSpan(
                text: '.',
                style: small.copyWith(color: dot < 0 ? faint : null),
              ),
              TextSpan(text: typedFraction, style: small),
              TextSpan(
                text: pendingFraction,
                style: small.copyWith(color: faint),
              ),
            ],
          ],
        ),
        semanticsLabel:
            'Amount ${formatFils(parseFils(text, currency: currency) ?? 0, currency: currency)}',
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.selected,
    required this.onTap,
    this.height = 80,
  });

  final SpendCategory category;
  final double height;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color(theme.brightness);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? color : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? Icons.check_circle_rounded : category.icon, color: color),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
