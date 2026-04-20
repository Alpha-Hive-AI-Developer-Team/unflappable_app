import 'package:unflappable/features/Notifications/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationsState {
  final NotificationStatus status;
  final List<AppNotification> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  bool get isLoading => status == NotificationStatus.loading;
  bool get hasError => status == NotificationStatus.error;
  bool get isEmpty => notifications.isEmpty && status != NotificationStatus.loading;

  NotificationsState copyWith({
    NotificationStatus? status,
    List<AppNotification>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}
