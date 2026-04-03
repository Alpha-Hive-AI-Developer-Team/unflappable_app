// authentication_endpoints.dart
part of 'endpoint.dart';

class _Authentication {
  final String _apiBaseUrl;

  factory _Authentication({required String apiBaseUrl}) {
    _instance ??= _Authentication._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Authentication._sharedInstance({required String apiBaseUrl})
    : _apiBaseUrl = apiBaseUrl;

  static _Authentication? _instance;

  String get _controllerName => '$_apiBaseUrl/api/vendor';
  String get login => '$_controllerName/login/';
  String get deleteAccount => '$_controllerName/auth-details/delete/';
}
