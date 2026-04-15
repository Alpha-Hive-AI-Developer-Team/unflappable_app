enum SettingsSection { main, notifications, account, helpCenter, legal }

class NotificationSettings {
  final bool dailyReminders;
  final String morningReminder; // e.g. "8:00 AM"
  final String eveningReminder; // e.g. "7:00 PM"
  final bool weeklyReview;
  final String weeklyReminderDay; // e.g. "Sunday"
  final String weeklyReminder; // e.g. "6:00 PM"

  const NotificationSettings({
    this.dailyReminders = true,
    this.morningReminder = '8:00 AM',
    this.eveningReminder = '7:00 PM',
    this.weeklyReview = true,
    this.weeklyReminderDay = 'Sunday',
    this.weeklyReminder = '6:00 PM',
  });

  NotificationSettings copyWith({
    bool? dailyReminders,
    String? morningReminder,
    String? eveningReminder,
    bool? weeklyReview,
    String? weeklyReminderDay,
    String? weeklyReminder,
  }) => NotificationSettings(
    dailyReminders: dailyReminders ?? this.dailyReminders,
    morningReminder: morningReminder ?? this.morningReminder,
    eveningReminder: eveningReminder ?? this.eveningReminder,
    weeklyReview: weeklyReview ?? this.weeklyReview,
    weeklyReminderDay: weeklyReminderDay ?? this.weeklyReminderDay,
    weeklyReminder: weeklyReminder ?? this.weeklyReminder,
  );

  String get morningReminder24h => _to24Hour(morningReminder);
  String get eveningReminder24h => _to24Hour(eveningReminder);
  String get weeklyReminderTime24h => _to24Hour(weeklyReminder);
  static String toDisplayTime(String value) => _to12Hour(value);

  static String _to24Hour(String value) {
    final text = value.trim().toUpperCase();
    final parts = text.split(' ');
    if (parts.length < 2) return text;

    final time = parts[0].split(':');
    if (time.length != 2) return text;

    var hour = int.tryParse(time[0]);
    final minute = int.tryParse(time[1]);
    final meridiem = parts[1];
    if (hour == null || minute == null) return text;

    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;

    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }

  static String _to12Hour(String value) {
    final text = value.trim();
    final time = text.split(':');
    if (time.length != 2) return text;

    final hour = int.tryParse(time[0]);
    final minute = int.tryParse(time[1]);
    if (hour == null || minute == null) return text;

    final isPm = hour >= 12;
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    final hourString = normalizedHour.toString();
    final minuteString = minute.toString().padLeft(2, '0');
    final suffix = isPm ? 'PM' : 'AM';
    return '$hourString:$minuteString $suffix';
  }
}

class AccountDraft {
  final String fullName;
  final String email;

  const AccountDraft({this.fullName = '', this.email = ''});

  AccountDraft copyWith({String? fullName, String? email}) => AccountDraft(
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
  );
}
