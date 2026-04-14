import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
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

  Future<bool> verify({required String email}) async {
    state = state.copyWith(isLoading: true);
    try {
      final code = state.digits.join();
      final response = await AuthService.verifyOtp(
        email: email.trim(),
        code: code,
      );

      state = state.copyWith(isLoading: false);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException {
      state = state.copyWith(isLoading: false);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> resendCode({required String email}) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await AuthService.resendOtp(email: email.trim());
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
