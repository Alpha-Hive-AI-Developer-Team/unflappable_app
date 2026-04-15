import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_provider/otp_state.dart';
import 'package:unflappable/service/auth_service.dart';

class OtpNotifier extends StateNotifier<OtpState> {
  Timer? _timer;

  OtpNotifier() : super(const OtpState()) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsLeft == 0) {
        t.cancel();
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  void setDigit(int index, String value) {
    final updated = List<String>.from(state.digits);
    updated[index] = value;
    state = state.copyWith(digits: updated);
  }

  void resend() {
    state = state.copyWith(digits: ['', '', '', ''], secondsLeft: 56);
    _timer?.cancel();
    _startTimer();
  }

  Future<String?> verify({
    required String email,
    required OtpPurpose purpose,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final code = state.digits.join();
      final response = purpose == OtpPurpose.signup
          ? await AuthService.verifyEmail(
              email: email.trim(),
              code: code,
            )
          : await AuthService.verifyOtp(
              email: email.trim(),
              code: code,
            );

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (purpose == OtpPurpose.forgotPassword) {
          return _extractResetToken(response.data);
        }

        final token = _extractAuthToken(response.data);
        if (token != null) {
          await LocalStorage.saveData(LocalStorage.accessToken, token);
          return token;
        }
        return null;
      }
      return null;
    } on DioException {
      state = state.copyWith(isLoading: false);
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  String? _extractResetToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final token = data['resetToken'] ?? data['token'];
      if (token != null) return token.toString();
      if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'] as Map<String, dynamic>;
        return nested['resetToken']?.toString() ?? nested['token']?.toString();
      }
    }
    return null;
  }

  String? _extractAuthToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final token = data['accessToken'] ?? data['token'] ?? data['authToken'];
      if (token != null) return token.toString();
      if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'] as Map<String, dynamic>;
        return nested['accessToken']?.toString() ??
            nested['token']?.toString() ??
            nested['authToken']?.toString();
      }
    }
    return null;
  }

  Future<bool> resendCode({
    required String email,
    required OtpPurpose purpose,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = purpose == OtpPurpose.signup
          ? await AuthService.resendEmailVerificationOtp(email: email.trim())
          : await AuthService.resendOtp(email: email.trim());

      if (response.statusCode == 200 || response.statusCode == 201) {
        resend();
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on DioException {
      state = state.copyWith(isLoading: false);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
