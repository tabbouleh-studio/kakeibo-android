import 'package:flutter/material.dart';

/// Days 1–31 as a grid of round buttons, for "month starts on day".
class DayGrid extends StatelessWidget {
  const DayGrid({super.key, required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var d = 1; d <= 31; d++)
          Material(
            color: d == selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHigh,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(d),
              child: Center(
                child: Text(
                  '$d',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: d == selected ? theme.colorScheme.onPrimary : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
