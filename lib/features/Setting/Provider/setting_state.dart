import 'package:unflappable/features/Setting/Model/setting_model.dart';

class SettingsState {
  final SettingsSection section;
  final NotificationSettings notifications;
  final AccountDraft accountDraft;
  final bool isSavingAccount;

  const SettingsState({
    this.section = SettingsSection.main,
    this.notifications = const NotificationSettings(),
    this.accountDraft = const AccountDraft(),
    this.isSavingAccount = false,
  });

  SettingsState copyWith({
    SettingsSection? section,
    NotificationSettings? notifications,
    AccountDraft? accountDraft,
    bool? isSavingAccount,
  }) => SettingsState(
    section: section ?? this.section,
    notifications: notifications ?? this.notifications,
    accountDraft: accountDraft ?? this.accountDraft,
    isSavingAccount: isSavingAccount ?? this.isSavingAccount,
  );
}
