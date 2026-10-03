import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../models/enums.dart';
import '../../theme.dart';
import '../../util/money.dart';
import '../../util/period.dart';
import '../../widgets/money_field.dart';
import '../../widgets/money_text.dart';

/// Subscriptions and other repeating expenses, logged automatically when due.
class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(recurringItemsProvider);

    void open([RecurringItem? item]) =>
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => RecurringFormScreen(item: item)));

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring entries')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: open,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load.\n$e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          children: [
            Text(
              'Things like subscriptions that you want in the ledger. Each one is added '
              'automatically when it’s due, the next time you open the app. '
              'Rent and bills belong in fixed costs instead.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_repeat_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text('No recurring entries yet', style: theme.textTheme.titleMedium),
                  ],
                ),
              )
            else
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (i, item) in list.indexed) ...[
                      if (i > 0) const Divider(indent: 68),
                      _RecurringTile(item: item, onTap: () => open(item)),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile({required this.item, required this.onTap});

  final RecurringItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = item.category.color(theme.brightness);
    final every = item.frequency == Frequency.weekly ? 'Weekly' : 'Monthly';
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: item.active ? 0.16 : 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.category.icon, color: item.active ? color : theme.disabledColor, size: 20),
      ),
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        item.active ? '$every · next ${formatDay(item.nextDueDate)}' : '$every · paused',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: MoneyText(
        item.amountFils,
        size: 17,
        color: item.active ? null : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({super.key, this.item});

  final RecurringItem? item;

  @override
  ConsumerState<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  SpendCategory _category = SpendCategory.wants;
  Frequency _frequency = Frequency.monthly;
  DateTime _nextDue = dateOnly(DateTime.now());
  bool _active = true;

  @override
  void initState() {
    super.initState();
    if (widget.item case final item?) {
      _name.text = item.name;
      _amount.text = filsToInput(item.amountFils);
      _category = item.category;
      _frequency = item.frequency;
      _nextDue = item.nextDueDate;
      _active = item.active;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDue,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Next due date',
    );
    if (picked != null) setState(() => _nextDue = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    final db = ref.read(databaseProvider);
    await db.saveRecurringItem(
      RecurringItemsCompanion(
        id: widget.item == null ? const Value.absent() : Value(widget.item!.id),
        name: Value(_name.text.trim()),
        amountFils: Value(parseFils(_amount.text)!),
        category: Value(_category),
        frequency: Value(_frequency),
        nextDueDate: Value(_nextDue),
        active: Value(_active),
      ),
    );
    // Something due today or earlier is logged straight away.
    await db.processDueRecurring(dateOnly(DateTime.now()));
    navigator.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this recurring entry?'),
        content: const Text('Expenses it already added stay in your ledger.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    await ref.read(databaseProvider).deleteRecurringItem(widget.item!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.item != null;
    final today = dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit recurring' : 'New recurring'),
        actions: [
          if (editing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Netflix'),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            MoneyField(
              controller: _amount,
              label: 'Amount',
              validator: (v) => (parseFils(v ?? '') ?? 0) > 0 ? null : 'Enter an amount like 3.500',
            ),
            const SizedBox(height: 20),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in SpendCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18, color: c.color(theme.brightness)),
                    label: Text(c.label),
                    selected: _category == c,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Repeats', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Frequency>(
              segments: const [
                ButtonSegment(value: Frequency.weekly, label: Text('Weekly')),
                ButtonSegment(value: Frequency.monthly, label: Text('Monthly')),
              ],
              selected: {_frequency},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _frequency = s.first),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.event_rounded),
                    title: const Text('Next due'),
                    subtitle: Text(
                      _nextDue.isAfter(today)
                          ? formatDay(_nextDue)
                          : '${formatDay(_nextDue)} · will be added now',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickDate,
                  ),
                  const Divider(indent: 56),
                  SwitchListTile(
                    secondary: const Icon(Icons.play_circle_outline_rounded),
                    title: const Text('Active'),
                    subtitle: const Text('Pause to stop adding it for now'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
