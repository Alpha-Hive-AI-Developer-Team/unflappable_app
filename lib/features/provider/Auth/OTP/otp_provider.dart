import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/provider/Auth/OTP/otp_notifier.dart';
import 'package:unflappable/features/provider/Auth/OTP/otp_state.dart';

final otpProvider = StateNotifierProvider.autoDispose<OtpNotifier, OtpState>(
  (_) => OtpNotifier(),
);
