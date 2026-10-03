import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';

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
    _load();
  }

  Future<void> _load() async {
    final plan = await ref.read(currentPlanProvider.future);
    if (!mounted) return;
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

  int get _spendable =>
      _fils(_income) - _costs.fold<int>(0, (sum, c) => sum + _fils(c.amount)) - _fils(_savings);

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
    final spendable = _spendable;

    return Scaffold(
      appBar: AppBar(title: const Text('This month\'s plan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  Text(
                    formatPeriod(period),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MoneyField(controller: _income, label: 'Income', validator: _validateAmount),
                  const SizedBox(height: 24),
                  Text('Fixed costs', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Rent, bills and other costs you pay every month. '
                    'They reduce what you can spend but are not logged as expenses.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  for (final (i, row) in _costs.indexed) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: row.name,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(labelText: 'Name'),
                            validator: (v) =>
                                (v?.trim().isEmpty ?? true) && !row.isBlank ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _MoneyField(
                            controller: row.amount,
                            label: 'Amount',
                            validator: (v) => row.isBlank ? null : _validateAmount(v),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          padding: const EdgeInsets.only(top: 8),
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _costs.removeAt(i).dispose()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _costs.add(_CostRow())),
                      icon: const Icon(Icons.add),
                      label: const Text('Add fixed cost'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MoneyField(
                    controller: _savings,
                    label: 'Savings goal',
                    validator: (v) => _validateAmount(v, required: false),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spendable this month', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            formatFils(spendable),
                            style: moneyStyle(theme.textTheme.headlineMedium)
                                .copyWith(color: spendable < 0 ? theme.colorScheme.error : null),
                          ),
                          if (spendable < 0)
                            Text(
                              'Your fixed costs and savings goal are more than your income.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: const Text('Save plan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({required this.controller, required this.label, this.validator});

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: moneyStyle(null),
      decoration: InputDecoration(labelText: label, prefixText: 'KD ', hintText: '0.000'),
      validator: validator,
    );
  }
}
