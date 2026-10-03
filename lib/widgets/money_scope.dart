import 'package:flutter/widgets.dart';

import '../models/currency.dart';
import '../util/money.dart';

/// Provides the display currency and the privacy mask to every screen.
class MoneyScope extends InheritedWidget {
  const MoneyScope({super.key, required this.currency, required this.hidden, required super.child});

  final Currency currency;

  /// True while the privacy mask hides amounts.
  final bool hidden;

  static MoneyScope? _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MoneyScope>();

  @override
  bool updateShouldNotify(MoneyScope old) => old.currency != currency || old.hidden != hidden;
}

const maskedAmount = '••••';

extension MoneyContext on BuildContext {
  Currency get currency => MoneyScope._of(this)?.currency ?? Currency.kwd;

  bool get amountsHidden => MoneyScope._of(this)?.hidden ?? false;

  /// An amount for display, e.g. "KD 12.750", or "KD ••••" when masked.
  /// Pass `mask: false` for amounts the user is entering.
  String money(int fils, {bool mask = true}) => mask && amountsHidden
      ? '${currency.symbol} $maskedAmount'
      : formatFils(fils, currency: currency);
}
