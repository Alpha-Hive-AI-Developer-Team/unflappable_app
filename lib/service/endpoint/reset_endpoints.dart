part of 'endpoint.dart';

class _Reset {
  final String _apiBaseUrl;

  factory _Reset({required String apiBaseUrl}) {
    _instance ??= _Reset._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Reset._sharedInstance({required String apiBaseUrl})
    : _apiBaseUrl = apiBaseUrl;

  static _Reset? _instance;

  String get _resetController => '$_apiBaseUrl/api/reset';
  String get landing => _resetController;
  String get trigger => _resetController;
  String get history => '$_resetController/history';
}
