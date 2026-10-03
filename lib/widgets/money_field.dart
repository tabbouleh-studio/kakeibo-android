import 'package:flutter/material.dart';

import '../theme.dart';

/// A text field for a KWD amount ("KD 12.750"). Validate with parseFils.
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
      decoration: InputDecoration(labelText: label, prefixText: 'KD ', hintText: '0.000'),
      validator: validator,
    );
  }
}
