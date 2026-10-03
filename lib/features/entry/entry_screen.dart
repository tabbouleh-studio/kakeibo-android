import 'package:flutter/material.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final category = _category!;
    await ref
        .read(databaseProvider)
        .addEntry(amountFils: _amountFils, category: category, date: _date, note: _note.text);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Saved ${formatFils(_amountFils)} · ${category.label}')),
    );
  }

  String _dateLabel() {
    final diff = daysBetween(_date, DateTime.now());
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE d MMM').format(_date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = _amountText.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('New expense')),
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
                        child: Center(
                          child: FittedBox(
                            child: Text(
                              'KD ${empty ? '0.000' : _amountText}',
                              style: moneyStyle(
                                theme.textTheme.displayMedium,
                              ).copyWith(color: empty ? theme.colorScheme.onSurfaceVariant : null),
                            ),
                          ),
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
                                  onTap: () => setState(() => _category = c),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _note,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Note (optional)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                            label: Text(_dateLabel()),
                            onPressed: _pickDate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AmountKeypad(
                        onKey: (key) =>
                            setState(() => _amountText = applyAmountKey(_amountText, key)),
                        onClear: () => setState(() => _amountText = ''),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _canSave ? _save : null,
                          child: const Text('Save'),
                        ),
                      ),
                      const SizedBox(height: 16),
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

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.category, required this.selected, required this.onTap});

  final SpendCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color(theme.brightness);
    return Material(
      color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? color : theme.colorScheme.outlineVariant, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: color),
              const SizedBox(height: 4),
              Text(category.label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
