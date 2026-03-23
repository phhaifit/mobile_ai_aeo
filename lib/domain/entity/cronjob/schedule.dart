enum Schedule {
  daily,
  weekly,
  monthly,
  custom,
}

extension ScheduleExtension on Schedule {
  String get displayName {
    switch (this) {
      case Schedule.daily:
        return 'Daily';
      case Schedule.weekly:
        return 'Weekly';
      case Schedule.monthly:
        return 'Monthly';
      case Schedule.custom:
        return 'Custom Cron';
    }
  }

  String toJson() => name;

  static Schedule fromJson(String json) =>
      Schedule.values.firstWhere((e) => e.name == json);
}
