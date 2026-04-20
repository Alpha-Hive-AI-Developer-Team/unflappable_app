part of 'endpoint.dart';

class _Notifications {
  final String _apiBaseUrl;

  factory _Notifications({required String apiBaseUrl}) {
    _instance ??= _Notifications._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Notifications._sharedInstance({required String apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl;

  static _Notifications? _instance;

  String get _notificationsController => '$_apiBaseUrl/api/notifications';

  String get device => '$_notificationsController/device';
  String get list => _notificationsController;
  String read(String notificationId) => '$_notificationsController/$notificationId/read';
  String get readAll => '$_notificationsController/read-all';
}
