import 'package:dio/dio.dart';
import 'package:unflappable/core/utils/device_timezone.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class NotificationService {
  static Future<Response> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    // UA-81: sent at app start / device register so backend's cron has the
    // user's real IANA timezone instead of defaulting to UTC.
    final timezone = await DeviceTimezone.current();
    return DioHelper.postData(
      endPoint: EndPoints.notifications.device,
      data: {
        'fcmToken': fcmToken,
        'platform': platform,
        if (timezone != null) 'timezone': timezone,
      },
    );
  }

  static Future<Response> deleteDevice({
    required String fcmToken,
  }) {
    return DioHelper.deleteData(
      endPoint: EndPoints.notifications.device,
      data: {'fcmToken': fcmToken},
    );
  }

  static Future<Response> fetchNotifications() {
    return DioHelper.getData(endPoint: EndPoints.notifications.list);
  }

  // UN-56: dedicated count instead of deriving from the (possibly
  // paginated) fetched list, so the Home bell badge matches the backend's
  // true unread total.
  static Future<Response> fetchUnreadCount() {
    return DioHelper.getData(endPoint: EndPoints.notifications.unreadCount);
  }

  // UN-60: these mutate state and we never read the body back — but Dio's
  // default JSON transformer throws on a 200/204 with an empty/non-JSON
  // body, and that exception was being caught as a failure and reverting an
  // already-successful mark-as-read. responseType.plain skips that parse.
  static Future<Response> markAsRead({
    required String notificationId,
  }) {
    return DioHelper.patchData(
      endPoint: EndPoints.notifications.read(notificationId),
      data: {},
      options: Options(responseType: ResponseType.plain),
    );
  }

  static Future<Response> markAllRead() {
    return DioHelper.patchData(
      endPoint: EndPoints.notifications.readAll,
      data: {},
      options: Options(responseType: ResponseType.plain),
    );
  }
}
