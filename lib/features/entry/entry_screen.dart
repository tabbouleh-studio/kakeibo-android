import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../models/enums.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import 'amount_keypad.dart';

/// Quick entry: type the amount, tap a category, tap Save.
class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key});

  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  String _amountText = '';
  SpendCategory? _category;
  DateTime _date = dateOnly(DateTime.now());
  final _note = TextEditingController();
  bool _saving = false;

  int get _amountFils => parseFils(_amountText) ?? 0;
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
      firstDate: DateTime(today.year - 5),
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
    await ref
        .read(databaseProvider)
        .addEntry(amountFils: amount, category: category, date: _date, note: _note.text);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Saved ${formatFils(amount)} to ${category.label}')),
    );
  }

  String _dateLabel() {
    final diff = daysBetween(_date, DateTime.now());
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE d MMM').format(_date);
  }

  String get _saveLabel {
    if (_amountFils == 0) return 'Enter an amount';
    if (_category == null) return 'Choose a category';
    return 'Save ${formatFils(_amountFils)}';
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
        title: const Text('New expense'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
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
                              label: Text(_dateLabel()),
                              onPressed: _pickDate,
                              side: BorderSide.none,
                              backgroundColor: theme.colorScheme.surfaceContainerHigh,
                              shape: const StadiumBorder(),
                            ),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _note,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Add a note',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AmountKeypad(
                        onKey: (key) =>
                            setState(() => _amountText = applyAmountKey(_amountText, key)),
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
          ),
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
    final ink = theme.colorScheme.onSurface;
    final faint = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    final dot = text.indexOf('.');
    final whole = text.isEmpty ? '0' : (dot < 0 ? text : text.substring(0, dot));
    final typedFils = dot < 0 ? '' : text.substring(dot + 1);
    final pendingFils = '000'.substring(typedFils.length);
    final style = moneyStyle(
      const TextStyle(fontSize: 64, fontWeight: FontWeight.w600, height: 1.1),
    ).copyWith(color: text.isEmpty ? faint : ink, letterSpacing: -1.5);
    final small = TextStyle(fontSize: 34, letterSpacing: 0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(
              text: 'KD ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
            TextSpan(text: whole),
            TextSpan(
              text: '.',
              style: small.copyWith(color: dot < 0 ? faint : null),
            ),
            TextSpan(text: typedFils, style: small),
            TextSpan(
              text: pendingFils,
              style: small.copyWith(color: faint),
            ),
          ],
        ),
        semanticsLabel: 'Amount ${formatFils(parseFils(text) ?? 0)}',
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.category, required this.selected, required this.onTap});

  final SpendCategory category;
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
            height: 80,
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
