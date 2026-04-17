// endpoint.dart
library;

part 'authentication_endpoints.dart';
part 'home_endpoints.dart';
part 'onboarding_endpoints.dart';
part 'progress_endpoints.dart';
part 'settings_endpoints.dart';
part 'weekly_review_endpoints.dart';
part 'reset_endpoints.dart';

abstract final class EndPoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://unflappable-app-backend.onrender.com',
  );
  static _Authentication get auth => _Authentication(apiBaseUrl: baseUrl);
  static _Home get home => _Home(apiBaseUrl: baseUrl);
  static _Onboarding get onboarding => _Onboarding(apiBaseUrl: baseUrl);
  static _Progress get progress => _Progress(apiBaseUrl: baseUrl);
  static _Settings get settings => _Settings(apiBaseUrl: baseUrl);
  static _WeeklyReview get weeklyReview => _WeeklyReview(apiBaseUrl: baseUrl);
  static _Reset get reset => _Reset(apiBaseUrl: baseUrl);
}
