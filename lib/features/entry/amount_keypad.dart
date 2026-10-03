import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          Row(
            children: [
              for (final key in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _Key(
                      keyValue: key,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onKey(key);
                      },
                      onLongPress: key == backspaceKey
                          ? () {
                              HapticFeedback.mediumImpact();
                              onClear();
                            }
                          : null,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.keyValue, required this.onTap, this.onLongPress});

  final String keyValue;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAction = keyValue == backspaceKey || keyValue == '.';
    return Material(
      color: isAction
          ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
          : theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          height: 58,
          child: Center(
            child: keyValue == backspaceKey
                ? const Icon(Icons.backspace_outlined, semanticLabel: 'Delete', size: 22)
                : Text(
                    keyValue == '.' ? '·' : keyValue,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: keyValue == '.' ? FontWeight.w900 : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
