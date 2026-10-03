import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../models/enums.dart';
import '../../models/reflection_numbers.dart';
import '../../theme.dart';
import '../../util/period.dart';
import '../../widgets/money_text.dart';
import '../home/progress_widgets.dart';
import 'reflection_screen.dart';
import '../../widgets/money_scope.dart';

/// The four Kakeibo questions for one week or month.
class ReflectionFormScreen extends ConsumerStatefulWidget {
  const ReflectionFormScreen({super.key, required this.type, required this.period});

  final ReflectionType type;
  final Period period;

  @override
  ConsumerState<ReflectionFormScreen> createState() => _ReflectionFormScreenState();
}

class _ReflectionFormScreenState extends ConsumerState<ReflectionFormScreen> {
  final _haveNote = TextEditingController();
  final _saveNote = TextEditingController();
  final _spendNote = TextEditingController();
  final _improveNote = TextEditingController();

  ReflectionNumbers? _numbers;
  Reflection? _existing;
  bool _saving = false;

  bool get _weekly => widget.type == ReflectionType.weekly;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final startDay = ref.read(settingsProvider).monthStartDay;
    final p = widget.period;
    final existing = await db.reflectionFor(widget.type, p.start);
    final planPeriod = _weekly ? budgetMonthFor(p.start, startDay) : p;
    final plan = await db.planFor(planPeriod.start);
    final entries = await db.entriesBetween(p.start, p.end);
    final live = computeReflectionNumbers(
      type: widget.type,
      planMonthDays: planPeriod.lengthInDays,
      hasPlan: plan != null,
      incomeFils: plan?.incomeFils ?? 0,
      fixedCostsFils: plan?.fixedCostsFils ?? 0,
      savingsGoalFils: plan?.savingsGoalFils ?? 0,
      spending: [for (final e in entries) (e.category, e.amountFils)],
    );
    if (!mounted) return;
    setState(() {
      _existing = existing;
      // A saved reflection keeps the numbers it was saved with.
      _numbers = existing == null
          ? live
          : ReflectionNumbers(
              hasPlan: true,
              haveFils: existing.haveFils,
              saveFils: existing.saveFils,
              spentFils: existing.spentFils,
              spentByCategory: live.spentFils == existing.spentFils
                  ? live.spentByCategory
                  : const {},
            );
      if (existing != null) {
        _haveNote.text = existing.haveNote;
        _saveNote.text = existing.saveNote;
        _spendNote.text = existing.spendNote;
        _improveNote.text = existing.improveNote;
      }
    });
  }

  @override
  void dispose() {
    _haveNote.dispose();
    _saveNote.dispose();
    _spendNote.dispose();
    _improveNote.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n = _numbers!;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref
        .read(databaseProvider)
        .saveReflection(
          type: widget.type,
          periodStart: widget.period.start,
          haveFils: n.haveFils,
          saveFils: n.saveFils,
          spentFils: n.spentFils,
          haveNote: _haveNote.text,
          saveNote: _saveNote.text,
          spendNote: _spendNote.text,
          improveNote: _improveNote.text,
        );
    navigator.pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Reflection saved')));
  }

  Future<void> _delete() async {
    final existing = _existing!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this reflection?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(databaseProvider).deleteReflection(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = _numbers;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(_weekly ? 'Weekly reflection' : 'Monthly reflection'),
            Text(
              reflectionTitle(widget.type, widget.period),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (_existing != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: n == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (_existing != null)
                        _Hint('Numbers as they were when you first saved this reflection.')
                      else if (!n.hasPlan)
                        _Hint(
                          'There is no plan for this month, so income and savings are '
                          'shown as zero.',
                        ),
                      _QuestionCard(
                        number: 1,
                        question: 'How much money did I have?',
                        explanation: _weekly
                            ? 'This week’s share of income minus fixed costs'
                            : 'Income minus fixed costs',
                        amount: n.haveFils,
                        note: _haveNote,
                      ),
                      _QuestionCard(
                        number: 2,
                        question: 'How much did I want to save?',
                        explanation: _weekly
                            ? 'This week’s share of your savings goal'
                            : 'Your savings goal',
                        amount: n.saveFils,
                        note: _saveNote,
                        footer: n.saveFils > 0 ? _savedLine(theme, n) : null,
                      ),
                      _QuestionCard(
                        number: 3,
                        question: 'How much did I spend?',
                        explanation: 'Everything recorded in this period',
                        amount: n.spentFils,
                        note: _spendNote,
                        footer: n.spentByCategory.isEmpty || n.spentFils == 0
                            ? null
                            : _Breakdown(numbers: n),
                      ),
                      _ImproveCard(controller: _improveNote),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_existing == null ? 'Save reflection' : 'Save changes'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _savedLine(ThemeData theme, ReflectionNumbers n) {
    final left = n.leftFils;
    final text = left >= 0
        ? 'On track: ${context.money(n.saveFils)} saved, ${context.money(left)} unspent on top'
        : left.abs() >= n.saveFils
        ? 'Savings used up, ${context.money(left.abs() - n.saveFils)} over'
        : 'Saved ${context.money(n.saveFils + left)} of ${context.money(n.saveFils)}';
    return Text(
      text,
      style: moneyStyle(theme.textTheme.bodySmall)
          .copyWith(color: left >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.number);

  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.explanation,
    required this.amount,
    required this.note,
    this.footer,
  });

  final int number;
  final String question;
  final String explanation;
  final int amount;
  final TextEditingController note;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _NumberBadge(number),
                  const SizedBox(width: 10),
                  Expanded(child: Text(question, style: theme.textTheme.titleMedium)),
                ],
              ),
              const SizedBox(height: 12),
              MoneyText(amount, size: 30),
              Text(
                explanation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (footer != null) ...[const SizedBox(height: 10), footer!],
              const SizedBox(height: 12),
              TextField(
                controller: note,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Note (optional)', isDense: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.numbers});

  final ReflectionNumbers numbers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = numbers.spentFils;
    return Column(
      children: [
        for (final c in SpendCategory.values)
          if (numbers.spentByCategory[c]! > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(c.icon, size: 16, color: c.color(theme.brightness)),
                  const SizedBox(width: 8),
                  SizedBox(width: 64, child: Text(c.label, style: theme.textTheme.bodySmall)),
                  Expanded(
                    child: ProgressBar(
                      value: numbers.spentByCategory[c]! / total,
                      color: c.color(theme.brightness),
                      height: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.money(numbers.spentByCategory[c]!),
                    style: moneyStyle(theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _ImproveCard extends StatelessWidget {
  const _ImproveCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _NumberBadge(4),
                const SizedBox(width: 10),
                Expanded(child: Text('How can I improve?', style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'What went well, what didn’t, and one thing to try next time.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 4,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Write your thoughts…'),
            ),
          ],
        ),
      ),
    );
  }
}
