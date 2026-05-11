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

  String get _subscriptionController => '$_apiBaseUrl/api/subscription';

  String get plans => '$_subscriptionController/plans';
  String get status => '$_subscriptionController/status';
  String get verify => '$_subscriptionController/verify';
  String get restore => '$_subscriptionController/restore';
}
