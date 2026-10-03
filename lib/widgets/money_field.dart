import 'package:flutter/material.dart';

import '../theme.dart';
import '../util/money.dart';
import 'money_scope.dart';

/// A text field for an amount in the app currency. Validate with parseFils.
class MoneyField extends StatelessWidget {
  const MoneyField({super.key, required this.controller, this.validator, this.label});

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: moneyStyle(Theme.of(context).textTheme.titleMedium),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '${context.currency.symbol} ',
        hintText: formatFils(0, currency: context.currency, withSymbol: false),
      ),
      validator: validator,
    );
  }
}
