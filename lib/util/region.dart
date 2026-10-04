import 'package:flutter/widgets.dart';

import '../models/currency.dart';
import '../models/region_currency.dart';

/// The country part of the phone's region setting (e.g. "KW" from
/// "English (Kuwait)"), read on the device. Null if none is set.
String? phoneRegion([List<Locale>? locales]) {
  for (final locale in locales ?? WidgetsBinding.instance.platformDispatcher.locales) {
    final country = locale.countryCode;
    if (country != null && country.length == 2) return country.toUpperCase();
  }
  return null;
}

/// The usual currency for [region], if the app supports it.
Currency? currencyForRegion(String? region) {
  final code = regionCurrency[region];
  return code != null && Currency.isKnown(code) ? Currency.byCode(code) : null;
}
