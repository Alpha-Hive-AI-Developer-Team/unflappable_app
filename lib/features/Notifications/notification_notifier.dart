import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/core/notifications/notification_manager.dart';
import 'package:unflappable/features/Notifications/notification_model.dart';
import 'package:unflappable/features/Notifications/notification_state.dart';
import 'package:unflappable/service/notification_service.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(const NotificationsState()) {
    _notificationSubscription = NotificationManager.onNotificationReceived
        .listen((_) {
          if (state.hasLoadedOnce) unawaited(fetchNotifications());
        });
  }

  late final StreamSubscription<void> _notificationSubscription;
  bool _isFetching = false;

  Future<void> fetchNotifications() async {
    if (_isFetching) return;
    _isFetching = true;
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
        // Immediate fallback from this page's own data; refined below by
        // the dedicated endpoint, which accounts for pages not fetched yet.
        unreadCount: notifications.where((item) => !item.isRead).length,
      );
      unawaited(fetchUnreadCount());
    } on DioException catch (_) {
      // Always show a plain, user-facing message here — this is a
      // full-screen error state, unlike the action-error toast below, so a
      // raw backend route/technical string (e.g. a 404's internal message)
      // must never be shown directly to the user.
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Unable to fetch notifications.',
        hasLoadedOnce: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Unable to fetch notifications.',
        hasLoadedOnce: true,
      );
    } finally {
      _isFetching = false;
    }
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }

  /// UN-56: authoritative unread count for the Home bell badge.
  Future<void> fetchUnreadCount() async {
    try {
      final response = await NotificationService.fetchUnreadCount();
      final count = _extractUnreadCount(response.data);
      if (count != null) {
        state = state.copyWith(unreadCount: count);
      }
    } catch (_) {
      // Keep whatever value is already shown (derived from the list, or
      // the last successful fetch) rather than blanking the badge.
    }
  }

  int? _extractUnreadCount(dynamic data) {
    if (data is int) return data;
    if (data is Map<String, dynamic>) {
      final direct =
          data['unreadCount'] ?? data['count'] ?? data['unread_count'];
      if (direct is int) return direct;
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return _extractUnreadCount(nested);
      if (nested is int) return nested;
    }
    return null;
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
    state = state.copyWith(
      notifications: optimistic,
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    );

    try {
      await NotificationService.markAsRead(notificationId: notificationId);
    } on DioException catch (e) {
      // UN-60: a response was received and it was a success status — the
      // backend processed the mutation. Treat this as success rather than
      // reverting; whatever threw happened after the HTTP layer already
      // confirmed success (e.g. decoding an empty/non-JSON body).
      if (_isSuccessStatus(e.response?.statusCode)) return;

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

  bool _isSuccessStatus(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  Future<void> markAllAsRead() async {
    if (state.notifications.isEmpty) return;

    final previous = List<AppNotification>.from(state.notifications);
    final previousUnreadCount = state.unreadCount;
    final optimistic = state.notifications
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    state = state.copyWith(notifications: optimistic, unreadCount: 0);

    try {
      await NotificationService.markAllRead();
    } on DioException catch (e) {
      if (_isSuccessStatus(e.response?.statusCode)) return;

      state = state.copyWith(
        notifications: previous,
        unreadCount: previousUnreadCount,
        actionErrorMessage: _extractError(
          e,
          fallback: 'Unable to mark all notifications as read.',
        ),
      );
    } catch (_) {
      state = state.copyWith(
        notifications: previous,
        unreadCount: previousUnreadCount,
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
    state = state.copyWith(
      notifications: reverted,
      unreadCount: state.unreadCount + 1,
    );
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
