import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/features/Auth/providers/user_notifier.dart';
import 'package:unflappable/features/Setting/Model/setting_model.dart';
import 'package:unflappable/features/Setting/Provider/setting_state.dart';
import 'package:unflappable/features/Setting/Utils/account_full_name_merge.dart';
import 'package:unflappable/service/settings_service.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._ref) : super(const SettingsState());

  final Ref _ref;

  Future<void> loadInitialData() async {
    if (state.hasLoadedInitialData || state.isLoadingInitialData) return;
    state = state.copyWith(isLoadingInitialData: true, clearError: true);

    try {
      final settingsResponse = await SettingsService.getSettings();
      final accountResponse = await SettingsService.getAccount();
      final notificationsResponse = await SettingsService.getNotifications();

      final settingsMap = _extractPayload(settingsResponse.data);
      final accountMap = _extractPayload(accountResponse.data);
      final notificationsMap = _extractPayload(notificationsResponse.data);

      final merged = <String, dynamic>{
        ...settingsMap,
        ...accountMap,
        ...notificationsMap,
      };

      final plan = _readString(merged, ['plan']);
      if (plan != null && plan.toLowerCase() == 'pro') {
        _ref.read(userProvider.notifier).syncIsProFromAuxiliaryApi(true);
      }

      final apiName = _readString(merged, ['fullName', 'name']);
      final sessionUser = _ref.read(userProvider).user;
      final mergedFullName = mergeAccountFullNameForDisplay(
        apiFullName: apiName,
        sessionUserName: sessionUser?.name ?? '',
        fallbackDraftFullName: state.accountDraft.fullName,
      );

      final nextAccount = AccountDraft(
        fullName: mergedFullName.isNotEmpty
            ? mergedFullName
            : (apiName ?? state.accountDraft.fullName),
        email: _readString(merged, ['email']) ?? state.accountDraft.email,
      );

      final current = state.notifications;
      final nextNotifications = NotificationSettings(
        dailyReminders:
            _readBool(merged, ['dailyReminders']) ?? current.dailyReminders,
        morningReminder: NotificationSettings.toDisplayTime(
          _readString(merged, ['morningReminder']) ??
              current.morningReminder24h,
        ),
        eveningReminder: NotificationSettings.toDisplayTime(
          _readString(merged, ['eveningReminder']) ??
              current.eveningReminder24h,
        ),
        weeklyReview:
            _readBool(merged, ['weeklyReview']) ?? current.weeklyReview,
        weeklyReminderDay:
            _readString(merged, ['weeklyReminderDay']) ??
            current.weeklyReminderDay,
        weeklyReminder: NotificationSettings.toDisplayTime(
          _readString(merged, ['weeklyReminderTime']) ??
              current.weeklyReminderTime24h,
        ),
      );

      state = state.copyWith(
        accountDraft: nextAccount,
        notifications: nextNotifications,
        isLoadingInitialData: false,
        hasLoadedInitialData: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoadingInitialData: false,
        errorMessage: _dioErrorMessage(e, fallback: 'Failed to load settings.'),
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingInitialData: false,
        errorMessage: 'Failed to load settings.',
      );
    }
  }

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

  void setWeeklyReminderDay(String v) => state = state.copyWith(
    notifications: state.notifications.copyWith(weeklyReminderDay: v),
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
    state = state.copyWith(isSavingAccount: true, clearError: true);
    try {
      await SettingsService.updateAccount(
        fullName: state.accountDraft.fullName,
      );
      state = state.copyWith(isSavingAccount: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isSavingAccount: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Failed to update account.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isSavingAccount: false,
        errorMessage: 'Failed to update account.',
      );
    }
  }

  Future<void> saveNotifications() async {
    state = state.copyWith(isSavingNotifications: true, clearError: true);
    try {
      await SettingsService.updateNotifications(
        notifications: state.notifications,
      );
      state = state.copyWith(isSavingNotifications: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isSavingNotifications: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Failed to update notification settings.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isSavingNotifications: false,
        errorMessage: 'Failed to update notification settings.',
      );
    }
  }

  Future<bool> logout() async {
    state = state.copyWith(isProcessingLogout: true, clearError: true);
    try {
      final refreshToken =
          LocalStorage.getData(LocalStorage.refreshToken) ??
          LocalStorage.getData(LocalStorage.accessToken) ??
          '';
      await SettingsService.logout(refreshToken: refreshToken);
      await NotificationManager.deleteDeviceToken();
      await LocalStorage.clearAllData();
      state = state.copyWith(isProcessingLogout: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isProcessingLogout: false,
        errorMessage: _dioErrorMessage(e, fallback: 'Failed to logout.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isProcessingLogout: false,
        errorMessage: 'Failed to logout.',
      );
      return false;
    }
  }

  Future<bool> deleteAccount({required String confirmText}) async {
    state = state.copyWith(isDeletingAccount: true, clearError: true);
    try {
      await SettingsService.deleteAccount(confirmText: confirmText);
      await LocalStorage.clearAllData();
      state = state.copyWith(isDeletingAccount: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isDeletingAccount: false,
        errorMessage: _dioErrorMessage(
          e,
          fallback: 'Failed to delete account.',
        ),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isDeletingAccount: false,
        errorMessage: 'Failed to delete account.',
      );
      return false;
    }
  }

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }

  Map<String, dynamic> _extractPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  bool? _readBool(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) return value;
    }
    return null;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref),
);
