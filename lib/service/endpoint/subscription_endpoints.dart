// subscription_endpoints.dart
part of 'endpoint.dart';

// PRO FEATURE — disabled for the current free-only release.
// Commented out (not deleted) so it can be restored when the Pro tier
// relaunches. See also: endpoint.dart (the `EndPoints.subscription` getter
// that exposed this is commented out too), subscription_service.dart,
// subscription_models.dart, pricing_screen.dart, pricing_notifier.dart.
/*
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
*/
