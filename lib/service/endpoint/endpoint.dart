// endpoint.dart
library;

import 'package:unflappable/service/endpoint/endpoint.dart';

part 'authentication_endpoints.dart';
part 'onboarding_endpoints.dart';

abstract final class EndPoints {
  static const String baseUrl =
      'https://peakishly-modiolar-abrielle.ngrok-free.dev';
  static _Authentication get auth => _Authentication(apiBaseUrl: baseUrl);
  static _Onboarding get onboarding => _Onboarding(apiBaseUrl: baseUrl);
}
