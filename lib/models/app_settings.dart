import 'package:flutter/foundation.dart';

import 'currency.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.monthStartDay = 1,
    this.weekStartDay = DateTime.sunday,
    this.lockEnabled = false,
    this.lastBackupAt,
    this.currencyCode = 'KWD',
    this.hideAmounts = false,
  });

  static const monthStartDayKey = 'monthStartDay';
  static const weekStartDayKey = 'weekStartDay';
  static const lockEnabledKey = 'lockEnabled';
  static const lastBackupAtKey = 'lastBackupAt';
  static const currencyKey = 'currency';
  static const hideAmountsKey = 'hideAmounts';
  static const keys = {
    monthStartDayKey,
    weekStartDayKey,
    lockEnabledKey,
    lastBackupAtKey,
    currencyKey,
    hideAmountsKey,
  };

  /// Week start choices offered in settings, as [DateTime.weekday] values.
  static const weekStartChoices = {
    DateTime.sunday: 'Sunday',
    DateTime.saturday: 'Saturday',
    DateTime.monday: 'Monday',
  };

  /// Day of the month (1–31) the budget month starts on.
  final int monthStartDay;

  /// [DateTime.weekday] value the week starts on.
  final int weekStartDay;
  final bool lockEnabled;
  final DateTime? lastBackupAt;

  /// ISO 4217 code of the display currency.
  final String currencyCode;

  /// Privacy mask: amounts show as •••• until revealed.
  final bool hideAmounts;

  Currency get currency => Currency.byCode(currencyCode);

  AppSettings copyWith({
    int? monthStartDay,
    int? weekStartDay,
    bool? lockEnabled,
    DateTime? lastBackupAt,
    String? currencyCode,
    bool? hideAmounts,
  }) => AppSettings(
    monthStartDay: monthStartDay ?? this.monthStartDay,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    currencyCode: currencyCode ?? this.currencyCode,
    hideAmounts: hideAmounts ?? this.hideAmounts,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.monthStartDay == monthStartDay &&
      other.weekStartDay == weekStartDay &&
      other.lockEnabled == lockEnabled &&
      other.lastBackupAt == lastBackupAt &&
      other.currencyCode == currencyCode &&
      other.hideAmounts == hideAmounts;

  @override
  int get hashCode => Object.hash(
    monthStartDay,
    weekStartDay,
    lockEnabled,
    lastBackupAt,
    currencyCode,
    hideAmounts,
  );
}
