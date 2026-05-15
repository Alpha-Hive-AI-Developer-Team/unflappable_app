import 'package:dio/dio.dart';
import 'package:unflappable/features/Setting/Model/setting_model.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class SettingsService {
  static Future<Response> getSettings() {
    return DioHelper.getData(endPoint: EndPoints.settings.settings);
  }

  static Future<Response> getAccount() {
    return DioHelper.getData(endPoint: EndPoints.settings.account);
  }

  static Future<Response> updateAccount({required String fullName}) {
    return DioHelper.putData(
      endPoint: EndPoints.settings.account,
      data: {'fullName': fullName},
    );
  }

  static Future<Response> getNotifications() {
    return DioHelper.getData(endPoint: EndPoints.settings.notifications);
  }

  static Future<Response> updateNotifications({
    required NotificationSettings notifications,
  }) {
    return DioHelper.putData(
      endPoint: EndPoints.settings.notifications,
      data: {
        'dailyReminders': notifications.dailyReminders,
        'morningReminder': notifications.morningReminder24h,
        'eveningReminder': notifications.eveningReminder24h,
        'weeklyReview': notifications.weeklyReview,
        'weeklyReminderDay': notifications.weeklyReminderDay,
        'weeklyReminderTime': notifications.weeklyReminderTime24h,
      },
    );
  }

  static Future<Response> logout({required String refreshToken}) {
    return DioHelper.postData(
      endPoint: EndPoints.settings.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  static Future<Response> deleteAccount({
    required String confirmText,
  }) {
    return DioHelper.deleteData(
      endPoint: EndPoints.settings.account,
      data: {'confirmText': confirmText},
    );
  }
}
