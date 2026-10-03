import 'package:flutter/material.dart';

import '../theme.dart';
import '../util/money.dart';
import 'money_scope.dart';

/// An amount set like a ledger figure: small symbol, large whole part,
/// smaller decimals. Follows the app currency and the privacy mask.
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
    final currency = context.currency;
    final hidden = context.amountsHidden;
    final text = hidden
        ? maskedAmount
        : formatFils(fils.abs(), currency: currency, withSymbol: false);
    final dot = text.contains('.') ? text.indexOf('.') : text.length;
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
          if (fils < 0 && !hidden) const TextSpan(text: '−'),
          if (showSymbol)
            TextSpan(
              text: '${currency.symbol} ',
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w500,
                color: soft,
                letterSpacing: 0,
              ),
            ),
          if (hidden)
            TextSpan(
              text: maskedAmount,
              style: TextStyle(fontSize: size * 0.58, color: soft, letterSpacing: 2),
            )
          else
            TextSpan(text: text.substring(0, dot)),
          TextSpan(
            text: text.substring(dot),
            style: TextStyle(fontSize: size * 0.58, color: soft, letterSpacing: 0),
          ),
        ],
      ),
      maxLines: 1,
      semanticsLabel: hidden ? 'Amount hidden' : formatFils(fils, currency: currency),
    );
  }
}
