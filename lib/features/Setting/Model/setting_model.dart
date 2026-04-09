enum SettingsSection { main, notifications, account, helpCenter, legal }

class NotificationSettings {
  final bool dailyReminders;
  final String morningReminder; // e.g. "8:00 AM"
  final String eveningReminder; // e.g. "7:00 PM"
  final bool weeklyReview;
  final String weeklyReminder; // e.g. "Sunday 6:00 PM"

  const NotificationSettings({
    this.dailyReminders = true,
    this.morningReminder = '8:00 AM',
    this.eveningReminder = '7:00 PM',
    this.weeklyReview = true,
    this.weeklyReminder = 'Sunday 6:00 PM',
  });

  NotificationSettings copyWith({
    bool? dailyReminders,
    String? morningReminder,
    String? eveningReminder,
    bool? weeklyReview,
    String? weeklyReminder,
  }) => NotificationSettings(
    dailyReminders: dailyReminders ?? this.dailyReminders,
    morningReminder: morningReminder ?? this.morningReminder,
    eveningReminder: eveningReminder ?? this.eveningReminder,
    weeklyReview: weeklyReview ?? this.weeklyReview,
    weeklyReminder: weeklyReminder ?? this.weeklyReminder,
  );
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
