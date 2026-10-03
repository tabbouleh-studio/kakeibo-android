import 'package:flutter/material.dart';

import '../../util/money.dart';

/// Calculator-style keypad. Emits digits, '.', or [backspaceKey].
/// Long-pressing backspace emits [onClear].
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({super.key, required this.onKey, required this.onClear});

  final ValueChanged<String> onKey;
  final VoidCallback onClear;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', backspaceKey],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Row(children: [for (final key in row) Expanded(child: _key(context, key))]),
      ],
    );
  }

  Widget _key(BuildContext context, String key) {
    final style = Theme.of(context).textTheme.headlineSmall;
    return SizedBox(
      height: 60,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onKey(key),
        onLongPress: key == backspaceKey ? onClear : null,
        child: Center(
          child: key == backspaceKey
              ? Icon(Icons.backspace_outlined, semanticLabel: 'Delete')
              : Text(key, style: style),
        ),
      ),
    );
  }
}
