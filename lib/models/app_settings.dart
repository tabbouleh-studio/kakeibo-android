import 'package:flutter/foundation.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.monthStartDay = 1,
    this.weekStartDay = DateTime.sunday,
    this.lockEnabled = false,
    this.lastBackupAt,
  });

  static const monthStartDayKey = 'monthStartDay';
  static const weekStartDayKey = 'weekStartDay';
  static const lockEnabledKey = 'lockEnabled';
  static const lastBackupAtKey = 'lastBackupAt';
  static const keys = {monthStartDayKey, weekStartDayKey, lockEnabledKey, lastBackupAtKey};

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

  AppSettings copyWith({
    int? monthStartDay,
    int? weekStartDay,
    bool? lockEnabled,
    DateTime? lastBackupAt,
  }) => AppSettings(
    monthStartDay: monthStartDay ?? this.monthStartDay,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.monthStartDay == monthStartDay &&
      other.weekStartDay == weekStartDay &&
      other.lockEnabled == lockEnabled &&
      other.lastBackupAt == lastBackupAt;

  @override
  int get hashCode => Object.hash(monthStartDay, weekStartDay, lockEnabled, lastBackupAt);
}
