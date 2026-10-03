import 'package:flutter/material.dart';

import '../theme.dart';
import '../util/money.dart';

/// An amount set like a ledger figure: small "KD", large dinars, smaller fils.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.fils, {
    super.key,
    this.size = 32,
    this.color,
    this.weight = FontWeight.w600,
    this.showSymbol = true,
  });

  final int fils;
  final double size;
  final Color? color;
  final FontWeight weight;
  final bool showSymbol;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    final soft = ink.withValues(alpha: 0.62);
    final text = formatFils(fils.abs(), withSymbol: false);
    final dot = text.indexOf('.');
    final style = moneyStyle(
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: ink,
        letterSpacing: size > 28 ? -1 : -0.3,
        height: 1.1,
      ),
    );

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          if (fils < 0) const TextSpan(text: '−'),
          if (showSymbol)
            TextSpan(
              text: 'KD ',
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w500,
                color: soft,
                letterSpacing: 0,
              ),
            ),
          TextSpan(text: text.substring(0, dot)),
          TextSpan(
            text: text.substring(dot),
            style: TextStyle(fontSize: size * 0.58, color: soft, letterSpacing: 0),
          ),
        ],
      ),
      maxLines: 1,
      semanticsLabel: formatFils(fils),
    );
  }
}
