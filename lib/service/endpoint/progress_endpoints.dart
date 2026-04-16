part of 'endpoint.dart';

class _Progress {
  final String _apiBaseUrl;

  factory _Progress({required String apiBaseUrl}) {
    _instance ??= _Progress._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Progress._sharedInstance({required String apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl;

  static _Progress? _instance;

  String get overview => '$_apiBaseUrl/api/progress';
}
