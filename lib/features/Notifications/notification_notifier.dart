import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Notifications/notification_model.dart';
import 'package:unflappable/features/Notifications/notification_state.dart';
import 'package:unflappable/service/notification_service.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState());

  Future<void> fetchNotifications() async {
    state = state.copyWith(
      status: NotificationStatus.loading,
      errorMessage: null,
    );

    try {
      final response = await NotificationService.fetchNotifications();
      final notifications = _parseResponse(response.data);
      notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: notifications,
        hasLoadedOnce: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: _extractError(
          e,
          fallback: 'Unable to fetch notifications.',
        ),
        hasLoadedOnce: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Unable to fetch notifications.',
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentIndex = state.notifications.indexWhere(
      (item) => item.id == notificationId,
    );
    if (currentIndex < 0) return;

    final notification = state.notifications[currentIndex];
    if (notification.isRead) return;

    final optimistic = List<AppNotification>.from(state.notifications);
    optimistic[currentIndex] = notification.copyWith(isRead: true);
    state = state.copyWith(notifications: optimistic);

    try {
      await NotificationService.markAsRead(notificationId: notificationId);
    } on DioException catch (e) {
      // UN-31: don't flip `status` to error — that was replacing the whole
      // list with a full-screen error for a single failed tap. Revert just
      // this item and surface a toast instead.
      state = state.copyWith(
        actionErrorMessage: _extractError(
          e,
          fallback: 'Unable to mark notification as read.',
        ),
      );
      _revertReadState(notificationId);
    } catch (_) {
      state = state.copyWith(
        actionErrorMessage: 'Unable to mark notification as read.',
      );
      _revertReadState(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    if (state.notifications.isEmpty) return;

    final previous = List<AppNotification>.from(state.notifications);
    final optimistic = state.notifications
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    state = state.copyWith(notifications: optimistic);

    try {
      await NotificationService.markAllRead();
    } on DioException catch (e) {
      state = state.copyWith(
        notifications: previous,
        actionErrorMessage: _extractError(
          e,
          fallback: 'Unable to mark all notifications as read.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        notifications: previous,
        actionErrorMessage: 'Unable to mark all notifications as read.',
      );
    }
  }

  void clearActionError() {
    state = state.copyWith(actionErrorMessage: null);
  }

  void _revertReadState(String notificationId) {
    final index = state.notifications.indexWhere(
      (item) => item.id == notificationId,
    );
    if (index < 0) return;
    final reverted = List<AppNotification>.from(state.notifications);
    reverted[index] = reverted[index].copyWith(isRead: false);
    state = state.copyWith(notifications: reverted);
  }

  List<AppNotification> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(
        data['data'] as List,
      ).map(AppNotification.fromJson).toList();
    }

    if (data is List) {
      return List<Map<String, dynamic>>.from(
        data,
      ).map(AppNotification.fromJson).toList();
    }

    return <AppNotification>[];
  }

  String _extractError(DioException e, {required String fallback}) {
    final payload = e.response?.data;
    if (payload is Map<String, dynamic>) {
      final message = payload['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
      (_) => NotificationsNotifier(),
    );
