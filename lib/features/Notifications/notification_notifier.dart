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
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: _extractError(
          e,
          fallback: 'Unable to fetch notifications.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Unable to fetch notifications.',
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

    final updated = List<AppNotification>.from(state.notifications);
    updated[currentIndex] = notification.copyWith(isRead: true);
    state = state.copyWith(notifications: updated);

    try {
      await NotificationService.markAsRead(notificationId: notificationId);
    } on DioException catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: _extractError(
          e,
          fallback: 'Unable to mark notification as read.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Unable to mark notification as read.',
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (state.notifications.isEmpty) return;

    final updatedNotifications = state.notifications
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    state = state.copyWith(notifications: updatedNotifications);

    try {
      await NotificationService.markAllRead();
    } on DioException catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: _extractError(
          e,
          fallback: 'Unable to mark all notifications as read.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Unable to mark all notifications as read.',
      );
    }
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
