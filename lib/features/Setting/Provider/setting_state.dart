import 'package:unflappable/features/Setting/Model/setting_model.dart';

class SettingsState {
  final SettingsSection section;
  final NotificationSettings notifications;
  final AccountDraft accountDraft;
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
    this.accountDraft = const AccountDraft(),
    this.isSavingAccount = false,
    this.isSavingNotifications = false,
    this.isProcessingLogout = false,
    this.isDeletingAccount = false,
    this.isLoadingInitialData = false,
    this.hasLoadedInitialData = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsSection? section,
    NotificationSettings? notifications,
    AccountDraft? accountDraft,
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
    accountDraft: accountDraft ?? this.accountDraft,
    isSavingAccount: isSavingAccount ?? this.isSavingAccount,
    isSavingNotifications: isSavingNotifications ?? this.isSavingNotifications,
    isProcessingLogout: isProcessingLogout ?? this.isProcessingLogout,
    isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
    isLoadingInitialData: isLoadingInitialData ?? this.isLoadingInitialData,
    hasLoadedInitialData: hasLoadedInitialData ?? this.hasLoadedInitialData,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
