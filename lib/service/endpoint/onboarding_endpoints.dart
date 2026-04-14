part of 'endpoint.dart';

class _Onboarding {
  final String _apiBaseUrl;

  factory _Onboarding({required String apiBaseUrl}) {
    _instance ??= _Onboarding._sharedInstance(apiBaseUrl: apiBaseUrl);
    return _instance!;
  }

  _Onboarding._sharedInstance({required String apiBaseUrl})
      : _apiBaseUrl = apiBaseUrl;

  static _Onboarding? _instance;

  String get _onboardingController => '$_apiBaseUrl/api/onboarding';

  String get complete => '$_onboardingController/complete';
}
