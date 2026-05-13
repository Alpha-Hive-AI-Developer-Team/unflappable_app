// subscription_endpoints.dart
part of 'endpoint.dart';

class _Subscription {
  final String _apiBaseUrl;

  factory _Subscription({required String apiBaseUrl}) {
    _instance ??= _Subscription._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Subscription._sharedInstance({required String apiBaseUrl})
    : _apiBaseUrl = apiBaseUrl;

  static _Subscription? _instance;

  String get _root => '$_apiBaseUrl/api/subscription';

  String get plans => '$_root/plans';
  String get status => '$_root/status';
  String get verify => '$_root/verify';
  String get restore => '$_root/restore';
}
