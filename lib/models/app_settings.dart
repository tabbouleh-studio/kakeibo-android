import 'package:flutter/material.dart' show ThemeMode, immutable;

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
    this.themeMode = ThemeMode.system,
    this.onboardingDone = false,
  });

  static const monthStartDayKey = 'monthStartDay';
  static const weekStartDayKey = 'weekStartDay';
  static const lockEnabledKey = 'lockEnabled';
  static const lastBackupAtKey = 'lastBackupAt';
  static const currencyKey = 'currency';
  static const hideAmountsKey = 'hideAmounts';
  static const themeModeKey = 'themeMode';
  static const onboardingDoneKey = 'onboardingDone';
  static const keys = {
    monthStartDayKey,
    weekStartDayKey,
    lockEnabledKey,
    lastBackupAtKey,
    currencyKey,
    hideAmountsKey,
    themeModeKey,
    onboardingDoneKey,
  };

  /// Week start choices offered in settings, as [DateTime.weekday] values.
  static const weekStartChoices = {
    DateTime.sunday: 'Sunday',
    DateTime.saturday: 'Saturday',
    DateTime.monday: 'Monday',
  };

  static const themeModeLabels = {
    ThemeMode.system: 'System default',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
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

  /// Light, dark, or follow the phone.
  final ThemeMode themeMode;

  /// First-launch setup finished (device state, not in backups).
  final bool onboardingDone;

  Currency get currency => Currency.byCode(currencyCode);

  AppSettings copyWith({
    int? monthStartDay,
    int? weekStartDay,
    bool? lockEnabled,
    DateTime? lastBackupAt,
    String? currencyCode,
    bool? hideAmounts,
    ThemeMode? themeMode,
    bool? onboardingDone,
  }) => AppSettings(
    monthStartDay: monthStartDay ?? this.monthStartDay,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    currencyCode: currencyCode ?? this.currencyCode,
    hideAmounts: hideAmounts ?? this.hideAmounts,
    themeMode: themeMode ?? this.themeMode,
    onboardingDone: onboardingDone ?? this.onboardingDone,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.monthStartDay == monthStartDay &&
      other.weekStartDay == weekStartDay &&
      other.lockEnabled == lockEnabled &&
      other.lastBackupAt == lastBackupAt &&
      other.currencyCode == currencyCode &&
      other.hideAmounts == hideAmounts &&
      other.themeMode == themeMode &&
      other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(
    monthStartDay,
    weekStartDay,
    lockEnabled,
    lastBackupAt,
    currencyCode,
    hideAmounts,
    themeMode,
    onboardingDone,
  );
}
