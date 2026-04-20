import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class NotificationService {
  static Future<Response> registerDevice({
    required String fcmToken,
    required String platform,
  }) {
    return DioHelper.postData(
      endPoint: EndPoints.notifications.device,
      data: {
        'fcmToken': fcmToken,
        'platform': platform,
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

  static Future<Response> markAsRead({
    required String notificationId,
  }) {
    return DioHelper.patchData(
      endPoint: EndPoints.notifications.read(notificationId),
      data: {},
    );
  }

  static Future<Response> markAllRead() {
    return DioHelper.patchData(
      endPoint: EndPoints.notifications.readAll,
      data: {},
    );
  }
}
