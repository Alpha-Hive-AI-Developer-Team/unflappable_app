import 'package:unflappable/features/Auth/create_password/create_password_export.dart';
import 'package:unflappable/features/Setting/Model/setting_model.dart';
import 'package:unflappable/features/Setting/Provider/setting_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  // ── Notifications ──────────────────────────────────────────────────────────
  void toggleDailyReminders(bool v) => state = state.copyWith(
    notifications: state.notifications.copyWith(dailyReminders: v),
  );

  void setMorningReminder(String v) => state = state.copyWith(
    notifications: state.notifications.copyWith(morningReminder: v),
  );

  void setEveningReminder(String v) => state = state.copyWith(
    notifications: state.notifications.copyWith(eveningReminder: v),
  );

  void toggleWeeklyReview(bool v) => state = state.copyWith(
    notifications: state.notifications.copyWith(weeklyReview: v),
  );

  void setWeeklyReminder(String v) => state = state.copyWith(
    notifications: state.notifications.copyWith(weeklyReminder: v),
  );

  // ── Account ────────────────────────────────────────────────────────────────
  void initAccountDraft({required String name, required String email}) =>
      state = state.copyWith(
        accountDraft: AccountDraft(fullName: name, email: email),
      );

  void setDraftName(String v) => state = state.copyWith(
    accountDraft: state.accountDraft.copyWith(fullName: v),
  );

  void setDraftEmail(String v) => state = state.copyWith(
    accountDraft: state.accountDraft.copyWith(email: v),
  );

  Future<void> saveAccount() async {
    state = state.copyWith(isSavingAccount: true);
    // TODO: call repository
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isSavingAccount: false);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (_) => SettingsNotifier(),
);
