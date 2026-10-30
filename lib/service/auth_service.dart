import 'package:dio/dio.dart';
import 'package:unflappable/service/dio_helper.dart';
import 'package:unflappable/service/endpoint/endpoint.dart';

abstract final class AuthService {
  static Future<Response> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.signup,
      data: {'fullName': fullName, 'email': email, 'password': password},
    );
  }

  static Future<Response> login({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.login,
      data: {'fullName': fullName, 'email': email, 'password': password},
    );
  }

  static Future<Response> signInWithApple({
    required String identityToken,
    String? fullName,
    // US-33: Apple only sends these on the very first authorization —
    // backend accepts them as an alternative to `fullName` and uses them
    // for its placeholder-upgrade logic, so send them raw (unjoined) when
    // available instead of relying solely on our own composed string.
    String? givenName,
    String? familyName,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.apple,
      data: {
        'identityToken': identityToken,
        if (fullName != null && fullName.trim().isNotEmpty)
          'fullName': fullName.trim(),
        if (givenName != null && givenName.isNotEmpty) 'givenName': givenName,
        if (familyName != null && familyName.isNotEmpty)
          'familyName': familyName,
      },
    );
  }

  static Future<Response> forgotPassword({required String email}) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.forgotPassword,
      data: {'email': email},
    );
  }

  static Future<Response> verifyOtp({
    required String email,
    required String code,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.verifyOtp,
      data: {'email': email, 'otp': code},
    );
  }

  static Future<Response> verifyEmail({
    required String email,
    required String code,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.verifyEmail,
      data: {'email': email, 'otp': code},
    );
  }

  static Future<Response> resetPassword({
    required String resetToken,
    required String newPassword,
    String? confirmPassword,
  }) async {
    final payload = {'resetToken': resetToken, 'newPassword': newPassword};
    if (confirmPassword != null) {
      payload['confirmPassword'] = confirmPassword;
    }

    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.resetPassword,
      data: payload,
    );
  }

  static Future<Response> resendOtp({required String email}) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.resendOtp,
      data: {'email': email},
    );
  }

  static Future<Response> resendEmailVerificationOtp({
    required String email,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.verifyEmailResend,
      data: {'email': email},
    );
  }

  /// Change password for an already-authenticated user (Bearer token).
  /// Distinct from the forgot-password/OTP reset flow.
  static Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return DioHelper.putData(
      endPoint: EndPoints.auth.changePassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  /// US-29: for accounts with no password yet (e.g. Apple-only, `hasPassword
  /// == false`). Distinct from [changePassword] — no current password to
  /// verify. Backend returns `PASSWORD_ALREADY_SET` if one already exists.
  static Future<Response> setPassword({required String newPassword}) async {
    return DioHelper.postData(
      endPoint: EndPoints.auth.setPassword,
      data: {'newPassword': newPassword},
    );
  }
}
