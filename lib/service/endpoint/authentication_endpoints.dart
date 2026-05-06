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

  String get _authController => '$_apiBaseUrl/api/auth';
  String get _vendorController => '$_apiBaseUrl/api/vendor';

  String get signup => '$_authController/signup';
  String get login => '$_authController/login';
  String get apple => '$_authController/apple';
  String get forgotPassword => '$_authController/password/forgot';
  String get verifyOtp => '$_authController/password/verify-otp';
  String get verifyEmail => '$_authController/verify-email';
  String get verifyEmailResend => '$_authController/verify-email/resend';
  String get resetPassword => '$_authController/password/reset';
  String get resendOtp => '$_authController/password/resend-otp';

  String get deleteAccount => '$_vendorController/auth-details/delete/';
}
