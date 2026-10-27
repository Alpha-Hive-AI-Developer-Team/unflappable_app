import 'package:unflappable/features/Notifications/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

const _keep = Object();

class NotificationsState {
  final NotificationStatus status;
  final List<AppNotification> notifications;
  final String? errorMessage;
  // UN-31: a failed mark-as-read/mark-all-read no longer flips [status] to
  // error (which was replacing the whole list with a full-screen error) —
  // it's surfaced separately as a one-off toast instead.
  final String? actionErrorMessage;
  // Set once the first fetch (success or failure) completes. Distinguishes
  // "first load ever" from "refreshing a list that happens to be empty" —
  // checking notifications.isEmpty alone can't tell those apart.
  final bool hasLoadedOnce;

  const NotificationsState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.actionErrorMessage,
    this.hasLoadedOnce = false,
  });

  bool get isLoading => status == NotificationStatus.loading;
  // Only the very first load shows a full-screen spinner; a pull-to-refresh
  // (even of an empty list) relies on RefreshIndicator's own spinner instead
  // — fixes the duplicate-loader bug.
  bool get isInitialLoading => isLoading && !hasLoadedOnce;
  bool get hasError => status == NotificationStatus.error;
  bool get isEmpty => notifications.isEmpty && status != NotificationStatus.loading;

  NotificationsState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    Object? errorMessage = _keep,
    Object? actionErrorMessage = _keep,
    bool? hasLoadedOnce,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage:
          errorMessage == _keep ? this.errorMessage : errorMessage as String?,
      actionErrorMessage: actionErrorMessage == _keep
          ? this.actionErrorMessage
          : actionErrorMessage as String?,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}
