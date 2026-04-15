part of 'endpoint.dart';

class _Settings {
  final String _apiBaseUrl;

  factory _Settings({required String apiBaseUrl}) {
    _instance ??= _Settings._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Settings._sharedInstance({required String apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl;

  static _Settings? _instance;

  String get _settingsController => '$_apiBaseUrl/api/settings';

  String get settings => _settingsController;
  String get account => '$_settingsController/account';
  String get notifications => '$_settingsController/notifications';
  String get logout => '$_settingsController/logout';
}
