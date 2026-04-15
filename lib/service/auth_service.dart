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
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Response> login({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.login,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Response> forgotPassword({
    required String email,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.forgotPassword,
      data: {
        'email': email,
      },
    );
  }

  static Future<Response> verifyOtp({
    required String email,
    required String code,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.verifyOtp,
      data: {
        'email': email,
        'otp': code,
      },
    );
  }

  static Future<Response> verifyEmail({
    required String email,
    required String code,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.verifyEmail,
      data: {
        'email': email,
        'otp': code,
      },
    );
  }

  static Future<Response> resetPassword({
    required String resetToken,
    required String newPassword,
    String? confirmPassword,
  }) async {
    final payload = {
      'resetToken': resetToken,
      'newPassword': newPassword,
    };
    if (confirmPassword != null) {
      payload['confirmPassword'] = confirmPassword;
    }

    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.resetPassword,
      data: payload,
    );
  }

  static Future<Response> resendOtp({
    required String email,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.resendOtp,
      data: {
        'email': email,
      },
    );
  }

  static Future<Response> resendEmailVerificationOtp({
    required String email,
  }) async {
    return DioHelper.postWithOutAuthData(
      endPoint: EndPoints.auth.verifyEmailResend,
      data: {
        'email': email,
      },
    );
  }
}
