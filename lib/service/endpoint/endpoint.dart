// endpoint.dart
library;

part 'authentication_endpoints.dart';
part 'onboarding_endpoints.dart';
part 'settings_endpoints.dart';

abstract final class EndPoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://peakishly-modiolar-abrielle.ngrok-free.dev',
  );
  static _Authentication get auth => _Authentication(apiBaseUrl: baseUrl);
  static _Onboarding get onboarding => _Onboarding(apiBaseUrl: baseUrl);
  static _Settings get settings => _Settings(apiBaseUrl: baseUrl);
}
