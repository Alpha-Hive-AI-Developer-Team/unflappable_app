import 'package:flutter_riverpod/legacy.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_provider/otp_notifier.dart';
import 'package:unflappable/features/Auth/otp_screen/otp_provider/otp_state.dart';

final otpProvider = StateNotifierProvider.autoDispose<OtpNotifier, OtpState>(
  (_) => OtpNotifier(),
);
