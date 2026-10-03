import 'package:intl/intl.dart';

/// 1 KWD = 1,000 fils. All money in the app is an `int` number of fils.
const filsPerDinar = 1000;

/// Largest amount accepted from user input (999,999,999.999 KWD).
const maxInputFils = 999999999999;

final _grouping = NumberFormat('#,##0', 'en_US');

/// Formats fils for display: 12750 -> "KD 12.750", 1234500 -> "KD 1,234.500".
String formatFils(int fils, {bool withSymbol = true}) {
  final abs = fils.abs();
  final dinars = _grouping.format(abs ~/ filsPerDinar);
  final rest = (abs % filsPerDinar).toString().padLeft(3, '0');
  final number = withSymbol ? 'KD $dinars.$rest' : '$dinars.$rest';
  return fils < 0 ? '-$number' : number;
}

/// Formats fils for an editable text field: 12750 -> "12.750", no grouping.
String filsToInput(int fils) => formatFils(fils, withSymbol: false).replaceAll(',', '');

final _amountPattern = RegExp(r'^(\d*)(?:\.(\d{0,3}))?$');

/// Parses user input into fils. Accepts "12.75", "12.750", ".5", "1,234.5",
/// "KD 12" and Arabic-Indic digits. Returns null for anything invalid,
/// negative, or with more than 3 decimal places.
int? parseFils(String input) {
  var s = _normalizeDigits(input).replaceAll(RegExp(r'[\s,]'), '');
  if (s.toUpperCase().startsWith('KD')) s = s.substring(2);
  final match = _amountPattern.firstMatch(s);
  if (match == null) return null;
  final whole = match.group(1)!;
  final frac = match.group(2) ?? '';
  if (whole.isEmpty && frac.isEmpty) return null;
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
/// one decimal point, at most 3 decimals, no leading zeros, bounded length.
String applyAmountKey(String current, String key) {
  if (key == backspaceKey) {
    return current.isEmpty ? current : current.substring(0, current.length - 1);
  }
  if (key == '.') {
    if (current.contains('.')) return current;
    return current.isEmpty ? '0.' : '$current.';
  }
  if (!RegExp(r'^\d$').hasMatch(key)) return current;
  final dot = current.indexOf('.');
  if (dot >= 0) {
    if (current.length - dot - 1 >= 3) return current;
  } else {
    if (current == '0') return key;
    if (current.length >= 9) return current;
  }
  return current + key;
}
