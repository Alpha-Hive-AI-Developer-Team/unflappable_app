import 'package:unflappable/features/Setting/Model/setting_model.dart';

const _keep = Object();

class SettingsState {
  final SettingsSection section;
  final NotificationSettings notifications;
  // US-23 / US-69: last loaded/saved snapshot — compared against
  // [notifications] to decide whether Save Preferences should be enabled.
  final NotificationSettings savedNotifications;
  final AccountDraft accountDraft;
  // US-26 / US-27: last loaded/saved snapshot — compared against
  // [accountDraft] to decide whether Save Changes should be enabled, and to
  // discard an unsaved edit when the screen is left without saving.
  final AccountDraft savedAccountDraft;
  final String? accountNameError;
  final bool isSavingAccount;
  final bool isSavingNotifications;
  final bool isProcessingLogout;
  final bool isDeletingAccount;
  final bool isLoadingInitialData;
  final bool hasLoadedInitialData;
  final String? errorMessage;

  const SettingsState({
    this.section = SettingsSection.main,
    this.notifications = const NotificationSettings(),
    this.savedNotifications = const NotificationSettings(),
    this.accountDraft = const AccountDraft(),
    this.savedAccountDraft = const AccountDraft(),
    this.accountNameError,
    this.isSavingAccount = false,
    this.isSavingNotifications = false,
    this.isProcessingLogout = false,
    this.isDeletingAccount = false,
    this.isLoadingInitialData = false,
    this.hasLoadedInitialData = false,
    this.errorMessage,
  });

  bool get hasUnsavedNotificationChanges => notifications != savedNotifications;

  bool get hasUnsavedAccountChanges =>
      accountDraft.fullName.trim() != savedAccountDraft.fullName.trim();

  SettingsState copyWith({
    SettingsSection? section,
    NotificationSettings? notifications,
    NotificationSettings? savedNotifications,
    AccountDraft? accountDraft,
    AccountDraft? savedAccountDraft,
    Object? accountNameError = _keep,
    bool? isSavingAccount,
    bool? isSavingNotifications,
    bool? isProcessingLogout,
    bool? isDeletingAccount,
    bool? isLoadingInitialData,
    bool? hasLoadedInitialData,
    String? errorMessage,
    bool clearError = false,
  }) => SettingsState(
    section: section ?? this.section,
    notifications: notifications ?? this.notifications,
    savedNotifications: savedNotifications ?? this.savedNotifications,
    accountDraft: accountDraft ?? this.accountDraft,
    savedAccountDraft: savedAccountDraft ?? this.savedAccountDraft,
    accountNameError: accountNameError == _keep
        ? this.accountNameError
        : accountNameError as String?,
    isSavingAccount: isSavingAccount ?? this.isSavingAccount,
    isSavingNotifications: isSavingNotifications ?? this.isSavingNotifications,
    isProcessingLogout: isProcessingLogout ?? this.isProcessingLogout,
    isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
    isLoadingInitialData: isLoadingInitialData ?? this.isLoadingInitialData,
    hasLoadedInitialData: hasLoadedInitialData ?? this.hasLoadedInitialData,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
