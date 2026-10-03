import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import '../../widgets/money_text.dart';

/// Set intentions for the current budget month: income, fixed costs, savings goal.
class MonthSetupScreen extends ConsumerStatefulWidget {
  const MonthSetupScreen({super.key});

  @override
  ConsumerState<MonthSetupScreen> createState() => _MonthSetupScreenState();
}

class _CostRow {
  _CostRow([String name = '', String amount = ''])
    : name = TextEditingController(text: name),
      amount = TextEditingController(text: amount);

  final TextEditingController name;
  final TextEditingController amount;

  bool get isBlank => name.text.trim().isEmpty && amount.text.trim().isEmpty;

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class _MonthSetupScreenState extends ConsumerState<MonthSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _income = TextEditingController();
  final _savings = TextEditingController();
  final List<_CostRow> _costs = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Listen (not read): an unlistened provider is paused and might never load.
    ref.listenManual(currentPlanProvider, (_, next) {
      if (_loading && next.hasValue) _fill(next.value);
    }, fireImmediately: true);
  }

  void _fill(PlanData? plan) {
    setState(() {
      if (plan != null) {
        _income.text = filsToInput(plan.incomeFils);
        _savings.text = filsToInput(plan.savingsGoalFils);
        for (final c in plan.fixedCosts) {
          _costs.add(_CostRow(c.name, filsToInput(c.amountFils)));
        }
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _income.dispose();
    _savings.dispose();
    for (final c in _costs) {
      c.dispose();
    }
    super.dispose();
  }

  int _fils(TextEditingController c) => parseFils(c.text) ?? 0;

  int get _fixedTotal => _costs.fold<int>(0, (sum, c) => sum + _fils(c.amount));

  int get _spendable => _fils(_income) - _fixedTotal - _fils(_savings);

  String? _validateAmount(String? value, {bool required = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Required' : null;
    return parseFils(text) == null ? 'Enter an amount like 12.750' : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final period = ref.read(currentPeriodProvider);
    await ref
        .read(databaseProvider)
        .savePlan(
          periodStart: period.start,
          incomeFils: _fils(_income),
          savingsGoalFils: _fils(_savings),
          costs: [
            for (final c in _costs)
              if (!c.isBlank) (name: c.name.text.trim(), amountFils: _fils(c.amount)),
          ],
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = ref.watch(currentPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Plan your month'),
            Text(
              formatPeriod(period),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _Section(
                          icon: Icons.payments_outlined,
                          title: 'Income',
                          subtitle: 'What comes in this month',
                          child: _MoneyField(controller: _income, validator: _validateAmount),
                        ),
                        const SizedBox(height: 12),
                        _Section(
                          icon: Icons.home_work_outlined,
                          title: 'Fixed costs',
                          subtitle:
                              'Rent, bills and other must-pays. '
                              'They reduce what you can spend but aren’t logged as expenses.',
                          trailing: _fixedTotal > 0 ? MoneyText(_fixedTotal, size: 16) : null,
                          child: _fixedCosts(theme),
                        ),
                        const SizedBox(height: 12),
                        _Section(
                          icon: Icons.savings_outlined,
                          title: 'Savings goal',
                          subtitle: 'Set aside first, before any spending',
                          child: _MoneyField(
                            controller: _savings,
                            validator: (v) => _validateAmount(v, required: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SummaryBar(spendable: _spendable, saving: _saving, onSave: _save),
                ],
              ),
            ),
    );
  }

  Widget _fixedCosts(ThemeData theme) {
    return Column(
      children: [
        for (final (i, row) in _costs.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: row.name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(hintText: 'e.g. Rent'),
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) && !row.isBlank ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _MoneyField(
                    controller: row.amount,
                    validator: (v) => row.isBlank ? null : _validateAmount(v),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  padding: const EdgeInsets.only(top: 6),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _costs.removeAt(i).dispose()),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => setState(() => _costs.add(_CostRow())),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add fixed cost'),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                ?trailing,
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.spendable, required this.saving, required this.onSave});

  final int spendable;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final negative = spendable < 0;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      negative ? 'More than your income' : 'Spendable this month',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: negative
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MoneyText(
                        spendable,
                        size: 26,
                        color: negative ? theme.colorScheme.error : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28)),
                onPressed: saving ? null : onSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({required this.controller, this.validator});

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: moneyStyle(Theme.of(context).textTheme.titleMedium),
      decoration: const InputDecoration(prefixText: 'KD ', hintText: '0.000'),
      validator: validator,
    );
  }
}
