import 'package:intl/intl.dart';

import '../models/currency.dart';

/// All money is an `int` number of thousandths of the main unit: fils for
/// KWD (1 KWD = 1,000 fils). Other currencies use the same unit, shown with
/// their own number of decimals.
const filsPerDinar = 1000;

/// Largest amount accepted from user input (999,999,999.999).
const maxInputFils = 999999999999;

final _grouping = NumberFormat('#,##0', 'en_US');

int _pow10(int n) => n == 0 ? 1 : 10 * _pow10(n - 1);

/// Formats for display: 12750 -> "KD 12.750", 1234500 -> "KD 1,234.500".
/// Currencies with fewer decimals round half up: 12755 in USD -> "\$ 12.76".
String formatFils(int fils, {Currency currency = Currency.kwd, bool withSymbol = true}) {
  final step = _pow10(3 - currency.decimals);
  final units = (fils.abs() + step ~/ 2) ~/ step;
  final scale = _pow10(currency.decimals);
  final whole = _grouping.format(units ~/ scale);
  final number = currency.decimals == 0
      ? whole
      : '$whole.${(units % scale).toString().padLeft(currency.decimals, '0')}';
  final text = withSymbol ? '${currency.symbol} $number' : number;
  return fils < 0 && units > 0 ? '-$text' : text;
}

/// Formats for an editable text field: 12750 -> "12.750", no grouping.
String filsToInput(int fils, {Currency currency = Currency.kwd}) =>
    formatFils(fils, currency: currency, withSymbol: false).replaceAll(',', '');

/// A sample amount for hints and error messages: "12.750", "12.50" or "1250".
String exampleAmount(Currency currency) => switch (currency.decimals) {
  0 => '1250',
  2 => '12.50',
  _ => '12.750',
};

/// Parses user input into fils. Accepts "12.75", "12.750", ".5", "1,234.5",
/// a leading currency code or symbol ("KD 12"), and Arabic-Indic digits.
/// Returns null for anything invalid, negative, or with more decimals than
/// [currency] allows.
int? parseFils(String input, {Currency currency = Currency.kwd}) {
  var s = _normalizeDigits(input).replaceAll(RegExp(r'[\s,]'), '');
  for (final prefix in {currency.code, currency.symbol.replaceAll(' ', '')}) {
    if (s.toUpperCase().startsWith(prefix.toUpperCase())) {
      s = s.substring(prefix.length);
      break;
    }
  }
  final match = RegExp('^(\\d*)(?:\\.(\\d{0,${currency.decimals}}))?\$').firstMatch(s);
  if (match == null) return null;
  final whole = match.group(1)!;
  final frac = match.group(2) ?? '';
  if (whole.isEmpty && frac.isEmpty) return null;
  if (currency.decimals == 0 && s.contains('.')) return null;
  if (whole.length > 9) return null;
  final fils =
      int.parse(whole.isEmpty ? '0' : whole) * filsPerDinar + int.parse(frac.padRight(3, '0'));
  return fils > maxInputFils ? null : fils;
}

String _normalizeDigits(String s) {
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660); // Arabic-Indic
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0); // Extended Arabic-Indic
    } else if (rune == 0x066B) {
      buffer.write('.'); // Arabic decimal separator
    } else if (rune == 0x066C) {
      buffer.write(','); // Arabic thousands separator
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Keypad keys for [applyAmountKey].
const backspaceKey = 'back';

/// Applies one keypad press to the typed amount text. Keeps the text valid:
/// one decimal point, at most [decimals] decimals, no leading zeros, bounded length.
String applyAmountKey(String current, String key, {int decimals = 3}) {
  if (key == backspaceKey) {
    return current.isEmpty ? current : current.substring(0, current.length - 1);
  }
  if (key == '.') {
    if (decimals == 0 || current.contains('.')) return current;
    return current.isEmpty ? '0.' : '$current.';
  }
  if (!RegExp(r'^\d$').hasMatch(key)) return current;
  final dot = current.indexOf('.');
  if (dot >= 0) {
    if (current.length - dot - 1 >= decimals) return current;
  } else {
    if (current == '0') return key;
    if (current.length >= 9) return current;
  }
  return current + key;
}
