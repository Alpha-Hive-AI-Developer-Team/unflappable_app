import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/OTP/otp_state.dart';

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

  Future<void> verify() async {
    state = state.copyWith(isLoading: true);
    // TODO: call auth repository
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
