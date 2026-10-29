enum OtpPurpose { signup, forgotPassword }

class OtpState {
  final List<String> digits;
  final int secondsLeft;
  // UA-9: split from a single shared `isLoading` — that made the Next
  // button show a spinner during Resend (the wrong control), and nothing
  // disabled Back during either request.
  final bool isVerifying;
  final bool isResending;

  const OtpState({
    this.digits = const ['', '', '', ''],
    this.secondsLeft = 56,
    this.isVerifying = false,
    this.isResending = false,
  });

  bool get isComplete => digits.every((d) => d.isNotEmpty);
  bool get isBusy => isVerifying || isResending;

  OtpState copyWith({
    List<String>? digits,
    int? secondsLeft,
    bool? isVerifying,
    bool? isResending,
  }) => OtpState(
    digits: digits ?? this.digits,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    isVerifying: isVerifying ?? this.isVerifying,
    isResending: isResending ?? this.isResending,
  );
}
