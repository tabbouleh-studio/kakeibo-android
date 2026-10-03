import 'dart:convert';
import 'dart:typed_data';

import '../util/money.dart';
import 'database.dart';

/// Entries as CSV for Excel: UTF-8 with BOM, CRLF lines, ISO dates and
/// plain decimal amounts like 12.750.
Uint8List entriesToCsv(List<Entry> entries) {
  final buffer = StringBuffer('﻿')..write('Date,Category,Amount (KWD),Note\r\n');
  for (final e in entries) {
    final d = e.date;
    final date =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    buffer.write('$date,${e.category.label},${filsToInput(e.amountFils)},${_field(e.note)}\r\n');
  }
  return Uint8List.fromList(utf8.encode(buffer.toString()));
}

String _field(String value) {
  if (!value.contains(RegExp(r'[",\r\n]'))) return value;
  return '"${value.replaceAll('"', '""')}"';
}
